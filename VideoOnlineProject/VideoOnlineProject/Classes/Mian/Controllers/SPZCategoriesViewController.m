//
//  SPZCategoriesViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCategoriesViewController.h"
#import "SPZCategoriesCollectionViewCell.h"
#import "SPZMainTItleDataModel.h"
#import "SPZCategoriyListViewController.h"

@interface SPZCategoriesViewController ()<SDCycleScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

//banner
@property(nonatomic,strong)SDCycleScrollView *bannerView;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray <SPZMainTItleDataModel *>*categoriesArr;

@end

@implementation SPZCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupBannerView];
    [self setupCollectionView];
    [self customBackBtn];
    [self customTitleWith:@"分类"];
    [self getData];
}

-(void)getData{
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeCategory parameters:@{} success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _categoriesArr = [SPZMainTItleDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
            [_collectionView reloadData];
        }
        
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)setupBannerView{
    _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, 120) delegate:self placeholderImage:[UIImage imageNamed:@"占位图"]];
    _bannerView.layer.masksToBounds = YES;
    _bannerView.layer.cornerRadius = 10;
    [self.view addSubview:_bannerView];
    _bannerView.showPageControl = YES;
    _bannerView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
}

-(void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemW = (SCREENWIDTH - 30)/2;
    layout.itemSize = CGSizeMake(itemW,100);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, SCREENHEIGHT - 64 - 140) collectionViewLayout:layout];
    [collectView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    _collectionView = collectView;
    [self.view addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZCategoriesCollectionViewCell class] forCellWithReuseIdentifier:@"categoriesCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
 
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZMainTItleDataModel *dataModel = _categoriesArr[indexPath.item];
    SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
    catListVC.vcType = CategoryListType;
    catListVC.categoryId = dataModel.Id;
    catListVC.titleStr = dataModel.titleName;
    [self.navigationController pushViewController:catListVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZCategoriesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoriesCell" forIndexPath:indexPath];
    cell.dataModel = _categoriesArr[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  _categoriesArr.count;
}


@end
