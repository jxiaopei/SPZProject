//
//  SPZItemDataModel.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZItemDataModel.h"

@implementation SPZItemDataModel

+(NSDictionary *)mj_objectClassInArray
{
    return @{@"resList":[SPZUnitDataModel class]};
}

-(CGFloat)rowHeight{
    
    return 4/2 * 120 + 10 + 35 + 60 ;
}

@end
