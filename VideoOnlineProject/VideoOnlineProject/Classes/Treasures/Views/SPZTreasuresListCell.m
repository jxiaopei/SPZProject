//
//  SPZTreasuresListCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZTreasuresListCell.h"

@interface SPZTreasuresListCell()

@property(nonatomic,strong)UIImageView *iconView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *likeBtn;
@property(nonatomic,strong)UIButton *commentBtn;

@end

@implementation SPZTreasuresListCell

-(void)setupUI{
    
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(180);
    }];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10;
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIButton *commentBtn = [UIButton new];
    [self addSubview:commentBtn];
    _commentBtn = commentBtn;
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(iconView.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(25);
    }];
    commentBtn.hidden = YES;
    [commentBtn setImage:ImagePlaceHolder forState:UIControlStateNormal];
    
    UIButton *likeBtn = [UIButton new];
    [self addSubview:likeBtn];
    _likeBtn = likeBtn;
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(commentBtn.mas_left).mas_offset(-10);
        make.top.mas_equalTo(iconView.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(25);
    }];
    likeBtn.hidden = YES;
    [likeBtn setImage:ImagePlaceHolder forState:UIControlStateNormal];
    
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(iconView.mas_bottom).mas_offset(10);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];
}

-(void)setDataModel:(SPZUnitDataModel *)dataModel{
    _dataModel = dataModel;
    _titleLabel.text = dataModel.fileName;
     [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.logo)] placeholderImage:ImagePlaceHolder];

}

@end
