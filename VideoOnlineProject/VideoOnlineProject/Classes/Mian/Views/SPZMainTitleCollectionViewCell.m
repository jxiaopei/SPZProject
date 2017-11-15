//
//  SPZMainTitleCollectionViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZMainTitleCollectionViewCell.h"

@interface SPZMainTitleCollectionViewCell()

@property(nonatomic,strong)UILabel *titleLabel;

@end

@implementation SPZMainTitleCollectionViewCell

-(void)setupUI{
    
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(0);
    }];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
}

-(void)setDataModel:(SPZMainTItleDataModel *)dataModel
{
    _dataModel = dataModel;
    _titleLabel.text = dataModel.titleName;
}

@end
