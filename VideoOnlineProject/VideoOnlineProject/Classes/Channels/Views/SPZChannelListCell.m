//
//  SPZChannelListCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZChannelListCell.h"

@interface SPZChannelListCell ()

@property(nonatomic,strong)UIImageView *iconView;

@end

@implementation SPZChannelListCell

-(void)setupUI{
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
    }];
    iconView.image = ImagePlaceHolder;
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10;
    iconView.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)setDataModel:(SPZUnitDataModel *)dataModel{
    _dataModel = dataModel;
     [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.previewPath)] placeholderImage:ImagePlaceHolder];
}

@end
