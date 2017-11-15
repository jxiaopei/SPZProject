//
//  SPZCategoryListCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCategoryListCell.h"

@interface SPZCategoryListCell ()

@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView *iconView;

@end

@implementation SPZCategoryListCell

-(void)setupUI{
    
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.centerX.mas_offset(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(90);
    }];
    iconView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 2;
    
    UILabel *nameLabel = [UILabel new];
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(iconView.mas_bottom).mas_offset(5);
    }];
    nameLabel.text = @"视频名字";
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
}

-(void)setDataModel:(SPZUnitDataModel *)dataModel{
    _dataModel = dataModel;
    _nameLabel.text = dataModel.fileName;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.logo)] placeholderImage:ImagePlaceHolder];
}

@end
