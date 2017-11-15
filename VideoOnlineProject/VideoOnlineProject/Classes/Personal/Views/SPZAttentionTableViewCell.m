//
//  SPZAttentionTableViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZAttentionTableViewCell.h"

@interface SPZAttentionTableViewCell ()

@property(nonatomic,strong)UIButton *collectBtn;
@property(nonatomic,strong)UIImageView *iconView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *dateLabel;

@end

@implementation SPZAttentionTableViewCell

-(void)setupUI{
    
    UIButton *collectBtn = [UIButton new];
    [self addSubview:collectBtn];
    _collectBtn = collectBtn;
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(30);
    }];
    [collectBtn setImage:[UIImage imageNamed:@"编辑未选择"] forState:UIControlStateNormal];
    [collectBtn setImage:[UIImage imageNamed:@"编辑选择"] forState:UIControlStateSelected];
    [collectBtn addTarget:self action:@selector(didClickCollectBtn:) forControlEvents:UIControlEventTouchUpInside];
    collectBtn.alpha = 0.0;
    
    UIImageView *iconView = [UIImageView new];
    [self addSubview:iconView];
    _iconView = iconView;
    iconView.frame = CGRectMake(10, 10, 120, 80);
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 2;
    iconView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
    
    UILabel *nameLabel = [UILabel new];
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    nameLabel.frame = CGRectMake(140, 10, SCREENWIDTH - 180, 40);
    nameLabel.numberOfLines = 2;
    nameLabel.font = [UIFont systemFontOfSize:14];
    
    UILabel *dateLabel = [UILabel new];
    [self addSubview:dateLabel];
    _dateLabel = dateLabel;
    dateLabel.frame = CGRectMake(140, 60, SCREENWIDTH - 180, 20);
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.textColor = [UIColor grayColor];
    
}

-(void)didClickCollectBtn:(UIButton *)sender{
    sender.selected = ! sender.selected;
    if(self.didClickCollectBtnBlock){
        self.didClickCollectBtnBlock(sender.selected);
    }
}

-(void)setIsEditing:(BOOL)isEditing{
    _isEditing = isEditing;
    if(_isEditing){
        [UIView animateWithDuration:0.2 animations:^{
            _collectBtn.alpha = 1.0;
            _iconView.frame = CGRectMake(50, 10, 120, 80);
            _nameLabel.frame = CGRectMake(180, 10, SCREENWIDTH - 220, 40);
            _dateLabel.frame = CGRectMake(180, 60, SCREENWIDTH - 220, 20);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            _collectBtn.alpha = 0.0;
            _iconView.frame = CGRectMake(10, 10, 120, 80);
            _nameLabel.frame = CGRectMake(140, 10, SCREENWIDTH - 180, 40);
            _dateLabel.frame = CGRectMake(140, 60, SCREENWIDTH - 180, 20);
        }];
    }
   
}

-(void)setDataModel:(SPZUnitDataModel *)dataModel{
    _dataModel = dataModel;
    _collectBtn.selected = dataModel.isSelected;
    if([dataModel.fileName isNotNil]){
        _nameLabel.text = dataModel.fileName;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.logo)] placeholderImage:ImagePlaceHolder];
    }else{
        _nameLabel.text = dataModel.pictureName;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.previewPath)] placeholderImage:ImagePlaceHolder];
    }
    _dateLabel.text = [dataModel.createTime insertStandardTimeFormat];
}




@end
