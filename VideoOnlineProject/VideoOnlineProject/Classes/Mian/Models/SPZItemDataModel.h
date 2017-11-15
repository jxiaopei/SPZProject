//
//  SPZItemDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPZUnitDataModel.h"

@interface SPZItemDataModel : NSObject

@property(nonatomic,copy)NSString *catTitle;
@property(nonatomic,assign)NSInteger catId;
@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*resList;
@property(nonatomic,assign)CGFloat rowHeight;

@end
