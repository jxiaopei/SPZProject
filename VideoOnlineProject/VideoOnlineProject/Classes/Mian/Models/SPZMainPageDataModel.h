//
//  SPZMainPageDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPZUnitDataModel.h"

@interface SPZMainPageDataModel : NSObject

@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*dataList;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*secondList;
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,assign)BOOL isCountEnought;
@property(nonatomic,assign)BOOL isChange;

@end
