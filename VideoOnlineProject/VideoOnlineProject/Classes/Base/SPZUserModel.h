//
//  SPZUserModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZUserModel : NSObject<NSCoding>

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,assign)BOOL isLogin;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,assign)BOOL isLoginOtherView;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *userAccount;
@property (nonatomic, strong) NSString *currentToken;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, assign) NSUInteger integral;
@property (nonatomic, strong) NSString *openDelay;
@property (nonatomic, assign) BOOL showIntegral;

@property(nonatomic,strong)NSMutableArray *searchHisArr;

+(SPZUserModel *)shareModel;

@end
