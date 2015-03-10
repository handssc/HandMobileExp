//
//  UItextFieldControl.m
//  HandMobileExp
//
//  Created by 吴笑诚 on 15/2/15.
//  Copyright (c) 2015年 hand. All rights reserved.
//

#import "UItextFieldControl.h"

@implementation UItextFieldControl

- (id) initWithRadixPointNum:(NSInteger)radixPointLength length:(NSInteger)numLength {
    if  (self = [super init]) {

        _RadixPointNum = radixPointLength;
        _decimalNumMax = numLength;
        
    }
    return self;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    self.isHasRadixPoint = YES;
    NSString *existText = textField.text;
    if ([existText rangeOfString:@"."].location == NSNotFound) {
        self.isHasRadixPoint = NO;
    }
    if (string.length > 0) {
        if (existText.length >= _decimalNumMax ) {

           // NSLog(@"existText:%@ ,%ld",existText,existText.length);
            return NO;
        }
        unichar newChar = [string characterAtIndex:0];
        if ((newChar >= '0' && newChar <= '9') || newChar == '.' ) {
            if (newChar == '.') {
                if (self.isHasRadixPoint || _RadixPointNum == 0)
                    return NO;
                else
                    return YES;
            }else {
                if (self.isHasRadixPoint) {
                    NSRange ran = [existText rangeOfString:@"."];
                    NSInteger radixPointCount = range.location - ran.location;
                    if (radixPointCount <= _RadixPointNum)
                        return YES;
                    else
                        return NO;
                } else
                    return YES;
            }
            
        }else {
            if ( newChar == '\n') return YES;       // 这句非常重要：不然将导致“Done”按钮失效
            return NO;
        }
        
    }else {
        return YES;
    }
}




@end
