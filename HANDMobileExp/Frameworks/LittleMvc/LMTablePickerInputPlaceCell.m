//
//  LMTablePickerInputPlaceCell.m
//  HandMobileExp
//
//  Created by 吴笑诚 on 15/2/27.
//  Copyright (c) 2015年 hand. All rights reserved.
//

#import "LMTablePickerInputPlaceCell.h"



@interface LMTablePickerInputPlaceCell()

@property (nonatomic, assign) BOOL canPlaceInput;
@end

@implementation LMTablePickerInputPlaceCell {
    
    
}

// 初始化pickView
- (void)initalizeInputView {
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.showsSelectionIndicator = NO;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.picker.frame = CGRectMake(0, 84, 320, 100);
    
    self.picker.showsSelectionIndicator = YES;
    
    _placeTextField.inputView = self.picker;    // 默认设置

    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nibArray = [[NSBundle mainBundle] loadNibNamed:@"LMTablePickerInputPlaceCell" owner:self options:nil ];
        self = [nibArray objectAtIndex:0];
        _placeTextField.delegate = self;
        _canPlaceInput = NO;
        self.modifiedFlag = NO;
    
        [self initalizeInputView];
    }
    return self;
}

///*

- (UIView *)inputView {
    
    NSLog(@"input View");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return nil;
    } else {
        return self.picker;

    }
}


///*
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

    //[self resignFirstResponder];
    [_placeTextField resignFirstResponder];
    self.modifiedFlag = YES;
}
/*
- (BOOL)becomeFirstResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize pickerSize = [self.picker sizeThatFits:CGSizeZero];
        CGRect frame = self.picker.frame;
        frame.size = pickerSize;
        self.picker.frame = frame;
        popoverController.popoverContentSize = pickerSize;
        [popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        // resign the current first responder
        for (UIView *subview in self.superview.subviews) {
            if ([subview isFirstResponder]) {
                [subview resignFirstResponder];
            }
        }
        return NO;
    } else {
        [self.picker setNeedsLayout];
    }
    return [super becomeFirstResponder];
}
*/
- (BOOL)resignFirstResponder {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    UITableView *tableView = (UITableView *)self.superview;
    //	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    return [super resignFirstResponder];
}


/*************
 ******* 设备旋转 未生效 del by wuxiaocheng
- (void)deviceDidRotate:(NSNotification*)notification {
    
    NSLog(@"deviceDidRotate");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // we should only get this call if the popover is visible
        [popoverController presentPopoverFromRect:self.detailTextLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.picker setNeedsLayout];
    }
}
 ***************/


#pragma mark -
#pragma mark Respond to touch and become first responder.

///*
- (BOOL)canBecomeFirstResponder {
    //return YES;
    return NO;
}
//*/

#pragma mark -
#pragma mark UIKeyInput Protocol Methods
/*
- (BOOL)hasText {
    return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}
*/
#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    //	UITableView *tableView = (UITableView *)self.superview;
    //	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    [self resignFirstResponder];
}



- (void)awakeFromNib {
    // Initialization code
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
       [self becomeFirstResponder];
    }
}
*/

#pragma mark Button
- (IBAction)changeInputButtonPressed:(UIButton *)sender {
    [_placeTextField resignFirstResponder];

    
    if (_canPlaceInput == NO) {
        //_placeTextField.enabled = YES;
        _canPlaceInput = YES;
        [_changeInputButton setTitle:@"选择" forState:UIControlStateNormal];
        _placeTextField.inputView = UIKeyboardTypeDefault;


    } else {
       // _placeTextField.enabled = NO;
        _canPlaceInput = NO;
        [_changeInputButton setTitle:@"输入" forState:UIControlStateNormal];
        _placeTextField.inputView = self.picker;

    }
    
    [_placeTextField becomeFirstResponder];

}


#pragma mark - TextField Delegate

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_placeTextField becomeFirstResponder];
    
    ///*

    CGRect frame = _placeTextField.frame;
    //int offset = frame.origin.y + 32 - (self.contentView.frame.size.height - 216.0);//键盘高度216
    
    int offset = frame.origin.y + 32 - (self.contentView.frame.size.height - 116.0);//键盘高度216

    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.superview.frame = CGRectMake(0.0f, -offset, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[_placeTextField resignFirstResponder];
    [textField resignFirstResponder];

    return YES;
}



///*
//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
   // NSLog(@"test");
   // [_placeTextField resignFirstResponder];
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    self.superview.frame =CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    [UIView commitAnimations];

}
 //*/
@end
