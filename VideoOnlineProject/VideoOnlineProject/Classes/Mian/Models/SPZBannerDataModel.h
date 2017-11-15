//
//  SPZBannerDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZBannerDataModel : NSObject

@property(nonatomic,assign)NSInteger Id;
@property(nonatomic,assign)NSInteger resId;
@property(nonatomic,strong)NSString *bannerTitle;
@property(nonatomic,strong)NSString *bannerLinkUrl;
@property(nonatomic,strong)NSString *bannerImageUrl;

@end
