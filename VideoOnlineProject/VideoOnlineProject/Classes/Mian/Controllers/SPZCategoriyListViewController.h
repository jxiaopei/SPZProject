//
//  SPZCategoriyListViewController.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseViewController.h"

typedef NS_ENUM(NSInteger,CategoryVCType){
    
    LikeListType = 0,       //猜你喜欢
    CategoryListType,       //类型下列表
    VideoListType,          //单一类型影片列表
    RecommendType,          //推荐列表
};

@interface SPZCategoriyListViewController : SPZBaseViewController

@property(nonatomic,assign)NSInteger categoryId;
@property(nonatomic,assign)CategoryVCType vcType;
@property(nonatomic,copy)NSString *titleStr;

@end
