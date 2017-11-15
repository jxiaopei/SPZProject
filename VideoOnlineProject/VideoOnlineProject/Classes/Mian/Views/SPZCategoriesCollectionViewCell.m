//
//  SPZCategoriesCollectionViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCategoriesCollectionViewCell.h"

@interface SPZCategoriesCollectionViewCell()

@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView *iconView;

@end

@implementation SPZCategoriesCollectionViewCell

-(void)setupUI{
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 2;
    iconView.image = ImagePlaceHolder;
    iconView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;

    
    UILabel *nameLabel = [UILabel new];
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    nameLabel.text = @"分类名称";
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    
}

-(void)setDataModel:(SPZMainTItleDataModel *)dataModel{
    _dataModel = dataModel;
    _nameLabel.text = dataModel.titleName;
    [_iconView sd_setImageWithURL:[NSURL URLWithString: BaseHost(dataModel.imageUrl)] placeholderImage:ImagePlaceHolder];
}

@end
