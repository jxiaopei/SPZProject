//
//  SPZBaseWebViewController.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseViewController.h"
#import  <WebKit/WebKit.h>

@interface SPZBaseWebViewController : SPZBaseViewController

@property(nonatomic,copy)NSString *urlString;
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,strong)WKWebView *webView;

@end
