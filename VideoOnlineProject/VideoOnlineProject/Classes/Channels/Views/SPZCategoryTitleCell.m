//
//  SPZCategoryTitleCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCategoryTitleCell.h"

@implementation SPZCategoryTitleCell

-(void)setupUI{
    self.iconView = [UIImageView new];
    [self addSubview:self.iconView];
    self.iconView.frame = CGRectMake(((SCREENWIDTH -35)/4 - 50)/2, 5, 50, 50);
    
    self.title = [UILabel new];
    self.title.textColor = [UIColor blackColor];
    self.title.font = [UIFont systemFontOfSize:14];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.title];
    self.title.frame = CGRectMake(2, 60, (SCREENWIDTH - 35)/4 - 4, 20);
    self.title.adjustsFontSizeToFitWidth = YES;
}

@end
