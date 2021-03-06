//
//  SPZMainPageTableViewCell.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZMainPageTableViewCell.h"
#import "SPZMainUnitCollectionViewCell.h"

@interface SPZMainPageTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UIButton *showMoreBtn;

@end

@implementation SPZMainPageTableViewCell

-(void)setupUI{
    
    UIView *verView = [UIView new];
    [self addSubview:verView];
    verView.frame = CGRectMake(10, 10, 2, 15);
    verView.backgroundColor = GlobalPurpleColor;
    
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(verView.mas_centerY);
    }];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = @"热门推荐";
    
   
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemW = (SCREENWIDTH - 20 - 2)/2;
    layout.itemSize = CGSizeMake(itemW,120);
    layout.minimumInteritemSpacing = 2;
//    layout.minimumInteritemSpacing = 5;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 35, SCREENWIDTH - 20, 250) collectionViewLayout:layout];
    _collectionView = collectView;
    [self addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZMainUnitCollectionViewCell class] forCellWithReuseIdentifier:@"mainUnitCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    collectView.scrollEnabled = NO;
    
    UIButton *showMoreBtn = [UIButton new];
    [self addSubview:showMoreBtn];
    _showMoreBtn = showMoreBtn;
    [showMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(- 80);
        make.top.mas_equalTo(collectView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(120);
    }];
    showMoreBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 100, 5, 0);
    showMoreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [showMoreBtn setImage:[UIImage imageNamed:@"首页右箭头"] forState:UIControlStateNormal];
    showMoreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [showMoreBtn setTitleColor:GlobalRedColor forState:UIControlStateNormal];
    [showMoreBtn addTarget:self action:@selector(didClickShowMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *changeBtn = [UIButton new];
    [self addSubview:changeBtn];
    [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(60);
        make.top.mas_equalTo(collectView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(120);
    }];
    changeBtn.imageEdgeInsets = UIEdgeInsetsMake(7.5, 95, 7.5, 10);
    changeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    changeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [changeBtn setTitle:@"换一换" forState:UIControlStateNormal];
    [changeBtn setImage:[UIImage imageNamed:@"首页刷新"] forState:UIControlStateNormal];
    changeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [changeBtn setTitleColor:GlobalBlueColor forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(didChangeAGroupsData:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(5);
    }];
    
}

-(void)didChangeAGroupsData:(UIButton *)sender{
    if(!_dataModel.isCountEnought){
        [MBProgressHUD showError:@"暂无可更换数据"];
        return;
    }
    _dataModel.isChange = !_dataModel.isChange;
    if(self.didChangeAGroupsDataBtnBlock){
        self.didChangeAGroupsDataBtnBlock();
    }
}

-(void)didClickShowMoreBtn:(UIButton *)sender{
    if(self.didClickShowMoreBtnBlock){
        self.didClickShowMoreBtnBlock();
    }
}

-(void)setDataModel:(SPZMainPageDataModel *)dataModel{
    _dataModel = dataModel;
    NSInteger row = _dataModel.dataList.count % 2 ? _dataModel.dataList.count / 2 + 1 : _dataModel.dataList.count /2;
    row = row > dataModel.count ? dataModel.count : row;
    _collectionView.frame = CGRectMake(10, 35, SCREENWIDTH - 20, 130 * row);
    [_collectionView reloadData];
    _titleLabel.text = _dataModel.titleStr;
    NSString *titleStr = [NSString stringWithFormat:@"更多%@",[_dataModel.titleStr substringToIndex:2]];
    [_showMoreBtn setTitle:titleStr forState:UIControlStateNormal];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.didClickCollectionCellBlock){
        self.didClickCollectionCellBlock(indexPath.item);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZMainUnitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainUnitCell" forIndexPath:indexPath];
    if(_dataModel.isCountEnought && _dataModel.isChange){
      cell.dataModel = _dataModel.secondList[indexPath.item];
    }else{
      cell.dataModel = _dataModel.dataList[indexPath.item];  
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_dataModel.isCountEnought && _dataModel.isChange){
        return _dataModel.secondList.count > _dataModel.count * 2 ? _dataModel.count * 2 : _dataModel.secondList.count;
    }
    return _dataModel.dataList.count > _dataModel.count * 2 ? _dataModel.count * 2 : _dataModel.dataList.count;
}


@end
