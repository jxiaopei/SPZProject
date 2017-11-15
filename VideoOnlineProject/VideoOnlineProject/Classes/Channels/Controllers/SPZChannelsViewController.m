//
//  SPZChannelsViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZChannelsViewController.h"
#import "SPZCategoryTitleCell.h"
#import "SPZChannelListCell.h"
#import "SPZPhotoViewController.h"
#import "SPZUnitDataModel.h"
#import "SPZChannelDataModel.h"
#import "SPZCategoriyListViewController.h"

@interface SPZChannelsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*itemsArr;
@property(nonatomic,strong)NSArray <SPZChannelDataModel *>*channelArr;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,copy)void (^didGetChannelsData)(NSArray <SPZChannelDataModel *>*channelArr);

@end

@implementation SPZChannelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    [self customTitleWith:@"频道"];
    [self setupTableView];
    [self getData];
    
}

-(void)getData{
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:VideoType parameters:@{} success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
           _channelArr = [SPZChannelDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
            self.didGetChannelsData(_channelArr);
            [_collectionView reloadData];
        }
    } fail:^(NSError *error) {
       [MBProgressHUD showError:@"网络错误"];
    }];
    
    NSDictionary *paramters = @{@"pageNum":@(_pageNum),
                                @"pageSize":@10,
                                };
    [[SPZNetworkTool getInstance]postJsonWithUrl:PhotoLikeList parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            if(_pageNum == 1){
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                _itemsArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];;
                if(!mutableArr.count)
                {
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshing];
                    [self.itemsArr addObjectsFromArray:mutableArr];
                }
            }
            [_tableView reloadData];
        }else{
            [_tableView.mj_header endRefreshing];
            [_tableView.mj_footer endRefreshing];
        }
      
        
    } fail:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
    }];
}

-(void)didClickCategoriesBtn:(UIButton *)sender{
    SPZChannelDataModel *dataModel = _channelArr[sender.tag];
    SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
    catListVC.vcType = VideoListType;
    catListVC.categoryId = dataModel.Id;
    catListVC.titleStr = dataModel.typeName;
    [self.navigationController pushViewController:catListVC animated:YES];
}

-(UIView *)setupHeaderView{
    
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH, 270);
    NSMutableArray *btnArr = [NSMutableArray new];
    for(int i = 0;i < 2;i++){
        UIButton *titleBtn = [UIButton new];
        [headerView addSubview:titleBtn];
        titleBtn.frame = CGRectMake(10 + ((SCREENWIDTH - 30)/2 + 10) * i, 10, (SCREENWIDTH - 30)/2, 100);
        [titleBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateNormal placeholderImage:ImagePlaceHolder];
        NSString *titleStr = @"分类";
        titleBtn.tag = i;
        [titleBtn setTitle:titleStr forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(didClickCategoriesBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr addObject:titleBtn];
    }
    
    self.didGetChannelsData = ^(NSArray <SPZChannelDataModel *>*channelArr){;
        for (int i = 0; i < btnArr.count; i++) {
            UIButton *titleBtn = btnArr[i];
            if(channelArr.count){
                SPZChannelDataModel *model = channelArr[i];
                [titleBtn setTitle:model.typeName forState:UIControlStateNormal];
                [titleBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:BaseHost(model.imageUrl)] forState:UIControlStateNormal placeholderImage:ImagePlaceHolder];
            }
        }
    };
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((SCREENWIDTH - 35)/4, 85);
//    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 5;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 120, SCREENWIDTH - 20, 85) collectionViewLayout:layout];
    [headerView addSubview:collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView = collectionView;
    collectionView.scrollEnabled = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[SPZCategoryTitleCell class] forCellWithReuseIdentifier:@"categoryTitleCell"];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(collectionView.mas_bottom).mas_offset(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];
    
    UIView *lineView1 = [UIView new];
    [headerView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(lineView.mas_bottom).mas_offset(25);
        make.height.mas_equalTo(1);
    }];
    lineView1.backgroundColor = [UIColor blackColor];
    
    UILabel *titleLabel = [UILabel new];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(lineView1);
        make.width.mas_equalTo(100);
    }];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = @"猜你喜欢";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    return headerView;
}

-(void)setupTableView
{
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);
    //    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[SPZChannelListCell class] forCellReuseIdentifier:@"channelListCell"];
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.rowHeight = 200;
    tableView.tableHeaderView = [self setupHeaderView];
    
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        _pageNum = 1;
        [self getData];
    }];
    tableView.mj_header = header;
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        _pageNum++;
        [self getData];
    }];
    tableView.mj_footer = footer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZPhotoViewController *photoVC = [SPZPhotoViewController new];
    SPZUnitDataModel *dataModel = _itemsArr[indexPath.row];
    photoVC.Id = dataModel.Id;
    photoVC.titleStr = dataModel.pictureName;
    [self.navigationController pushViewController:photoVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemsArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataModel = _itemsArr[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZChannelDataModel *dataModel = _channelArr[indexPath.item + 2];
    SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
    catListVC.vcType = VideoListType;
    catListVC.categoryId = dataModel.Id;
    catListVC.titleStr = dataModel.typeName;
    [self.navigationController pushViewController:catListVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZCategoryTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryTitleCell" forIndexPath:indexPath];
    SPZChannelDataModel *dataModel = _channelArr[indexPath.item + 2];
    cell.title.text = dataModel.typeName;
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:BaseHost(dataModel.imageUrl)] placeholderImage:ImagePlaceHolder];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _channelArr.count - 2;
}

-(NSArray <SPZChannelDataModel *>*)channelArr{
    if(_channelArr == nil){
        _channelArr = [NSArray new];
    }
    return _channelArr;
}

@end
