//
//  SPZVideoPlayerViewController.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/30.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseViewController.h"

@interface SPZVideoPlayerViewController : SPZBaseViewController

@property(nonatomic,assign)NSInteger Id;
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,copy)NSString *videoPath;
@property(nonatomic,assign)BOOL isOpenVipTipView;

@end
