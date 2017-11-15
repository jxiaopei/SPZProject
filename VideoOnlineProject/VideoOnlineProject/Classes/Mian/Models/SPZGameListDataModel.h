//
//  SPZGameListDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZGameListDataModel : NSObject

@property (nonatomic, strong) NSString *gameImageUrl;
@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, strong) NSString *link_url;
@property (nonatomic, strong) NSString *show_flag;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *type_name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *gameBanner;

@end
