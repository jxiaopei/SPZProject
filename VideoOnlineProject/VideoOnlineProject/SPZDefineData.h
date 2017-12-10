//
//  SPZDefineData.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#ifndef SPZDefineData_h
#define SPZDefineData_h



#define kMainToken @"4d2cbce9-4338-415e-8343-7c9e67dae7ef"

#define BundleID                @"com.eric.VideoOnlineProject"

#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define AppUpdateCode           @"a9170aa9edf6c67986f9da694a234b89"   //检测新版本更新code
#define AppUpdatePeramters      @{@"code":AppUpdateCode}

#define AppKey                  @"5a2386a2f43e48681900005e"           //友盟appKey
#define AppSecret               @"gfbvej3rrc8qn0oz0fxkqk5s5fmuby6e"  //友盟app 秘钥

#define COMPANYPARA             @{@"app_id":@"1258070698"}            //appID
#define CacheKey                @"ACPCacheKey"
#define UserID                  @"UserID"

#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH   [UIScreen mainScreen].bounds.size.width
#define StringFormat(string, args...)       [NSString stringWithFormat:string, args]
#define Log_ResponseObject      NSLog(@"%@",[responseObject mj_JSONString])
#define ImagePlaceHolder        [UIImage imageNamed:@"占位图"]

#endif /* SPZDefineData_h */
