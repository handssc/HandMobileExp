//
//  EXPDetailViewController.m
//  HandMobileExp
//
//  Created by Tracy－jun on 14-7-10.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import "EXPSubmitDetailViewController.h"
#import "LMCellStype.h"
#import "EXPLineModelDetailViewController.h"
#import "EXPSubmitDetailModel.h"
#import "AFNetRequestModel.h"
#import "MMProgressHUDWindow.H"


@interface EXPSubmitDetailViewController (){
    //点击代理
    EXPSubmitDelegate * delegate;
    
    //httpmodel
    EXPSubmitHttpModel * httpmodel;
    
    //dataBaseModel
    EXPSubmitDetailModel * datamodel;
    
    //组件
    UIButton  * btn;    // 按钮 暂时弃用
    
    //
    int selectRecord;   // 选中记录
    
    //
    BOOL httpFaild;
    
    BOOL uploadLock;    //上传锁
    
    
}

@end

@implementation EXPSubmitDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ///*
        //手动塞入依赖关系，以后会使用ioc
        EXPSubmitDetailDataSource * tv =  [[EXPSubmitDetailDataSource alloc] init];
        tv.DetailTvC = self;
        self.dataSource  = tv;
        
        
        //model
        datamodel = tv.model;
        //*/
         
        httpmodel = [[EXPSubmitHttpModel alloc] init];
        [httpmodel.delegates addObject:self];
        
        selectRecord = 0;
        httpFaild = NO;
        uploadLock = NO;
        
        
        // 上传
        UIImage *checkList = [UIImage imageNamed:@"submit"];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:checkList style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
        
        //按钮
//        btn  =  [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height *0.7, 220, 50)];
//        [btn  setTitle:@"批量提交" forState:UIControlStateNormal];
//        [btn setBackgroundColor:[UIColor colorWithRed:0.780 green:0.805 blue:0.555 alpha:0.670]];
//        [btn  addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchDown];
//        [self.view addSubview:btn];
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    
    /* del by 吴笑诚
    //按钮
    btn  =  [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height *0.7, 220, 50)];
    [btn  setTitle:@"批量提交" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:0.780 green:0.805 blue:0.555 alpha:0.670]];
    [btn  addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
     
     */
    
    //[_tableView setEditing:YES animated:YES];
    //使能选中
    
    
    [_tableView setEditing:YES];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
    //important 解决7.1超过边框问题 
    //_tableView.allowsSelectionDuringEditing = YES;
    
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.title = @"批量上传";
    
    
    
    [self createUI_statistic];
    
    
}

// 统计总览
- (void) createUI_statistic {
    
    // Buuton selecAll
    self.selectAllButton = [[UIButton alloc]initWithFrame:CGRectMake(0.0, self.view.bounds.size.height * 0.02, 70.0, 30.0)];
    
    [self.selectAllButton setTitle:@"全选" forState: UIControlStateNormal];
    [self.selectAllButton.layer setCornerRadius:6.0f];
    self.selectAllButton.showsTouchWhenHighlighted = YES;
    self.selectAllButton.titleLabel.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
    self.selectAllButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.selectAllButton.titleLabel.textColor = [UIColor whiteColor];
    [self.selectAllButton addTarget:self action:@selector(selectAllButtonPressed:) forControlEvents:UIControlEventTouchDown];

    
    // Button cancelSelectAll
    self.cancelSelectAllButton = [[UIButton alloc]initWithFrame:CGRectMake(70.0, self.view.bounds.size.height * 0.02, 80.0, 30.0)];
    [self.cancelSelectAllButton setTitle:@"全部取消" forState: UIControlStateNormal];
    [self.cancelSelectAllButton.layer setCornerRadius:6.0f];
    self.cancelSelectAllButton.showsTouchWhenHighlighted = YES;
    self.cancelSelectAllButton.titleLabel.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
    self.cancelSelectAllButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.cancelSelectAllButton.titleLabel.textColor = [UIColor whiteColor];
    [self.cancelSelectAllButton addTarget:self action:@selector(cancelSelectAllButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    // Button selectPageButton
    self.selectPageButton = [[UIButton alloc]initWithFrame:CGRectMake(150.0, self.view.bounds.size.height * 0.02, 70.0, 30.0)];
    [self.selectPageButton setTitle:@"本页" forState: UIControlStateNormal];
    [self.selectPageButton.layer setCornerRadius:6.0f];
    self.selectPageButton.showsTouchWhenHighlighted = YES;
    self.selectPageButton.titleLabel.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
    self.selectPageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.selectPageButton.titleLabel.textColor = [UIColor whiteColor];
    [self.selectPageButton addTarget:self action:@selector(selectPageButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    //Button cancelSelectPageButton
    self.cancelSelectPageButton = [[UIButton alloc]initWithFrame:CGRectMake(230.0, self.view.bounds.size.height * 0.02, 80.0, 30.0)];
    [self.cancelSelectPageButton setTitle:@"本页取消" forState: UIControlStateNormal];
    [self.cancelSelectPageButton.layer setCornerRadius:6.0f];
    self.cancelSelectPageButton.showsTouchWhenHighlighted = YES;
    self.cancelSelectPageButton.titleLabel.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
    self.cancelSelectPageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.cancelSelectPageButton.titleLabel.textColor = [UIColor whiteColor];
    [self.cancelSelectPageButton addTarget:self action:@selector(cancelSelectPageButtonPressed:) forControlEvents:UIControlEventTouchDown];


    
    [self.view addSubview:self.selectAllButton];
    [self.view addSubview:self.cancelSelectAllButton];
    [self.view addSubview:self.selectPageButton];
    [self.view addSubview:self.cancelSelectPageButton];


    
    self.view.backgroundColor = [UIColor colorWithRed:0.561 green:0.380 blue:0.201 alpha:1.000];

}


#pragma mark button delegate

// 全部选择
- (void)selectAllButtonPressed: (UIButton *)paramSender {
    //NSLog(@" Select ALL");
    //[_tableView selectAll:_tableView];
    
    
    NSInteger sectionCount = [_tableView.dataSource numberOfSectionsInTableView:_tableView];
    for (int section=0; section < sectionCount; section++) {
        NSInteger rowsCount = [_tableView numberOfRowsInSection:section];
        for (int row = 0; row < rowsCount; row++) {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:row inSection:section];
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition: UITableViewScrollPositionNone];
            if ([delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
        }
    }
    

}

// 全部不选
- (void)cancelSelectAllButtonPressed: (UIButton *)paramSender {
    //NSLog(@" Cancel Select ALL");
    
    
    NSInteger sectionCount = [_tableView.dataSource numberOfSectionsInTableView:_tableView];
    for (int section=0; section < sectionCount; section++) {
        NSInteger rowsCount = [_tableView numberOfRowsInSection:section];
        for (int row = 0; row < rowsCount; row++) {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:row inSection:section];
            [_tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            if ([delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
                [delegate tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
            }
            
        }
     
    }
}

// 选中本页
- (void) selectPageButtonPressed:(UIButton *)paramSender {
    
    NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[_tableView indexPathsForVisibleRows]];
    ///*
    for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
        NSIndexPath *indexPath= [anArrayOfIndexPath objectAtIndex:i];
     
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition: UITableViewScrollPositionNone];
        if ([delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
     
    
     }
    
}

// 取消本页
- (void) cancelSelectPageButtonPressed: (UIButton *)paramSender {
    
     NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[_tableView  indexPathsForVisibleRows]];
     for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
         NSIndexPath *indexPath= [anArrayOfIndexPath objectAtIndex:i];
     
         [_tableView deselectRowAtIndexPath:indexPath animated:NO];
     
         if ([delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
             [delegate tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
         }
     
     
     }
    
}

- (void)addDetailPage:(id *)sender
{
    EXPLineModelDetailViewController *detail =  [[EXPLineModelDetailViewController alloc]initWithNibName:nil bundle:nil];
    detail.detailList = self;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark private
- (void)returnHomePage:(id *)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submit:(id *)sender
{
    
    EXPSubmitDetailDataSource  * datasource = self.dataSource;
    FMDataBaseModel * model = datasource.model;
    
    if (uploadLock == NO) {
        uploadLock = YES;
       
        for ( NSNumber * key    in  delegate.selectIndex){
            
            for (  NSDictionary * record in  model.result){
                
                NSNumber * recordId =  [record valueForKey:@"id"];
                
                if([recordId integerValue] == [key integerValue]){
                    
                    NSNumber * expense_amount=  [record valueForKey:@"expense_amount"];
                    NSString *  expenseAmount = [NSString stringWithFormat:@"%.2f",[expense_amount floatValue]];
                    NSNumber  * exchange_rate = [record valueForKey:@"exchangeRate"];
                    
                    NSString *  exchangeRate = [NSString stringWithFormat:@"%.2f",[exchange_rate floatValue]];
                    
                    NSString* currency = [NSString stringWithFormat:@"%@",[record valueForKey:@"currency"] ];
                    
                    NSString* currency_code = [currency substringToIndex:3];
                    NSString* currency_name = nil;
                    if (currency.length < 5) {
                        currency_name = @"人民币";
                    }
                    else {
                        currency_name = [currency substringFromIndex:4];
                        
                    }
                    NSLog(@"%@, %@", currency_code,currency_name);
                    
                    NSDictionary * param = @{
                                             @"expense_amount" : expenseAmount,
                                             @"expense_number" : [record valueForKey:@"expense_number"],
                                             @"expense_place" :[record valueForKey:@"expense_place"],
                                             @"expense_class_id" : [record valueForKey:@"expense_class_id"],
                                             @"expense_type_id"    : [record valueForKey:@"expense_type_id"] ,
                                             @"expense_date"    : [record valueForKey:@"expense_date"],
                                             @"expense_date_to"    : [record valueForKey:@"expense_date_to"],
                                             @"description" : [record valueForKey:@"description"],
                                             @"local_id" : [record valueForKey:@"id"],
                                             @"currency_code" : currency_code,
                                             @"currency_name" : currency_name,
                                             @"exchange_rate" : exchangeRate
                                             
                                             
                                             };
                    
                    
                    
                    selectRecord++;
                    
                    NSData * data =    [record valueForKey:@"item1"];
                    if( data.length !=0){
                        //                    [httpmodel upload:param fileName:@"upload.jpg" data:data];
                        NSMutableArray * files = [[NSMutableArray alloc] init];
                        
                        for(int i = 0;i< 9;i++){
                            NSString * keyItem = @"item";
                            NSString * mimeType =  @"image/jpeg";
                            keyItem = [keyItem stringByAppendingFormat:@"%d",i+1];
                            NSData * data = [record valueForKey:keyItem];
                            if(data !=nil && data.length !=0){
                                NSString * fileName =@"upload";
                                fileName =   [fileName stringByAppendingFormat:@"%d.jpg",i];
                                
                                NSDictionary * file = @{@"mimeType": mimeType,
                                                        @"filename" :fileName,
                                                        @"filedata" :data
                                                        
                                                        
                                                        };
                                
                                [files addObject:file];
                                
                                
                                
                            }
                            
                        }
                        
                        [httpmodel upload:param files:files];
                        
                        
                    }else{
                        [httpmodel upload:param];
                        
                    }
                    
                    
                    
                }
                
            }
            
            
        }

            
        
        
    }
    
    
}

#pragma mark tableview

-(UITableView *)tableView{
    
    if(_tableView == nil){

    _tableView = ({
        //UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
        UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.height-64-44)];
        
//        tableView.backgroundColor = [UIColor colorWithRed:0.876 green:0.874 blue:0.760 alpha:1.0];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.backgroundView = nil;
        //tableView.tableFooterView = [[UIView alloc]init];
        //tableView.tableHeaderView = [[UIView alloc]init];
        tableView;
    });
    }
    
    [self.view addSubview:_tableView];
    return _tableView;
}



#pragma delegate
- (id<UITableViewDelegate>)createDelegate {
    delegate = [[EXPSubmitDelegate alloc] init];
    return delegate;
}



#pragma LMModelDelegate
-(void)modelDidStartLoad:(id<TTModel>)model{
    
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    if([className isEqualToString:@"EXPSubmitDetailModel"]){
        
        
    }else if([className isEqualToString:@"EXPSubmitHttpModel"]){
        MMProgressHUD.presentationStyle =MMProgressHUDPresentationStyleDrop;
        [datamodel load:0 more:0];
        
        [MMProgressHUD showWithTitle:nil status:@"upload"];
       // updateLock = YES;
        
    }
    
}

#pragma model delegate
-(void)modelDidFinishLoad:(id)model{
    NSString * className = [NSString stringWithUTF8String:object_getClassName(model)];
    
    if([className isEqualToString:@"EXPSubmitDetailModel"]){
        //刷新tableview
        [super modelDidFinishLoad:model];
        
    }else if ([className isEqualToString:@"EXPSubmitHttpModel"]){
        
        EXPSubmitHttpModel *__model = model;
        NSLog(@"%@",__model.Json);
        
        NSDictionary * body = [__model.Json valueForKey:@"body"];
        NSDictionary * head = [__model.Json valueForKey:@"head"];
        
        NSString * result =[head valueForKey:@"code"];
        
        
        NSNumber * local_id = [body valueForKey:@"local_id"];

        
        if([result isEqualToString:@"success"]){

                    //不需要上传则直接更新表状态
                NSDictionary * param = @{
                                @"id": local_id,
                                @"local_status": @"upload"
                                };
                NSArray * records = @[param];
                [datamodel update:records];
        
        }else if ([result isEqualToString:@"failure"]){
                
                
            
        }

                    

        
        //每次返回成功后都将需要提交的数据标识减少一
        selectRecord --;
        
        
        if(selectRecord == 0 && !httpFaild ){
            //认为结束
            MMProgressHUD.presentationStyle =MMProgressHUDPresentationStyleNone;
            
              //重置标志位
            httpFaild = NO;
            selectRecord = 0;
                        [delegate.selectIndex removeAllObjects];
            
            [MMProgressHUD dismiss];
            uploadLock = NO;
            [self reload];
        //选中标记为0，而且网络请求失败过
        }else if(selectRecord == 0 && httpFaild){
              //重置标志位
            selectRecord = 0;
            httpFaild = NO;
                        [delegate.selectIndex removeAllObjects];
            
            [MMProgressHUD dismiss];
            uploadLock = NO;

            [self reload];
        }
        
        
        
    }
    
    
    
    
    
}

-(void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error{
        EXPSubmitHttpModel *__model =   model;
            //错误异常处理
    
            //每次返回失败后都将需要提交的数据标识减少一
            selectRecord --;
            httpFaild = YES;
            [delegate.selectIndex removeAllObjects];
    
            //错误只提醒一次,当选择的标记全部返回为止
            if(selectRecord ==0){
            [MMProgressHUD dismiss];
                [self reload];
                //重置标志位
                httpFaild = NO;
                selectRecord = 0;
                uploadLock = NO;
            [LMAlertViewTool showAlertView:@"提示" message:@"网络出现问题，请检查网络后重新提交" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            }
    
}


@end
