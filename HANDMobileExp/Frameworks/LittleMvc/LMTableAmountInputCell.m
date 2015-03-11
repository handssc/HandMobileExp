    //
//  LMTableAmountInput.m
//  HandMobileExp
//
//  Created by jiangtiteng on 14-7-9.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import "LMTableAmountInputCell.h"
#import "ImagePickerActionSheet.h"
#import  "MWPhoto.h"


#define AMOUNT_DECIMAL_LENGTH_MAX 2


@implementation LMTableAmountInputCell{
    
    
}

@synthesize numberValue;
@synthesize numberFormatter;
@synthesize delegate;
@synthesize lowerLimit;
@synthesize upperLimit;

@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardAppearance;
@synthesize keyboardType;
@synthesize returnKeyType;
@synthesize secureTextEntry;
@synthesize spellCheckingType;
@synthesize imageArray = _imageArray;

- (void)initalizeInputView {
	// Initialization code
	self.keyboardType = UIKeyboardTypeDecimalPad;
	self.lowerLimit = 0;//最小为0
	self.upperLimit = 1000000000; //最大允许9位
    self.modifiedFlag = NO;
	
    dotBeginFlag = NO;
    firstInput = YES;
    endFlag = NO;
    dotnumber = AMOUNT_DECIMAL_LENGTH_MAX;
    
	if (!self.numberFormatter) {
		self.numberFormatter = [[NSNumberFormatter alloc] init];
		self.numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
		self.numberFormatter.maximumFractionDigits = AMOUNT_DECIMAL_LENGTH_MAX;
	}
	
	self.detailTextLabel.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:numberValue]];
    
    _imageArray = [[NSMutableArray alloc] init];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nibArray = [[NSBundle mainBundle] loadNibNamed:@"LMTableAmountInputCell" owner:self options:nil ];
        self = [nibArray objectAtIndex:0];
        [self initalizeInputView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress)];
        self.img.userInteractionEnabled = YES;
        [self.img addGestureRecognizer:singleTap];
        
        self.readOnlyFlag = NO;
        
        
    }
    return self;
}

#pragma img press delegate
-(void)buttonpress{
    self.modifiedFlag = YES;
    //当显示照片没有的情况下，是拍照
    if(self.img.image == nil){

        if (self.readOnlyFlag == NO) {
            imagesheet = [[ImagePickerActionSheet alloc] initWithView:self.tv delegate:self];
            
            
            
            _photowrapper = [[MWPhotoBrowserWraper alloc] initWithViewController:self.tv delegate:self readOnly:self.readOnlyFlag];
            
            
            [imagesheet showActionSheet];
        }

        
        
        
    }else {
        //每次都进行初始化，因为该组建无法复用
        _photowrapper = [[MWPhotoBrowserWraper alloc] initWithViewController:self.tv delegate:self readOnly:self.readOnlyFlag];
        
        [_photowrapper showWithPush];
        
        
        
    }
    
}

/////////////////IPickerActionSheetDelegate///////
-(void)image:(UIImage *)image data:(NSData *)data didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.img setImage:image];
    
     MWPhoto *     photo = [MWPhoto photoWithImage:image];
    photo.data = data;
    
    
    [_imageArray addObject:photo];
    
    [_photowrapper showWithPush];
    
}


-(void)DidCancel{
    
    
    
}


- (void) setPhotoReadOnly {
    NSLog(@"setPhotoReadOnly");
    self.readOnlyFlag = YES;
}

///////////////MWPhotoBrowserDelegate/////////////////
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _imageArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _imageArray.count)
        return [_imageArray objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _imageArray.count)
        return [_imageArray objectAtIndex:index];
    return nil;
}

-(void)addPicPhoto:(MWPhoto *)photo{
    
    [_imageArray addObject:photo];
    
}

-(void)delPicPhoto:(NSUInteger )number{
    [_imageArray removeObjectAtIndex:number];
    
    
    if(_imageArray.count == 0){
        
        [self.img setImage:nil];
    }else{
        MWPhoto * img = [_imageArray objectAtIndex:0];
        [self.img setImage:img.image];
        
    }
    
}





#pragma  mark cell select
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

    
    [super setSelected:selected animated:animated];
	
    if (selected) {
        firstInput = YES;
        dotBeginFlag = NO;
        endFlag= NO;
        dotnumber=AMOUNT_DECIMAL_LENGTH_MAX;
        [self becomeFirstResponder];
         
	}
}

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
	[self resignFirstResponder];
}


/*
#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark UIKeyInput Protocol Methods

- (BOOL)hasText {
	return (self.numberValue > 10);
}


- (void)insertText:(NSString *)theText {
	
	// make sure we receioved an integer (on the iPad a user chan change the keybord style)
	NSScanner *sc = [NSScanner scannerWithString:theText];
	if ([sc scanDecimal:NULL]) {
		if ([sc isAtEnd]) {
            NSLog(@"%@, %f",theText, self.numberValue);
            
            if(firstInput){
                firstInput = NO;
                self.numberValue = 0.0f;
            }
            
            // 开始小数部分输入
            if([theText isEqualToString:@"."] ){
                
                dotBeginFlag = YES;
                return;
            }
            
            //如果开始输入小数，且没有结束
            if(dotBeginFlag && !endFlag && dotnumber !=0){
                NSUInteger addedValues = [theText integerValue];
                dotnumber--;
                self.numberValue += addedValues * powf(0.1,  (AMOUNT_DECIMAL_LENGTH_MAX-dotnumber));
                
                self.amount.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble: self.numberValue]];
                if(dotnumber ==0){
                    endFlag = YES;
                }
                return;
            }
            
            // 小数为输入完成后 不允许继续输入
            if(endFlag ){
                return;
            }

            
			NSUInteger addedValues = [theText integerValue];
            if(  upperLimit <=  self.numberValue *(10*theText.length)){
                
                return;
            }
            
            //NSLog(@"length %lu", (unsigned long)theText.length);
			self.numberValue *= (10 * theText.length);
           // NSLog(@"%f, %lu", self.numberValue+6, (unsigned long)addedValues );

			self.numberValue += addedValues;
            //NSLog(@"%f",  66666660.000000+6);

			if (self.numberValue < self.lowerLimit) {
				self.numberValue = self.lowerLimit;
			} else if (self.numberValue > self.upperLimit) {
				self.numberValue = self.upperLimit;
			}
            
			self.amount.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.numberValue]];
//            NSLog(@"text is %@,value is %d text length is %d",self.amount.text,self.numberValue,self.amount.text.length);
			valueChanged = YES;
		}
	}
    
}


///*************
- (void)deleteBackward {
    
    NSLog(@"%d, %d,%d",endFlag,dotBeginFlag, dotnumber);
    
    // 第一次输入
    if(firstInput){
        firstInput = NO;
        self.numberValue = 0.0f;
        	self.amount.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.numberValue]];
        return;
    }
    
    if(endFlag || dotBeginFlag){
        // 删除小数
        dotnumber ++;
        endFlag = NO;
        if (dotnumber == AMOUNT_DECIMAL_LENGTH_MAX ) {
            dotBeginFlag = NO;
        }
        // 小数点左移 AMOUNT_DECIMAL_LENGTH_MAX-dotnumber
        self.numberValue = self.numberValue*pow(10, AMOUNT_DECIMAL_LENGTH_MAX-dotnumber);
        //return;
    }
    else {
        // 删除整数
        self.numberValue = self.numberValue / 10;

    }

    
    double tempIntPart ;
    
     modf(self.numberValue,&tempIntPart);
 
    self.numberValue = tempIntPart;
    
    // 小数点右移 AMOUNT_DECIMAL_LENGTH_MAX－dotnumber
    self.numberValue = self.numberValue*pow(0.1, AMOUNT_DECIMAL_LENGTH_MAX-dotnumber);

    
    //NSLog(@"del %f, %f", self.numberValue, tempIntPart);
	if (self.numberValue < self.lowerLimit) {
		self.numberValue = self.lowerLimit;
	} else if (self.numberValue > self.upperLimit) {
		self.numberValue = self.upperLimit;
	}
    
    //NSLog(@"del %f, %f", self.numberValue, tempIntPart);

    //self.amount.text = [NSString stringWithFormat:@"%f",self.numberValue];

	self.amount.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.numberValue]];

	valueChanged = YES;
}

*/
 //*****************/
@end
