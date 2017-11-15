//
//  SPZUserModel.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZUserModel.h"

@implementation SPZUserModel

+(SPZUserModel *)shareModel
{
    static SPZUserModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [self new];
    });
    return model;
}

-(NSMutableArray *)searchHisArr{
    if(_searchHisArr == nil){
        _searchHisArr = [NSMutableArray array];
        [_searchHisArr addObjectsFromArray:(NSArray *)[[YYCache cacheWithName:CacheKey] objectForKey:@"searchHisArr"]];
    }
    return _searchHisArr;
}

- (NSString *)uid {
    if (_uid == nil) {
        _uid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return _uid;
}

- (NSString *)openDelay {
    if (_openDelay.integerValue < 1000) {
        _openDelay = @"1000";
    }
    return _uid;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:self.currentToken forKey:@"currentToken"];
    [aCoder encodeObject:self.uid forKey:@"userId"];
    [aCoder encodeObject:self.userAccount forKey:@"userAccount"];
    [aCoder encodeObject:self.serviceUrl forKey:@"serviceUrl"];
    [aCoder encodeObject:self.openDelay forKey:@"openDelay"];
    [aCoder encodeInteger:self.integral forKey:@"integral"];
    [aCoder encodeBool:self.showIntegral forKey:@"showIntegral"];
    [aCoder encodeBool:self.isLogin forKey:@"isLogin"];
    [aCoder encodeObject:self.searchHisArr forKey:@"searchHisArr"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.userName  = [aDecoder decodeObjectForKey:@"userName"];
    self.password = [aDecoder decodeObjectForKey:@"password"];
    self.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
    self.currentToken = [aDecoder decodeObjectForKey:@"currentToken"];
    self.uid = [aDecoder decodeObjectForKey:@"userId"];
    self.userAccount = [aDecoder decodeObjectForKey:@"userAccount"];
    self.serviceUrl = [aDecoder decodeObjectForKey:@"serviceUrl"];
    self.openDelay = [aDecoder decodeObjectForKey:@"openDelay"];
    self.integral = [aDecoder decodeIntegerForKey:@"integral"];
    self.showIntegral = [aDecoder decodeBoolForKey:@"showIntegral"];
    self.isLogin = [aDecoder decodeBoolForKey:@"isLogin"];
    self.searchHisArr = [aDecoder decodeObjectForKey:@"searchHisArr"];
    return self;
}

@end
