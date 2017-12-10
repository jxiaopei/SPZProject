//
//  SPZUnitDataModel.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZUnitDataModel.h"

@implementation SPZUnitDataModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"Id" : @"id",
             };
}

-(NSString *)registerPic{
    NSString *imgUrl = nil;
    
    if([_registerPic hasPrefix:@"http"]){
        imgUrl = _registerPic;
    }else{
        imgUrl = BaseHost(_registerPic);
    }
    return imgUrl;
}

-(NSString *)confirmPic{
    
    NSString *imgUrl = nil;
    
    if([_confirmPic hasPrefix:@"http"]){
        imgUrl = _confirmPic;
    }else{
        imgUrl = BaseHost(_confirmPic);
    }
    return imgUrl;
    
}

@end
