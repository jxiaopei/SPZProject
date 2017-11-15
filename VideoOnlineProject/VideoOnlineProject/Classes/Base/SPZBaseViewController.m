//
//  SPZBaseViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseViewController.h"

@interface SPZBaseViewController ()

@end

@implementation SPZBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)customTitleWith:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.text = title;
    self.navigationItem.titleView = label;
}
- (void)customBackBtn
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    [button setImage:[UIImage imageNamed:@"返回键"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//不支持横屏设置三个方法
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//
//-(BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait ;
//}


@end
