//
//  EXPDetailViewController.h
//  HandMobileExp
//
//  Created by Tracy－jun on 14-7-10.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMTableViewController.h"
#import "EXPSubmitDelegate.h"

@interface EXPSubmitDetailViewController : LMTableViewController{
    
   
}

//@property (weak, nonatomic) IBOutlet UITableView *tableView;

//* del by wuxiaocheng
@property (strong, nonatomic) IBOutlet UILabel *sumLabel;
@property (strong, nonatomic) IBOutlet UILabel *sumMoneyLabel;

@property (strong, nonatomic)  UIButton *selectAllButton;
@property (strong, nonatomic)  UIButton *cancelSelectAllButton;
@property (strong, nonatomic)  UIButton *selectPageButton;
@property (strong, nonatomic)  UIButton *cancelSelectPageButton;

 
//*/

@end
