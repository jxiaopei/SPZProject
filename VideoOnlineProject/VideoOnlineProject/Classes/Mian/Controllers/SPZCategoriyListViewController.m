//
//  SPZCategoriyListViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCategoriyListViewController.h"
#import "SPZCategoryListCell.h"
#import "SPZItemDataModel.h"
#import "SPZVideoPlayerViewController.h"

@interface SPZCategoriyListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*itemsArr;
@property(nonatomic,assign)NSInteger pageNum;

@end

@implementation SPZCategoriyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    [self setupCollectionView];
    [self customBackBtn];
    [self getData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customTitleWith:_titleStr];
}

-(void)getData{
    
    NSDictionary *paramters = nil;
    NSString *url = nil;
    
    if(_vcType == LikeListType){
        paramters = @{@"pageNum":@(_pageNum),
                      @"pageSize":@10,
                      };
        url = HomeLikeList;
    }else if(_vcType == CategoryListType){
        paramters = @{@"pageNum":@(_pageNum),
                      @"pageSize":@10,
                      @"categoryId":@(_categoryId),
                      };
        url = CategoryList;
    }else if(_vcType == VideoListType){
        paramters = @{@"pageNum":@(_pageNum),
                      @"pageSize":@10,
                      @"videoTypeId":@(_categoryId),
                      };
        url = SmallChannelList;
    }else{
        paramters = @{@"pageNum":@(_pageNum),
                      @"pageSize":@10,
                      };
        url = HomeRecommend;
    }
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:url parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            if(_pageNum == 1){
                [_collectionView.mj_header endRefreshing];
                [_collectionView.mj_footer endRefreshing];
                if(_vcType == CategoryListType ){
                   _itemsArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
                }else if (_vcType == LikeListType || _vcType == RecommendType || _vcType == VideoListType){
                   _itemsArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                }
               
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                if(_vcType == CategoryListType ){
                    mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
                }else if (_vcType == LikeListType || _vcType == RecommendType || _vcType == VideoListType){
                    mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                }
                if(!mutableArr.count)
                {
                    [_collectionView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_collectionView.mj_footer endRefreshing];
                    [self.itemsArr addObjectsFromArray:mutableArr];
                }
            }
            [_collectionView reloadData];
        }else{
            [_collectionView.mj_header endRefreshing];
            [_collectionView.mj_footer endRefreshing];
        }
    } fail:^(NSError *error) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
    }];
}

-(void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemW = (SCREENWIDTH - 30)/2;
    layout.itemSize = CGSizeMake(itemW,120);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, SCREENHEIGHT - 64) collectionViewLayout:layout];
    [collectView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    _collectionView = collectView;
    [self.view addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZCategoryListCell class] forCellWithReuseIdentifier:@"categoriesListCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        _pageNum = 1;
        [self getData];
    }];
    collectView.mj_header = header;
    
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        _pageNum++;
        [self getData];
    }];
    collectView.mj_footer = footer;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZUnitDataModel *dataModel = _itemsArr[indexPath.row];
    SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
    videoPlayerVC.Id = dataModel.Id;
    videoPlayerVC.titleStr = dataModel.fileName;
    videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZCategoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoriesListCell" forIndexPath:indexPath];
    cell.dataModel = _itemsArr[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemsArr.count;
}


@end
