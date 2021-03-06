//
//  SPZBaseNetworkServiceTool.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseNetworkServiceTool.h"
#import "SPZBaseNetWorkServiceInforModel.h"
//#import "SPZBaseTabBarController.h"
//#import "SPZBaseViewController.h"

@interface SPZBaseNetworkServiceTool ()

@property(nonatomic,strong)NSMutableArray <SPZBaseNetWorkServiceInforModel *>*invalidUrlArr;

@property(nonatomic,copy)NSString *updateUrl;
@property(nonatomic,assign)NSInteger i;

@end

@implementation SPZBaseNetworkServiceTool

+(SPZBaseNetworkServiceTool *)shareServiceTool
{
    static SPZBaseNetworkServiceTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [self new];
    });
    return tool;
}

//六色因为没有握手一块的内容 所以设置了连续五次请求 成功则退出 失败会进入下一次 直至五次满 提示用户退出app
-(void)httpDNSActionWithCompleteBlock:(void(^)())completeBlock failureBlock:(void(^)())failureBlock{

    [[SPZNetworkTool getInstance]getJsonWithUrl:AppHttpDNS parameters:nil success:^(id responseObject) {
        Log_ResponseObject;
        NSString *ipStr = responseObject[@"currentData"];
        if([responseObject[@"currentStatus"] intValue] == 0){
            if([ipStr isNotNil]){
                YYCache *cache = [YYCache cacheWithName:CacheKey];
                [cache setObject:[NSString stringWithFormat:@"http://%@:9977",ipStr] forKey:@"serviceHost"];
                completeBlock();
                return ;
            }else{
                if(_i == 4){
                    failureBlock();
                }else{
                    [self httpDNSActionWithCompleteBlock:completeBlock failureBlock:failureBlock];
                    _i++;
                }
            }
        }else{
            if(_i == 4){
                failureBlock();
            }else{
                [self httpDNSActionWithCompleteBlock:completeBlock failureBlock:failureBlock];
                _i++;
            }
        }
    } fail:^(NSError *error) {
        if(_i == 4){
            failureBlock();
        }else{
            [self httpDNSActionWithCompleteBlock:completeBlock failureBlock:failureBlock];
            _i++;
        }
    }];
}

-(void)setNetWorkServiceWithCompleteBlock:(void(^)())completeBlock failureBlock:(void(^)())failureBlock{
    
    NSDictionary *paramers = @{@"paramData":@{@"code":@"acp"},
                               @"uri":@"/getDomainMapper",
                               @"token":@"4d2cbce9-4338-415e-8343-7c9e67dae7ef"};
    [[SPZNetworkTool getInstance]postJsonWithUrl:AppNetwork parameters:paramers success:^(id responseObject) {
        if([responseObject[@"stat"] integerValue] == 0){
            NSArray <SPZBaseNetWorkServiceInforModel *>*serviceInforArr = [SPZBaseNetWorkServiceInforModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
            
            if(serviceInforArr.count){
                //请求回来若干个域名进行轮询
                for(int i = 0;i < serviceInforArr.count;i++){
                    SPZBaseNetWorkServiceInforModel *inforModel = serviceInforArr[i];
                    [self checAppBeingIntercept:inforModel success:^{
                        //测试域名成功 上传失效域名
                        [self updateInvalidURLs];
                        YYCache *cache = [YYCache cacheWithName:CacheKey];
                        [cache setObject:inforModel.domain forKey:@"serviceHost"];
                        completeBlock();
                       
                    }callback:^{
                        [self.invalidUrlArr addObject:inforModel];
                        if(i == serviceInforArr.count - 1){
                            //测试域名全部失败 上传失效域名
                            [self updateInvalidURLs];
                            failureBlock();
                        }
                    }];
                }
            }
        }else{
           failureBlock();
        }
        
    } fail:^(NSError *error) {
        NSLog(@"%@",error.description);
        failureBlock();
    }];
    
}

-(void)getAppBaseInfors{
    
    NSLog(@"%@",BaseUrl(AppInitialize));
    
    NSDictionary *paramers = @{@"paramData":@{@"app_type":@1},
                               @"uri":AppInitialize,
                               @"token":@"4d2cbce9-4338-415e-8343-7c9e67dae7ef"};
    
    [[SPZNetworkTool getInstance] postDataWithUrl:BaseUrl(AppInitialize) parameters:paramers success:^(id responseObject) {
        
        if([responseObject[@"code"] isEqualToString:@"0000"])
        {
            YYCache *cache = [YYCache cacheWithName:CacheKey];
            NSString *signInStatus = nil;
            
            if([responseObject[@"data"][@"signInStatus"][0][@"mission_status"] integerValue] == 0){
                signInStatus = @"Yes";
                [cache setObject:signInStatus forKey:@"signInStatus"];
            }else{
                signInStatus = @"No";
                [cache setObject:signInStatus forKey:@"signInStatus"];
            }
            NSString *serviceUrl = responseObject[@"data"][@"service"][@"customer_server_url"];
            if([serviceUrl isNotNil]){
                [cache setObject:serviceUrl forKey:@"serviceUrl"];
            }
            
        }
        
    } fail:^(NSError *error) {
        
    }];
    
}

-(void)updateInvalidURLs{
    NSMutableArray *muArr = [NSMutableArray array];
    if( !_invalidUrlArr || self.invalidUrlArr.count == 0)
    {
        return;
    }
    for(SPZBaseNetWorkServiceInforModel *inforModel in _invalidUrlArr){
        
        NSDictionary *dict = @{@"id":[NSString stringWithFormat:@"%zd",inforModel.Id],
                               @"domainState":@1,
                               @"systemCode":@"acp",
                               @"domain":inforModel.domain,};
        [muArr addObject:dict];
    }
    
    if(muArr.count == 0)
    {
        return;
    }
    
    NSDictionary *paramers = @{@"paramData":@{@"changes":muArr.copy},
                               @"uri":AppUpdateInvalidUrl,
                               @"token":@"4d2cbce9-4338-415e-8343-7c9e67dae7ef"};
    [[SPZNetworkTool getInstance]postJsonWithUrl:AppUpdateInvalidUrl parameters:paramers success:^(id responseObject) {
        if([responseObject[@"stat"]  integerValue] == 0){
            
            
        }else{
            
            
        }
        
    } fail:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
    
}


- (void)checAppBeingIntercept:(SPZBaseNetWorkServiceInforModel *)inforModel success:(void(^)())success callback:(void(^)())callback{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *dayStr = [dateStr substringFromIndex:dateStr.length - 2];
    NSString *key = inforModel.privateKey;
    if(![inforModel.privateKey isNotNil]){
        key = @"";
    }
    NSString *md5string = [NSString stringWithFormat:@"acp%@%@%@",dateStr,dayStr,[NSString md5:key]];
    NSString *md5Str = [NSString md5:md5string];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",inforModel.domain,AppCheckHostAvailable];
    NSDictionary *paramers = @{@"paramData":@{@"date":dateStr,
                                              @"check_dn" :md5Str,
                                              @"host":@"acp"},
                               @"uri":AppCheckHostAvailable,
                               @"token":@"4d2cbce9-4338-415e-8343-7c9e67dae7ef"};
    
    [[SPZNetworkTool getInstance]postDataWithUrl:url parameters:paramers success:^(id responseObject) {
        
        if([responseObject[@"stat"] integerValue] == 0){
            
            NSInteger dayNum = [dayStr integerValue] * 2;
            NSString *newDateStr = [NSString stringWithFormat:@"%@%02zd",[dateStr substringToIndex:dateStr.length-2],dayNum];
            NSString *mathStr = [NSString stringWithFormat:@"%@%@acp%@",dayStr,newDateStr,[NSString md5:key]];
            NSLog(@"key === %@",mathStr);
            NSString *newMd5Str = [NSString md5:mathStr];
            if([newMd5Str isEqualToString:responseObject[@"data"][@"check_dn"] ]){
                success();
            }else{
                callback();
            }
            
        }else{
            callback();
        }
        
    } fail:^(NSError *error) {
        NSLog(@"%@",error.description);
        //        callback();
    }];
    
}

-(void)getUpdateInfor{
    
    [[SPZNetworkTool getInstance].sharedManager POST:AppUpdateUrl parameters:AppUpdatePeramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *str = [responseObject mj_JSONString];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dictData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if([dictData[@"entity"][@"downloadUrl"] isKindOfClass:[NSDictionary class]]){
            self.updateUrl=[NSString stringWithFormat:@"itms-services:///?action=download-manifest&url=%@",dictData[@"entity"][@"downloadUrl"][@"manifest"]];
        }
        NSInteger isbool=[dictData[@"entity"][@"versionType"] integerValue];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *version = dictData[@"entity"][@"version"];
        
        if (![appVersion isEqualToString:version]) {
            if (isbool==3) {
                
                [self showUpdateAlertVCWithUpdateMsg:dictData[@"entity"][@"version"]];
                
            }else if (isbool==4){
                
                [self forcedUpdate];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)forcedUpdate{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有重要新版本更新" message:@"为了给您更好的体验/n请更新到最新版本" preferredStyle:UIAlertControllerStyleAlert];
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    
    [NSThread sleepForTimeInterval:3.0];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.updateUrl] options:@{} completionHandler:^(BOOL success) {
        exit(0);
    }];
}

-(void)showUpdateAlertVCWithUpdateMsg:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有新版本更新" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.updateUrl]];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"放弃更新" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    
}



- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

-(NSMutableArray <SPZBaseNetWorkServiceInforModel *>*)invalidUrlArr{
    if(_invalidUrlArr == nil){
        _invalidUrlArr = [NSMutableArray new];
    }
    return _invalidUrlArr;
}



@end
