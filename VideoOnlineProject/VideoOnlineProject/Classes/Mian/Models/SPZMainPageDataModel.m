//
//  SPZMainPageDataModel.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZMainPageDataModel.h"

@implementation SPZMainPageDataModel

+(NSDictionary *)mj_objectClassInArray
{
    return @{@"dataList":[SPZUnitDataModel class]};
}

-(BOOL)isCountEnought{
    if(self.dataList.count > 4){
        return YES;
    }else{
        return NO;
    }
}

-(void)setDataList:(NSMutableArray<SPZUnitDataModel *> *)dataList{
    _dataList = dataList;
    _secondList = [NSMutableArray array];
    if(self.isCountEnought){
        [_secondList removeAllObjects];
        for(int i = 4;i < _dataList.count;i++){
            [_secondList addObject:_dataList[i]];
        }
    }
}

//-(NSMutableArray <SPZUnitDataModel *>*)secondList{
//   
//}

@end
