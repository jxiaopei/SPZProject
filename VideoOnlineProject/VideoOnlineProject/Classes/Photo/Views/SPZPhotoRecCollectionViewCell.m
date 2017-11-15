//
//  SPZPhotoRecCollectionViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/30.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZPhotoRecCollectionViewCell.h"

@interface SPZPhotoRecCollectionViewCell()

@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView *iconView;

@end

@implementation SPZPhotoRecCollectionViewCell

-(void)setupUI{
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(120);
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
    _nameLabel.text = dataModel.pictureName;
     [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.previewPath)] placeholderImage:ImagePlaceHolder];
}

@end
