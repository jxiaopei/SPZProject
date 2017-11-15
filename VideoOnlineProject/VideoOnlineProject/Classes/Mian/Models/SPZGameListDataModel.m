//
//  SPZGameListDataModel.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZGameListDataModel.h"

@implementation SPZGameListDataModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"Id" : @"id",
             };
}

@end
