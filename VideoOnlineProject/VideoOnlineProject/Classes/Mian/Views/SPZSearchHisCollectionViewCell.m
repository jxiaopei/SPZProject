//
//  SPZSearchHisCollectionViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZSearchHisCollectionViewCell.h"

@implementation SPZSearchHisCollectionViewCell

-(void)setupUI{
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.bottom.mas_equalTo(0);
    }];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.layer.masksToBounds = YES;
    titleLabel.layer.cornerRadius = 5;
    titleLabel.backgroundColor = GlobalLightGreyColor;
}

@end
