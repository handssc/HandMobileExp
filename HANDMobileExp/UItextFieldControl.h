//
//  UItextFieldControl.h
//  HandMobileExp
//
//  Created by 吴笑诚 on 15/2/15.
//  Copyright (c) 2015年 hand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UItextFieldControl : NSObject <UITextFieldDelegate>

@property (nonatomic, assign) BOOL isHasRadixPoint;
@property (nonatomic, assign) NSInteger RadixPointNum;      // 小数位数量
@property (nonatomic, assign) NSInteger decimalNumMax;      // 最大数位长度 包括小数点
//@property (nonatomic, assign) double numberValue;

- (id) initWithRadixPointNum: (NSInteger)radixPointLength length: (NSInteger) numLength ;


@end
