//
//  SPZAttentionTableViewCell.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZBaseTableViewCell.h"
#import "SPZUnitDataModel.h"

@interface SPZAttentionTableViewCell : SPZBaseTableViewCell

@property(nonatomic,strong)SPZUnitDataModel *dataModel;
@property(nonatomic,assign)BOOL isEditing;
@property(nonatomic,copy)void (^didClickCollectBtnBlock)(BOOL selected);

@end
