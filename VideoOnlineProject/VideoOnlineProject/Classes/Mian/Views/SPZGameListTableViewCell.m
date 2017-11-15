//
//  SPZGameListTableViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZGameListTableViewCell.h"

@implementation SPZGameListTableViewCell

-(void)setupUI{
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 80, 80)];
    _headImageView.clipsToBounds = YES;
    _headImageView.layer.cornerRadius = 40;;
    [self.contentView addSubview:_headImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 40, SCREENWIDTH - 150, 20)];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_titleLabel];
}

@end
