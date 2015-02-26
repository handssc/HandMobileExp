//
//  LMTableTextInputCell.h
//  HandMobileExp
//
//  Created by jiangtiteng on 14-8-8.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UItextFieldControl.h"

@interface LMTableTextInputCell : UITableViewCell <UITextFieldDelegate>//<UIKeyInput, UITextInputTraits>


@property(nonatomic) UIKeyboardType keyboardType;

//@property(nonatomic,assign) double numberValue;
@property (nonatomic, assign) NSUInteger lowerLimit;
@property (nonatomic, assign) NSUInteger upperLimit;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *currency;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;          // 金额
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;          // 数量
@property UItextFieldControl *amountTextFieldControl;
@property UItextFieldControl *numberTextFieldControl;


@property (nonatomic,assign) double amountValue;        // 金额
@property (nonatomic,assign) double numberValue;        // 数量





- (IBAction) amountTextFieldDoneEditing:(id)sender;
- (IBAction) numberTextFieldDoneEditing:(id)sender;


@end
