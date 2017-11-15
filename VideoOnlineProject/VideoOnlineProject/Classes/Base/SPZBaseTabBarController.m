//
//  SPZBaseTabBarController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseTabBarController.h"
#import "SPZBaseNavigationController.h"
#import "SPZMainPageViewController.h"
#import "SPZChannelsViewController.h"
#import "SPZTreasuresViewController.h"
#import "SPZPersonalViewController.h"

@interface SPZBaseTabBarController ()

@end

@implementation SPZBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
}

-(void)setupViewControllers
{
    SPZMainPageViewController *mainVC = [SPZMainPageViewController new];
    SPZBaseNavigationController *nav = [[SPZBaseNavigationController alloc]initWithRootViewController:mainVC];
    UIImage *homeNorImage = [[UIImage imageNamed:@"home" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *homeSelImage = [[UIImage imageNamed:@"home_selected" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"首页" image:homeNorImage selectedImage:homeSelImage];
    
    SPZChannelsViewController *channelsVC = [SPZChannelsViewController new];
    SPZBaseNavigationController *nav1 = [[SPZBaseNavigationController alloc]initWithRootViewController:channelsVC];
    UIImage *channelNorImage = [[UIImage imageNamed:@"channel" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *channelSelImage = [[UIImage imageNamed:@"channel_selected" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    nav1.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"频道" image:channelNorImage selectedImage:channelSelImage];
    
    SPZTreasuresViewController *treasuresVC = [SPZTreasuresViewController new];
    SPZBaseNavigationController *nav2 = [[SPZBaseNavigationController alloc]initWithRootViewController:treasuresVC];
    UIImage *treasuresNorImage = [[UIImage imageNamed:@"treasure" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *treasuresSelImage = [[UIImage imageNamed:@"treasure_selected" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    nav2.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"精品" image:treasuresNorImage selectedImage:treasuresSelImage];
    
    SPZPersonalViewController *personalVC = [SPZPersonalViewController new];
    SPZBaseNavigationController *nav3 = [[SPZBaseNavigationController alloc]initWithRootViewController:personalVC];
    UIImage *personalNorImage = [[UIImage imageNamed:@"personal" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage *personalSelImage = [[UIImage imageNamed:@"personal_selected" ] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    nav3.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"我的" image:personalNorImage selectedImage:personalSelImage];
    
    self.viewControllers = @[nav,nav1,nav2,nav3];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor blackColor];
    self.selectedIndex = 0;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName ,nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName ,nil]forState:UIControlStateSelected];
}


//- (BOOL)shouldAutorotate
//{
//    return [self.selectedViewController shouldAutorotate];
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return [self.selectedViewController supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
//}

@end
