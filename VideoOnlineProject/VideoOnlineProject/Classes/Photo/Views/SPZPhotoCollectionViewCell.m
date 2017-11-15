//
//  SPZPhotoCollectionViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/30.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZPhotoCollectionViewCell.h"

@interface SPZPhotoCollectionViewCell()

@property(nonatomic,strong)UIImageView *iconView;

@end

@implementation SPZPhotoCollectionViewCell

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
    iconView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 2;
}

-(void)setModel:(id)model{
    if([model isKindOfClass:[NSString class]]){
       _iconView.image =  [UIImage imageNamed:model];
    }else if([model isKindOfClass:[NSURL class]]){
        [_iconView sd_setImageWithURL:model placeholderImage:ImagePlaceHolder];
    }
    
}

@end
