//
//  LMTablePickerInputPlaceCell.h
//  HandMobileExp
//
//  Created by 吴笑诚 on 15/2/27.
//  Copyright (c) 2015年 hand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMTablePickerInputPlaceCell : UITableViewCell
//<UIKeyInput,UIPopoverControllerDelegate,UITextFieldDelegate> {
<UIPopoverControllerDelegate,UITextFieldDelegate> {
//<UITextFieldDelegate> {
    // For iPad
    UIPopoverController *popoverController;
    UIToolbar *inputAccessoryView;
}

@property (weak, nonatomic) IBOutlet UITextField *placeTextField;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeInputButton;
@property (nonatomic, strong) UIPickerView *picker;

- (IBAction)changeInputButtonPressed:(UIButton *)sender;

@end
