//
//  SPZMainPageTableViewCell.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseTableViewCell.h"
#import "SPZItemDataModel.h"
#import "SPZMainPageDataModel.h"

@interface SPZMainPageTableViewCell : SPZBaseTableViewCell

@property(nonatomic,strong)SPZMainPageDataModel *dataModel;
@property(nonatomic,copy)void(^didClickCollectionCellBlock)(NSInteger index);
@property(nonatomic,copy)void(^didClickShowMoreBtnBlock)();
@property(nonatomic,copy)void(^didChangeAGroupsDataBtnBlock)();


@end
