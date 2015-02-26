//
//  EXPLineModelViewController.m
//  HandMobileExp
//
//  Created by jiangtiteng on 14-7-8.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import "EXPLineModelDetailViewController.h"
#import "EXPLineDetailModel.h"
#import "EXPLineDetailHtppModel.h"
#import "EXPLocationAPI.h"
#import "EXPLocationManager.h"
#import "MMProgressHUDWindow.H"
#import "LMTableTextInputCell.h"
#import "LMTableDateFromToCell.h"
#import "LMRateFieldCell.h"


#define eps 1e-8

@interface EXPLineModelDetailViewController (){
    

    //model
    EXPLineDetailModel * model;
    EXPLineDetailHtppModel * httpmdel;
    
    //cell 表单元
    LMTableDateFromToCell *dateCell;                // 日期
    
    LMTableAmountInputCell *amountCell;             // 金额
    LMTablePickerInputCell *expenseTypeCell;        // 费用类型
    LMTablePickerInputCell *placeCell;              // 地点
    LMTableTextInputCell *numberCell;               // 数量
    
    LMRateFieldCell  * rateCell;                    // 费率
    
    NSMutableArray * imgArray;
    
    NSDictionary * record;
    
    
    EXPExpenseTypePicker * ExpenseTypePicker;
    EXPLocationPicker  *  LocationPicker;
    
    
    BOOL  completeFlag;
}

@end

@implementation EXPLineModelDetailViewController
@synthesize insertFlag;
@synthesize updateFlag;
@synthesize readOnlyFlag;

static NSString *simpleTableIdentifier = @"LMTableDateInputCell";

static NSUInteger MAX_SIZE_JPG = 307200;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //初始代理
        LocationPicker = [[EXPLocationPicker alloc] init];
        LocationPicker.provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
        LocationPicker.citys =[[LocationPicker.provinces objectAtIndex:0] objectForKey:@"Cities"];
        
        NSArray * expense_classes =  [[NSUserDefaults standardUserDefaults] valueForKey:@"expense_classes"];
        ExpenseTypePicker = [[EXPExpenseTypePicker alloc] init];
        ExpenseTypePicker.expense_classes =expense_classes;

 
        updateFlag = NO;
        insertFlag = YES;

        completeFlag = NO;
        readOnlyFlag = NO;
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    
    //初始化tableview
    [super viewDidLoad];
    
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    
    
    // Navigation
    [self createUI_Navigation];

    // 常规表项
    [self createUI_TableCommon];
    
    // 备注
    [self createUI_TableRemarks];
    
    // 按键
    [self createUI_Button];
    
    
    //初始化model
    model = [[EXPLineDetailModel alloc] init];
    [model.delegates addObject:self];
    httpmdel = [[EXPLineDetailHtppModel alloc] init];
    [httpmdel.delegates addObject:self];
    

    
    //如果是老数据则显示
    if(!insertFlag && updateFlag){
        [self showUpload];
        [self reload];
    }
    
    if (readOnlyFlag) {
        
        self.upload.hidden = YES;
        self.save.hidden = YES;
        
        UIImageView *submitView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submitted"]];
        submitView.frame = CGRectMake(60.0, self.view.bounds.size.height*0.6, self.view.bounds.size.width - 120.0, 100.0);
        [self.view addSubview:submitView];
        
        [self.view addSubview:self.coverView];
    }
    
    //init tableview cell
    [self buildCellView];
    //[self initCellView:true];
    [self initCellView:YES];
    
}

#pragma mark - 
#pragma mark UI Create


// Navigation
- (void) createUI_Navigation {
    //   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"报销单创建" style:UIBarButtonSystemItemDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    
    self.navigationItem.title = @"记一单";
}

// 常规表项
- (void) createUI_TableCommon {
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tv.dataSource = self;
    self.tv.delegate = self;
    
    self.tv.tableFooterView = [[UIView alloc]init];
    
    //    self.view.backgroundColor = [UIColor colorWithRed:0.876 green:0.874 blue:0.760 alpha:1.000];
    self.tv.scrollEnabled = NO;
    
    //    self.tv.backgroundColor = [UIColor colorWithRed:0.876 green:0.874 blue:0.760 alpha:0.310];
    self.tv.backgroundView.backgroundColor = nil;
    
    /******************************************
     ****** delete by wuxiaocheng @ 1/30 for 多余代码
     
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    
    ***************************/
    [self.view addSubview:self.tv];
}

// remarks
- (void) createUI_TableRemarks {
    //    UIView * div2 =[UIView new];
    //    div2.frame = CGRectMake(self.view.frame.size.width/2-10 , 80 ,
    //                              1.0f, 40.0f);
    //    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    //    [self.view addSubview:div2];
    
    UILabel * lb3 = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-10, 263.0f, 30, 30)];
    lb3.text = @"备注";
    lb3.font =   [lb3.font fontWithSize:22];
    //    lb3.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
    lb3.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:lb3];
    
    self.descTx = [[UITextView alloc] initWithFrame:CGRectMake(8.0, 293, self.view.bounds.size.width-16.0, (self.view.bounds.size.height-240)*0.25)];
    self.descTx.delegate = self;
    self.descTx.layer.borderColor =  [UIColor grayColor].CGColor;
    
    self.descTx.layer.borderWidth = 1.0;
    //    self.descTx.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.843 alpha:1.000];
    [self.view addSubview:self.descTx];
    
    self.descTx.tag = 1;
}

// 按键
- (void) createUI_Button {
    //添加按键
    self.save = [[UIButton alloc] initWithFrame:CGRectMake(8, self.descTx.frame.origin.y+self.descTx.frame.size.height+15, 320-16, (self.view.bounds.size.height-240)*0.15)];
    
    [self.save setTitle:@"保存" forState: UIControlStateNormal];
    [self.save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchDown];
    [self.save setBackgroundColor:[UIColor colorWithRed:241.0f/255.0f green:147.0f/255.0f blue:31.0f/255.0f alpha:0.780]];
    [self.save.layer setCornerRadius:6.0f];
    self.save.showsTouchWhenHighlighted = YES;
    
    [self.view addSubview:self.save];
    
}




#pragma mark - private
-(UIView *)coverView
{
    self.coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    return _coverView;
}

-(void)reload{
    NSDictionary * param = @{@"id" : self.keyId};
    [model load:0 param:param];
}


-(void)back{
    if(self.detailList != nil){
        [self.detailList reload];
    }
    
    if (self.tableView != nil) {
        [self.tableView reloadData];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


// 已上传后

-(void) showUpload{
    
    self.upload = [[UIButton alloc] initWithFrame:CGRectMake((self.save.bounds.size.width/2)+10, self.save.frame.origin.y, self.save.bounds.size.width/2, self.save.bounds.size.height)];

    [self.save setTitle:@"保存" forState: UIControlStateNormal];
    self.save.backgroundColor  = [UIColor colorWithRed:113.0f/255 green:113.0f/255  blue:113.0f/255  alpha:0.780];
    
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:0.5f];
    self.save.frame = CGRectMake(self.save.frame.origin.x,self.save.frame.origin.y, self.save.bounds.size.width/2, self.save.bounds.size.height);
    
    
    [UIView commitAnimations];
    

    
    [self.upload.layer setCornerRadius:6.0f];
    [self.upload setTitle:@" 再记一笔" forState:UIControlStateNormal];
//    [self.upload setTitle:@"提交数据" forState:UIControlStateNormal];
    [self.upload setBackgroundColor:[UIColor colorWithRed:241.0f/255.0f green:147.0f/255.0f blue:31.0f/255.0f alpha:0.780]];
//    [self.upload addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchDown];
    [self.upload addTarget:self action:@selector(readd:) forControlEvents:UIControlEventTouchDown];
    self.upload.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.upload];
    
    //self.save.showsTouchWhenHighlighted  = NO;
}

// 修改后，改变保存按钮颜色
- (void)showModified {
    [self.save setBackgroundColor:[UIColor colorWithRed:241.0f/255.0f green:147.0f/255.0f blue:31.0f/255.0f alpha:0.780]];
}

#pragma mark CheckData
//对数据进行校验
- (BOOL)checkDataVaild{
    //检查金额

    //NSLog(@"eps %.10f", eps);
    if( fabs(numberCell.amountValue-0) < eps || numberCell.numberValue == 0 || fabs(rateCell.numberValue-0) < eps ){
    
        [LMAlertViewTool showAlertView:@"提示" message:@"请输入正确金额" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        return NO;
    }
    
    return YES;
    
}


#pragma mark - btn delegate
-(void)readd:(UIButton *)parmSender{
    
    EXPLineModelDetailViewController *detailViewController = [[EXPLineModelDetailViewController alloc]initWithNibName:nil bundle:nil];
    detailViewController.detailList = self.detailList;
    
    [self.detailList.navigationController popViewControllerAnimated:NO];
    
    [self.detailList.navigationController pushViewController:detailViewController animated:NO];
    
}

-(void)save:(UIButton *)paramSender{


    
    if(![self checkDataVaild]){
        return;
    }
    
    //获取数据
    NSNumber * expense_class_id = ExpenseTypePicker.expense_class_id;
    NSString * expense_class_desc = ExpenseTypePicker.expense_class_desc;
    
    NSNumber * expense_type_id =  ExpenseTypePicker.expense_type_id;
    NSString * expense_type_desc = ExpenseTypePicker.expense_type_desc;
    
    NSNumber * expense_amount = [NSNumber numberWithDouble:   [[NSString stringWithFormat:@"%.2f",numberCell.amountValue] doubleValue]];
    NSNumber * expense_number = [NSNumber numberWithInteger:numberCell.numberValue];

    
 
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *expense_date = [NSString stringWithFormat:@"%@", [formatter stringFromDate:dateCell.dateFromValue]];
    NSString *expense_date_to = [NSString stringWithFormat:@"%@", [formatter stringFromDate:dateCell.dateToValue]];
    
    NSString * expense_place = [[LocationPicker.province_desc stringByAppendingString:@">"] stringByAppendingString:LocationPicker.city_desc];
    
    NSString * description = self.descTx.text;

    NSString * local_status = @"new";
    NSString * CREATION_DATE =[formatter stringFromDate:[NSDate date]];
    
    NSString * CREATED_BY = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    

    ///汇率 币种
    NSString * currency = rateCell.currencyLabel.text;
    
    NSNumber * exchangeRate =    [NSNumber numberWithDouble:   [[NSString stringWithFormat:@"%.4f",rateCell.numberValue] doubleValue]];
    
    // 总额计算
    double  _total_amount = [expense_amount doubleValue] * [expense_number integerValue] * [exchangeRate doubleValue];
    
    //NSLog(@"total save %f, %ld, %f", [expense_amount doubleValue], (long)[expense_number integerValue], [exchangeRate doubleValue]);
    
    NSNumber * total_amount = [NSNumber numberWithDouble:_total_amount];
    //判断是否有照片，没有照片则插入nil
//    if([amountCell.img image] !=nil){
//        data = UIImageJPEGRepresentation(  [amountCell.img image],0.1);
//        NSLog(@"%d",data.length);
//    
//    }else{
//        
//        data = nil;
//    }
    NSMutableDictionary * formdata = [[NSMutableDictionary alloc] init];


    
    
    [formdata setValue:expense_class_id forKey:@"expense_class_id"];
    [formdata setValue:expense_class_desc forKey:@"expense_class_desc"];
    [formdata setValue:expense_type_id forKey:@"expense_type_id"];
    [formdata setValue:expense_type_desc forKey:@"expense_type_desc"];
    [formdata setValue:expense_amount forKey:@"expense_amount"];
    [formdata setValue:expense_number forKey:@"expense_number"];
    [formdata setValue:total_amount forKey:@"total_amount"];
    [formdata setValue:expense_date forKey:@"expense_date"];
    [formdata setValue:expense_date_to forKey:@"expense_date_to"];
    [formdata setValue:expense_place forKey:@"expense_place"];
    [formdata setValue:description forKey:@"description"];
    [formdata setValue:local_status forKey:@"local_status"];
    [formdata setValue:CREATION_DATE forKey:@"CREATION_DATE"];
    [formdata setValue:CREATED_BY forKey:@"CREATED_BY"];
    
    [formdata setValue:currency forKey:@"currency"];
    [formdata setValue:exchangeRate forKey:@"exchangeRate"];
    

    for(int i =0;i< imgArray.count;i++){
        NSString * itemkey = @"item";
        itemkey = [itemkey  stringByAppendingFormat:@"%d",i+1];
        
        MWPhoto * photo =[imgArray objectAtIndex:i];
        

        
        if(photo !=nil){
       
            
            [formdata setValue:photo.data forKey:itemkey];
            
        }else {
            
            [formdata setValue:@"" forKey:itemkey];
        }
        
    }
    
    
    for(int i = imgArray.count;i< 9;i++){
        
        NSString * itemkey = @"item";
        itemkey = [itemkey  stringByAppendingFormat:@"%d",i+1];
        [formdata setValue:@"" forKey:itemkey];
    }
    
//    if(data != nil){
//        [formdata setValue: data forKey:@"item1"];
//    }else{
//        //不能直接存放nil，那样会报错
//        [formdata setValue: @"" forKey:@"item1"];
//    }
    
    NSArray * recordlist =@[formdata];

    if(insertFlag && !updateFlag){
        [model save:recordlist];
    }else if(!insertFlag && updateFlag && !completeFlag){
        [formdata setValue:self.keyId forKey:@"id"];
        [model update:recordlist];
    }else if(completeFlag){
        [formdata setValue:self.keyId forKey:@"id"];
        [formdata setValue:@"upload" forKey:@"local_status"];
        [model update:recordlist];

    }
    
    [LMAlertViewTool showAlertView:@"提示" message:@"保存成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
}


//
//-(void)upload:(UIButton *)paramSender{
//    
//
//
//
//
//    if(![self checkDataVaild]){
//        return;
//    }
//    //提交之前先保存
//    [self save:nil];
//    
//    
//    NSNumber * expense_amount = [NSNumber numberWithInteger:amountCell.numberValue];
//    NSNumber * expense_number = [NSNumber numberWithInteger:numberCell.numberValue];
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"YYYY-MM-dd"];
//    
//    NSString *expense_date = [formatter stringFromDate:dateCell.dateValue];
//    NSString *expense_date_to = [formatter stringFromDate:datetoCell.dateValue];
//    
//    NSString * expense_place = [[LocationPicker.province_desc stringByAppendingString:@">"] stringByAppendingString:LocationPicker.city_desc];
//    
//    NSString * description = self.descTx.text;
//    
//    NSNumber * expense_class_id = ExpenseTypePicker.expense_class_id;
//    
//    NSNumber * expense_type_id =  ExpenseTypePicker.expense_type_id;
//    
// 
//    NSDictionary * param = @{
//                              @"expense_amount" : expense_amount,
//                              @"expense_number" : expense_number,
//                              @"expense_place" :expense_place,
//                              @"expense_class_id" : expense_class_id,
//                              @"expense_type_id"    : expense_type_id ,
//                              @"expense_date"    : expense_date,
//                              @"expense_date_to" : expense_date_to,
//                              @"description" : description,
//                              @"local_id" : self.keyId
//                              };
//
//    
//    NSData *data = UIImageJPEGRepresentation(  [amountCell.img image],0.1);
//    
//    if(data !=nil){
//        [httpmdel upload:param fileName:@"upload.jpg" data:data];
//    }else{
//        
//        [httpmdel upload:param];
//    }
//    
//    
//}


-(int)getArrayIndex:(int )keyId
           class_index:(int) index
                   type:(NSString *)type
{
    if([type isEqualToString:@"expense_class_id"]){
        NSArray * classes =      ExpenseTypePicker.expense_classes;
        
        for(int i =0;i<classes.count;i++){
            NSDictionary * temp = [classes objectAtIndex:i];
            NSNumber * class_id  = [temp valueForKey:@"expense_class_id"];

            if(keyId == [class_id integerValue]){
                return  i;
            }
            
        }
    }else if ([type isEqualToString:@"expense_type_id"]){
        
        NSArray * classes =      ExpenseTypePicker.expense_classes;
        NSDictionary * temp = [classes objectAtIndex:index];
        NSArray * types = [temp valueForKey:@"expense_types"];
        for(int i =0;i<types.count;i++){
            NSDictionary * temp = [types objectAtIndex:i];
            NSNumber * type_id  = [temp valueForKey:@"expense_type_id"];
            
            if(keyId == [type_id integerValue]){
                return  i;
            }
            
        }
        
    }
    return 0;
}



#pragma mark -
#pragma mark buildCellView

- (void) buildCellView
{
    
        // 金额
        if (amountCell == nil)
        {
            amountCell = [[LMTableAmountInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTableAmountInputCell"];
            amountCell.tv = self;
            amountCell.selectionStyle = UITableViewCellSelectionStyleNone;
            imgArray = amountCell.imageArray;
        }
        
        // 费用类型
        if (expenseTypeCell == nil)
        {
            expenseTypeCell = [[LMTablePickerInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTablePickerInputCell"];
            
            expenseTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        ExpenseTypePicker.cell = expenseTypeCell;
        
        expenseTypeCell.picker.delegate = ExpenseTypePicker;
        expenseTypeCell.picker.dataSource = ExpenseTypePicker;
        
        
        expenseTypeCell.textLabel.text = @"费用";
    
    
        // 日期
        if (dateCell == nil)
        {
            dateCell = [[LMTableDateFromToCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTableDateFromToCell"];
            dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dateCell.parent = self;
        }

        
        // 地点
        if (placeCell == nil)
        {
            placeCell = [[LMTablePickerInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTablePickerInputCell"];
            placeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        LocationPicker.cell =placeCell;
        placeCell.picker.delegate =LocationPicker;
        placeCell.picker.dataSource = LocationPicker;
        
    
        // 数量
        if(numberCell == nil)
        {
         
            numberCell = [[LMTableTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTableTextInputCell"];
            numberCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        }
 
    
        // 汇率
        if(rateCell  == nil)
        {
            rateCell = [[LMRateFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMRateFieldCell"];
            rateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            rateCell.parent = self;
            
        }
    
    
        // 增加 观察依赖关系 总额 依赖于 金额 数量 汇率
        [numberCell addObserver:self forKeyPath:@"numberValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        //[amountCell addObserver:self forKeyPath:@"numberValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [numberCell addObserver:self forKeyPath:@"amountValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
  
        [rateCell addObserver:self forKeyPath:@"numberValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    

}


-(void)initCellView:(BOOL)animatedFlag{
    //赋值
    if(record != nil && !insertFlag && updateFlag){
        //金额
        NSNumber * expense_amount = [record valueForKey:@"expense_amount"];
        
        //amountCell.amount.text = [NSString  stringWithFormat:@"%.2f",[expense_amount doubleValue]];
        numberCell.amountTextField.text = [NSString  stringWithFormat:@"%.2f",[expense_amount doubleValue]];

        //amountCell.currency.text = [record valueForKey:@"currency"];
        numberCell.currency.text = [[record valueForKey:@"currency"] substringWithRange:NSMakeRange(0, 3)];

        //NSNumber * amount = [record valueForKey:@"expense_amount"];
        
        numberCell.amountValue =[expense_amount doubleValue];
        
        //数量
        
         NSNumber * expense_number = [record valueForKey:@"expense_number"];
        numberCell.numberValue = [expense_number integerValue];
        numberCell.numberTextField.text = [NSString stringWithFormat:@"%@",expense_number];
        
        
        //初始化汇率 币种
        NSNumber * exchangeRate = [record valueForKey:@"exchangeRate"];
        rateCell.exchangRateLabel.text = [NSString  stringWithFormat:@"%.4f",[exchangeRate doubleValue]];
        rateCell.numberValue = [exchangeRate doubleValue];
        rateCell.currencyLabel.text = [record valueForKey:@"currency"];
        
        
        //初始化费用类型
        NSNumber * class_id = [record valueForKey:@"expense_class_id"];
        NSNumber * type_id  =  [record valueForKey:@"expense_type_id"];
        
        int classArrId= [self getArrayIndex:[class_id integerValue] class_index:nil type:@"expense_class_id"];
        int typeArrId = [self getArrayIndex:[type_id integerValue]  class_index:classArrId type:@"expense_type_id"];
        
        [expenseTypeCell.picker selectRow:classArrId inComponent:0 animated:YES];
        [expenseTypeCell.picker selectRow:typeArrId inComponent:1 animated:YES];
        
        [ExpenseTypePicker pickerView:expenseTypeCell.picker didSelectRow:classArrId inComponent:0];
        [ExpenseTypePicker pickerView:expenseTypeCell.picker didSelectRow:typeArrId inComponent:1];

        
        [ expenseTypeCell.picker reloadComponent:0];
        [ expenseTypeCell.picker reloadComponent:1];
        //初始化地址
        NSArray *locationInfo = [[record valueForKey:@"expense_place"] componentsSeparatedByString:@">"];
        LocationPicker.province_desc = [locationInfo objectAtIndex:0];
        LocationPicker.city_desc = [locationInfo objectAtIndex:1];
        placeCell.detailTextLabel.text = [record valueForKey:@"expense_place"];
        
        //初始化日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"YYYY-MM-dd"];
        
        NSDate *expense_date =[formatter dateFromString:[record valueForKey:@"expense_date"]];
        dateCell.dateFromValue  =expense_date;
        
        dateCell.dateToValue =[formatter dateFromString:[record valueForKey:@"expense_date_to"]];
        
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.dateStyle = NSDateFormatterMediumStyle;
        
        dateCell.dateFrom.text = [formatter stringFromDate:dateCell.dateFromValue];
        dateCell.dateTo.text = [formatter stringFromDate:dateCell.dateToValue];
        
        

        
        //初始化描述
        
        self.descTx.text =[record valueForKey:@"description"];
        
        
        //初始化相片
        if([record valueForKey:@"item1"] !=nil){
  
            [amountCell.img setImage:[UIImage imageWithData:[record valueForKey:@"item1"]]];
             }
        
        
        for(int i = 0;i< 9;i++){
            NSString * keyItem = @"item";
            keyItem = [keyItem stringByAppendingFormat:@"%d",i+1];
            NSData * data = [record valueForKey:keyItem];
            if(data !=nil){
            
                if(data.length !=0){
                
                    UIImage * image = [UIImage imageWithData:[record valueForKey:keyItem]];
                
                    MWPhoto *     photo = [MWPhoto photoWithImage:image];
                    photo.data = data;
                
                    [amountCell.imageArray addObject:photo];
                }
            
            }
        }
        
    
    }else {
        
        
  
        [ExpenseTypePicker pickerView:expenseTypeCell.picker didSelectRow:0 inComponent:0];
        [ExpenseTypePicker pickerView:expenseTypeCell.picker didSelectRow:0 inComponent:1];
        

        
    
 
        NSString *province = [EXPLocationAPI shareInstance].province;
        NSString *city = [EXPLocationAPI shareInstance].city;
        
        if(![province  isEqualToString:@""] && ![city isEqualToString:@""] && city !=nil  && province !=nil){
            

            LocationPicker.province_desc = province;
            LocationPicker.city_desc = city;
            
            NSString *location = [NSString stringWithFormat:@"%@>%@",province,city];
            placeCell.detailTextLabel.text = location;
            placeCell.textLabel.text = @"地点";

        }else{
            
            [LocationPicker pickerView:placeCell.picker didSelectRow:0 inComponent:0];
            [LocationPicker pickerView:placeCell.picker didSelectRow:0 inComponent:1];
            
        }

    }
    
}

/**  汇率返回时候修改汇率 */
-(void) reloadRateCell:(NSString *)currency
          exchangeRate:(NSNumber *  )exchangRate
{
    //初始化汇率 币种
    rateCell.exchangRateLabel.text = [NSString  stringWithFormat:@"%.4f",[exchangRate doubleValue]];
    rateCell.numberValue = [exchangRate doubleValue];
    rateCell.currencyLabel.text = currency;
    numberCell.currency.text = [NSString stringWithFormat:@"%@", [currency substringWithRange:NSMakeRange(0, 3)]];
    
    NSLog(@"修改币种 %@, %@", currency, amountCell.currency.text);
}

#pragma mark － key-valuedelegate
//auto modify the total amount
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
   // NSLog(@"amountCell is %@", keyPath);

    if([keyPath isEqualToString:@"numberValue"] || [keyPath isEqualToString:@"amountValue"])
    {

        ///**
        if(numberCell.numberValue !=0 && numberCell.amountValue !=0 && rateCell.numberValue != 0){
            
           // NSLog(@"amountCell is %f",amountCell.numberValue);
            //double total = numberCell.numberValue * amountCell.numberValue * rateCell.numberValue;
            //numberCell.totalLabel.text= [numberCell.numberFormatter stringFromNumber:[NSNumber numberWithDouble:total]];
            double total = numberCell.numberValue * numberCell.amountValue * rateCell.numberValue;

            amountCell.amount.text= [amountCell.numberFormatter stringFromNumber:[NSNumber numberWithDouble:total]];

        }else{
            //numberCell.totalLabel.text = @"0";
            amountCell.amount.text = @"0";
        }
        //*/
        //amountCell.amount.text
    }
    
    

}

#pragma tableview datasource
- (void)tableViewCell:(LMTableDateInputCell *)cell didEndEditingWithDate:(NSDate *)value
{
	NSLog(@"%@ date changed to: %@", cell.textLabel.text, value);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LMTableDateInputCell";
    
    
    if(indexPath.section ==0){

        if (amountCell == nil)
        {
            amountCell = [[LMTableAmountInputCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTableAmountInputCell"];
            amountCell.tv = self;
            amountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        return amountCell;
    }else if(indexPath.section == 3){

        if (expenseTypeCell == nil)
        {
            expenseTypeCell = [[LMTablePickerInputCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTablePickerInputCell"];
            
            expenseTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            ExpenseTypePicker.cell =expenseTypeCell;
            
            expenseTypeCell.picker.delegate = ExpenseTypePicker;
            expenseTypeCell.picker.dataSource = ExpenseTypePicker;
            
            
            expenseTypeCell.textLabel.text = @"费用";
        }



        return expenseTypeCell;
        
    }else if(indexPath.section == 5){

        
        return dateCell;
        
    }else if(indexPath.section == 4){

        if (placeCell == nil)
        {
            placeCell = [[LMTablePickerInputCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LMTablePickerInputCell"];
            placeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            LocationPicker.cell =placeCell;
            placeCell.picker.delegate =LocationPicker;
            placeCell.picker.dataSource = LocationPicker;
            
        }

        
        
    
        return placeCell;
    }else if(indexPath.section == 1){
        
      
        return numberCell;
    }else if(indexPath.section == 2){
        
        return rateCell;
    }
    


 
    
    return  nil;
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 6;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 72;
            break;
        case 1:
            return 40;
        case 2:
            return 40;
        case 3:
            return 40;
        default:
            return 40;
            break;
    }
    
}



#pragma  modeldelegate
-(void)modelDidStartLoad:(id<TTModel>)pmodel{
        NSString * className = [NSString stringWithUTF8String:object_getClassName(pmodel)];
    
        if ([className isEqualToString:@"EXPLineDetailHtppModel"]){
            MMProgressHUD.presentationStyle =MMProgressHUDPresentationStyleDrop;
            [MMProgressHUD showWithTitle:nil status:@"正在处理"];
        }
}

-(void)modelDidFinishLoad:(id<TTModel>)pmodel{
    NSString * className = [NSString stringWithUTF8String:object_getClassName(pmodel)];

    if([className isEqualToString:@"EXPLineDetailModel"]){
        EXPLineDetailModel * _pmodel = pmodel;
        
        if([_pmodel.method isEqualToString:@"insert"]){
            
            [self showUpload];
            

            insertFlag = NO;
            updateFlag = YES;
            self.keyId =  [_pmodel getPrimaryKey:@"MOBILE_EXP_REPORT_LINE"];
            
            
        }else if([_pmodel.method isEqualToString:@"update"]){
            
            
            
        }else if ([_pmodel.method isEqualToString:@"query"]){
            
            record = [_pmodel.result objectAtIndex:0];

            
        }
        
    }else if ([className isEqualToString:@"EXPLineDetailHtppModel"]){
        
        
        EXPLineDetailHtppModel *_pmodel = pmodel;
        
        NSDictionary * head = [_pmodel.Json valueForKey:@"head"];

        
        NSString * result = [head valueForKey:@"code"];
        

   
        if([result isEqualToString:@"success"]){
                completeFlag = true;
                [self  save:nil];
                MMProgressHUD.presentationStyle =MMProgressHUDPresentationStyleNone;
                [MMProgressHUD dismiss];
                [self back];
                

            
        }else if([result isEqualToString:@"faild"]){
            [MMProgressHUD dismiss];
            [LMAlertViewTool showAlertView:@"提示" message:@"请求失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
        }

        
    }
}
-(void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error{
    //处理超时异常

        [MMProgressHUD dismiss];
        [LMAlertViewTool showAlertView:@"提示" message:@"网络出现问题，请检查网络后重新提交" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
    
}

#pragma keyboradDelegate

- (UIView *)inputAccessoryView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		if (!inputAccessoryView) {
			inputAccessoryView = [[UIToolbar alloc] init];
			inputAccessoryView.barStyle = UIBarStyleDefault;
			inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[inputAccessoryView sizeToFit];
			CGRect frame = inputAccessoryView.frame;
			frame.size.height = 44.0f;
			inputAccessoryView.frame = frame;
			
			UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
			UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			
			NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
			[inputAccessoryView setItems:array];
		}
		return inputAccessoryView;
	}
}

- (void)done:(id)sender {
    CGFloat y;
     if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
          y = 64;
     }else{
         
          y = 0;
     }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    
    self.view.frame =CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
	[self resignFirstResponder];
}

- (BOOL)resignFirstResponder {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

	return [super resignFirstResponder];
}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    CGRect frame = textView.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 150.0)+100;//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    
    if(offset > 0 )
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);

    [UIView commitAnimations];
    
    
}



//输入框编辑完成以后，将视图恢复到原始状态
- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGFloat y;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0) {
        y = 64;
    }else{
        
        y = 0;
    }
    self.view.frame =CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
