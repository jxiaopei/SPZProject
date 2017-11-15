//
//  SPZBaseNetworkServiceTool.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZBaseNetworkServiceTool : NSObject

+(SPZBaseNetworkServiceTool *)shareServiceTool;

-(void)setNetWorkService;

-(void)getAppBaseInfors;

-(void)getUpdateInfor;

-(void)httpDNSAction;

@end
