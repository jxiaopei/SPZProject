//
//  SPZCatePhotoListViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/23.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZCatePhotoListViewController.h"
#import "SPZPhotoViewController.h"
#import "SPZUnitDataModel.h"
#import "SPZPhotoRecCollectionViewCell.h"

@interface SPZCatePhotoListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView *photoView;
@property(nonatomic,assign)CGFloat imgH;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*itemsArr;

@end

@implementation SPZCatePhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    _imgH = (SCREENWIDTH/2 - 15) * 1.5 + 2;
    [self customBackBtn];
    [self setupCollectionView];
    [self getData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customTitleWith:_titleStr];
}

-(void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(SCREENWIDTH/2 - 15,(SCREENWIDTH/2 - 15) * 1.5);
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 10, SCREENWIDTH - 20, SCREENHEIGHT - 64) collectionViewLayout:layout];
    _photoView = collectView;
    [self.view addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZPhotoRecCollectionViewCell class] forCellWithReuseIdentifier:@"photosCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    
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

-(void)getData{
    NSDictionary *paramters = @{@"pageNum":@(_pageNum),
                                @"pageSize":@10,
                                };
    [[SPZNetworkTool getInstance]postJsonWithUrl:PhotoLikeList parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            if(_pageNum == 1){
                [_photoView.mj_header endRefreshing];
                [_photoView.mj_footer endRefreshing];
                _itemsArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];;
                if(!mutableArr.count)
                {
                    [_photoView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_photoView.mj_footer endRefreshing];
                    [self.itemsArr addObjectsFromArray:mutableArr];
                }
            }
            [_photoView reloadData];
        }else{
            [_photoView.mj_header endRefreshing];
            [_photoView.mj_footer endRefreshing];
        }
        
        
    } fail:^(NSError *error) {
        [_photoView.mj_header endRefreshing];
        [_photoView.mj_footer endRefreshing];
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZPhotoViewController *photoVC = [SPZPhotoViewController new];
    SPZUnitDataModel *dataModel = _itemsArr[indexPath.row];
    photoVC.Id = dataModel.Id;
    photoVC.titleStr = dataModel.pictureName;
    [self.navigationController pushViewController:photoVC animated:YES];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZPhotoRecCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photosCell" forIndexPath:indexPath];
    cell.dataModel = _itemsArr[indexPath.item];
    return cell;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemsArr.count;
}
@end
