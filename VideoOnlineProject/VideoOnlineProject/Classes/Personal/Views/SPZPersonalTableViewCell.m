//
//  SPZPersonalTableViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/1.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZPersonalTableViewCell.h"

@implementation SPZPersonalTableViewCell

-(void)setupUI{
    
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(25);
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconView.mas_right).mas_offset(20);
        make.centerY.mas_equalTo(0);
    }];
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    
    UILabel *detailLabel = [UILabel new];
    [self addSubview:detailLabel];
    _detailLabel = detailLabel;
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-30);
    }];
    detailLabel.font = [UIFont systemFontOfSize:13];
    detailLabel.textColor = [UIColor grayColor] ;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];
}

@end
