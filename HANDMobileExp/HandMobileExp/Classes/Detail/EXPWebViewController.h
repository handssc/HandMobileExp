//
//  EXPWebViewController.h
//  HandMobileExp
//
//  Created by jiangtiteng on 14-7-6.
//  Copyright (c) 2014年 hand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"

@interface EXPWebViewController : UIViewController <UIWebViewDelegate>{
    
    UIWebView*        _webView;
    NSString *        _url;
    NSString *        _text;
    NSString *        _resourceBundleName;
}


-(id)initWithUrl:(NSString *)url title:(NSString *)title;
@end
