//
//  EXPDetailViewController.m
//  HandMobileExp
//
//  Created by Tracy－jun on 14-7-10.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import "EXPDetailViewController.h"
#import "LMCellStype.h"
#import "EXPLineModelDetailViewController.h"
#import "EXPDetailModel.h"
#import "AFNetRequestModel.h"
#import "YFJLeftSwipeDeleteTableView.h"
#import "EXPdateSwitchView.h"
#import "EXPQueryViewController.h"

@interface EXPDetailViewController ()

@property NSInteger amount;                         // 金额
@property (nonatomic, strong)UILabel *sumLabel;
@property (strong, nonatomic)UILabel *sumMoneyLabel;

@property (nonatomic, strong)EXPdateSwitchView *dateSwitchView;

@end

@implementation EXPDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //手动塞入依赖关系，以后会使用ioc
        EXPDetailDataSource * tv =  [[EXPDetailDataSource alloc] init];
        tv.DetailTvC = self;
        self.dataSource  = tv;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    // 导航
    [self createUI_navigation];
    
    // 统计
    [self createUI_statistic];
    
}

#pragma mark -
#pragma mark createUI

// 导航部分
- (void) createUI_navigation {
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.title = @"报销明细";
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(returnHomePage:)];
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDetailPage:)];
    UIBarButtonItem * adddetailpage =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDetailPage:)];
    UIBarButtonItem * queryBar =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(querypage:)];
    
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:adddetailpage, nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.561 green:0.380 blue:0.201 alpha:1.000];
}


// 统计总览
- (void) createUI_statistic {
    
    self.sumMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(160.0, self.view.bounds.size.height * 0.03, 150.0, 30.0)];
    
    self.sumMoneyLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
    self.sumMoneyLabel.textAlignment = NSTextAlignmentRight;
    
    self.sumMoneyLabel.textColor = [UIColor whiteColor];
    self.sumLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0, self.view.bounds.size.height * 0.03, 100.0, 30.0)];
    self.sumLabel.textColor = [UIColor whiteColor];
    self.sumLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
    
    
}

#pragma mark - button delegate

// 添加
- (void)addDetailPage:(id *)sender
{
   EXPLineModelDetailViewController *detail =  [[EXPLineModelDetailViewController alloc]initWithNibName:nil bundle:nil];
    detail.detailList = self;
    [self.navigationController pushViewController:detail animated:YES];
}

// 查询
-(void)querypage:(id *)sender
{
     EXPQueryViewController *queryview =  [[EXPQueryViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:queryview animated:YES];
}

// 返回
- (void)returnHomePage:(id *)sender
{
    if(self.homeList != nil){
        [self.homeList reload];
    }
    if (self.tv != nil) {
        [self.tv reloadData];
    }

    [self.navigationController popViewControllerAnimated:YES];
}



- (UITableView *)tableView{
    
    if(_tableView == nil){
    _tableView = ({
       UITableView * tableView = [[YFJLeftSwipeDeleteTableView alloc]initWithFrame:CGRectMake(0.0, 55.0, self.view.bounds.size.width, self.view.bounds.size.height-55.0)];
        tableView.backgroundView.backgroundColor = [UIColor whiteColor];
//        tableView.backgroundColor = [UIColor colorWithRed:0.947 green:0.940 blue:0.831 alpha:1.000];
        tableView.backgroundView = nil;
        
        tableView.tableFooterView = [[UIView alloc]init];
        tableView.tableHeaderView = [[UIView alloc]init];
        tableView;
    });
    }
    
    [self.view addSubview:_tableView];
    return _tableView;
}




#pragma marik -
#pragma mark LMModelDelegate

-(void)modelDidFinishLoad:(FMDataBaseModel *)model{

    [super modelDidFinishLoad:model];
    // 总计
    double sumMoneyAmount = 0;
    for (  NSDictionary * record in  model.result){
        
        
        
       // sumMoneyAmount = sumMoneyAmount + [[record objectForKey:@"expense_amount"]floatValue]
        //* [[record objectForKey:@"expense_number"] integerValue];
        NSLog(@"create by %@", [record objectForKey:@"CREATED_BY"]);
        
        sumMoneyAmount += [[record objectForKey:@"total_amount"] doubleValue];
    }
    
    NSString *sumMoney = [NSString stringWithFormat:@"¥%.2f",sumMoneyAmount];
    
    
    self.sumLabel.text = @"总计：";
    
    
    self.sumMoneyLabel.text = sumMoney;
    
    [self.view addSubview:self.sumLabel];
    [self.view addSubview:self.sumMoneyLabel];
    
    
}



@end
