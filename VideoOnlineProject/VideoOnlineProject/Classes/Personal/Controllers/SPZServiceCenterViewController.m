//
//  SPZServiceCenterViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/2.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZServiceCenterViewController.h"

@interface SPZServiceCenterViewController ()

@end

@implementation SPZServiceCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBackBtn];
    [self customTitleWith:@"客服"];
}

-(void)viewWillAppear:(BOOL)animated{
    //    [super viewWillAppear:animated];
    NSString *url = @"https://chat6.livechatvalue.com/chat/chatClient/chatbox.jsp?companyID=17779&configID=48708&jid=&s=1";//(NSString *)[[YYCache cacheWithName:CacheKey] objectForKey:@"serviceUrl"];
    self.urlString = [url isNotNil]?url : @"";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

@end
