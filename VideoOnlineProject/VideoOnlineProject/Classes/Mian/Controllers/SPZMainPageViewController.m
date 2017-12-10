//
//  SPZMainPageViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZMainPageViewController.h"
#import "SPZMainTitleCollectionViewCell.h"
#import "SPZMainPageTableViewCell.h"
#import "SPZMainLikeCell.h"
#import "SPZCategoryListCell.h"

#import "SPZMainPageDataModel.h"
#import "SPZBannerDataModel.h"

#import "SPZCategoriesViewController.h"
#import "SPZCategoriyListViewController.h"
#import "SPZCatePhotoListViewController.h"
#import "SPZVideoPlayerViewController.h"
#import "SPZPhotoViewController.h"
#import "SPZSearchViewController.h"
#import "SPZGameListViewController.h"
#import "SPZAttentionListViewController.h"
#import "SPZUseHistoryViewController.h"

@interface SPZMainPageViewController()<UICollectionViewDelegate,UICollectionViewDataSource,SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)NSArray <SPZMainTItleDataModel *>*titleArr;
@property(nonatomic,strong)NSArray <SPZBannerDataModel *>*bannerList;
@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*likeList;
@property(nonatomic,strong)NSMutableArray <SPZMainPageDataModel *>*mainDataArr;

@property(nonatomic,strong)UICollectionView *titleCollectionView;
@property(nonatomic,strong)UICollectionView *likeCollectionView;
@property(nonatomic,strong)UITableView *tableView;
//banner
@property(nonatomic,strong)SDCycleScrollView *bannerView;
@property(nonatomic,assign)CGFloat advImgH;
@property(nonatomic,strong)UIView *navigationView;
@property(nonatomic,strong)UIView *navBottomView;

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*dataSource;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,assign)CGFloat topY;
@property(nonatomic,assign)NSInteger row;
@property(nonatomic,strong)UIView *noMoreDataView;

@property(nonatomic,assign)BOOL isAnimationPlaying;

@end

@implementation SPZMainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    _topY = kDevice_Is_iPhoneX ? 40 : 20;
    [self setNavigationView];
    [self setupScrollView];
    [self setupTableView];
    [self setupCollectionView];
}

-(void)getData{
    NSMutableDictionary *paramters = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomepageBanner parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _bannerList = [SPZBannerDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
            NSMutableArray *imageArr = [NSMutableArray array];
            NSMutableArray *titleArr = [NSMutableArray array];
            for(SPZBannerDataModel *bannerModel in _bannerList){
                [imageArr addObject:bannerModel.bannerImageUrl];
                [titleArr addObject:bannerModel.bannerTitle];
            }
            _bannerView.imageURLStringsGroup = imageArr;
            _bannerView.titlesGroup =titleArr;
        }
    } fail:^(NSError *error) {
       [MBProgressHUD showError:@"网络错误"];
    }];
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeCategory parameters:paramters success:^(id responseObject) {
       if([responseObject[@"currentStatus"] integerValue]  == 0){
           _titleArr = [SPZMainTItleDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
           [_titleCollectionView reloadData];
       }
    
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
    
    NSDictionary *dict = @{@"pageNum":@1,
                           @"pageSize":@10,
                           };
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeLikeList parameters:dict success:^(id responseObject) {
       
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _likeList = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            [_likeCollectionView reloadData];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeCatData parameters:@{} success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            NSArray <SPZUnitDataModel *>*dataArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"]];
            NSMutableArray *selectedArr = [NSMutableArray array];
            NSMutableArray *classicArr = [NSMutableArray array];
            NSMutableArray *beautiesArr = [NSMutableArray array];
            NSMutableArray *photoArr = [NSMutableArray array];
            [self.mainDataArr removeAllObjects];
            for(int i = 0;i < dataArr.count;i++){
                SPZUnitDataModel *model = dataArr[i];
                if(model.categoryId == 1){
                    [selectedArr addObject:model];
                }else if(model.categoryId == 3){
                    [classicArr addObject:model];
                }else if(model.categoryId == 4){
                    [beautiesArr addObject:model];
                }else if(model.categoryId == 5){
                    [photoArr addObject:model];
                }
            }
            if(selectedArr.count >0){
                SPZMainPageDataModel *mainModel = [SPZMainPageDataModel new];
                mainModel.dataList = selectedArr;
                mainModel.titleStr = @"精选推荐";
                [self.mainDataArr addObject:mainModel];
            }
            if(classicArr.count> 0){
                SPZMainPageDataModel *mainModel = [SPZMainPageDataModel new];
                mainModel.dataList = classicArr;
                mainModel.titleStr = @"经典推荐";
                [self.mainDataArr addObject:mainModel];
            }
            if(beautiesArr.count > 0){
                SPZMainPageDataModel *mainModel = [SPZMainPageDataModel new];
                mainModel.dataList = beautiesArr;
                mainModel.titleStr = @"美媛推荐";
                [self.mainDataArr addObject:mainModel];
            }
            if(photoArr.count > 0){
                SPZMainPageDataModel *mainModel = [SPZMainPageDataModel new];
                mainModel.dataList = photoArr;
                mainModel.titleStr = @"写真推荐";
                [self.mainDataArr addObject:mainModel];
            }
            _tableView.frame = CGRectMake(0, 0, SCREENWIDTH, 11 * 130 + (35 + 60)* 4 + 360 + _advImgH);
            _scrollView.contentSize = CGSizeMake(SCREENWIDTH, 11 * 130 + (35 + 60)* 4 + 360 + _advImgH);
             [_tableView reloadData];
            
            [self getRecommendToMeData];
        }
        
    } fail:^(NSError *error) {
        
        
    }];
}

-(void)getRecommendToMeData{
    NSDictionary *dic = @{@"pageNum":@(_pageNum),
                          @"pageSize":@6,
                          };
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeRecToMe parameters:dic success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            if(_pageNum == 1){
                [_scrollView.mj_header endRefreshing];
                [_scrollView.mj_footer endRefreshing];
                 _dataSource = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSArray *mutableArr  = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                if(!mutableArr.count)
                {
                    [_scrollView.mj_footer endRefreshingWithNoMoreData];
                    [self initNoMoreDataView];
                }else{
                    [_scrollView.mj_footer endRefreshing];
                    [_dataSource addObjectsFromArray:mutableArr.copy];
                }
            }
            NSInteger row = _dataSource.count % 2 == 1 ? _dataSource.count / 2 + 1 : _dataSource.count / 2;
            _row  = row ;
            _collectionView.frame = CGRectMake(10, 2170 + _advImgH + 35, SCREENWIDTH - 20, row * 130);
            if(!_noMoreDataView){
               _scrollView.contentSize = CGSizeMake(SCREENWIDTH, 2170 + _advImgH + 35 + row * 130);
            }
            [_collectionView reloadData];
        }else{
            [_scrollView.mj_header endRefreshing];
            [_scrollView.mj_footer endRefreshing];
        }
    } fail:^(NSError *error) {
        [_scrollView.mj_header endRefreshing];
        [_scrollView.mj_footer endRefreshing];
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)initNoMoreDataView{
    UIView *tipView = [UIView new];
    tipView.frame = CGRectMake(0, 2170 + _advImgH + 35 + _row * 130, SCREENWIDTH, 100);
    tipView.backgroundColor = [UIColor whiteColor];
    _noMoreDataView = tipView;
    UILabel *tipLabel = [UILabel new];
    [tipView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(200);
    }];
    tipLabel.text = @"─── 没有更多的数据了 ───";
    tipLabel.textColor = MJRefreshLabelTextColor;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *logoImage = [UIImageView new];
    [tipView addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(340/2.5);
        make.height.mas_equalTo(54/2.5);
    }];
    logoImage.image = [UIImage imageNamed:@"加载logo"];
    _scrollView.contentSize = CGSizeMake(SCREENWIDTH, 2170 + _advImgH + 35 + _row * 130 + 60);
    [self.scrollView addSubview:tipView];
}

-(UIView *)setupHeader{
    
    UIImage *advImage = [UIImage imageNamed:@"首页中间广告"];
    CGFloat imgW = advImage.size.width;
    CGFloat imgH = advImage.size.height;
    CGFloat advImgH = (SCREENWIDTH-20)/imgW * imgH;
    _advImgH = advImgH + 10;
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH, 360 + _advImgH);
    _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREENWIDTH, 180) delegate:self placeholderImage:[UIImage imageNamed:@"占位图"]];
    [headerView addSubview:_bannerView];
    _bannerView.showPageControl = YES;
    _bannerView.titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _bannerView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    _bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    
   
    UIImageView *advImageView = [UIImageView new];
    [headerView addSubview:advImageView];
    [advImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(190);
        make.height.mas_equalTo(advImgH);
    }];
    advImageView.image = advImage;
//    advImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIView *verView = [UIView new];
    [headerView addSubview:verView];
    verView.frame = CGRectMake(10, 190 + _advImgH, 2, 15);
    verView.backgroundColor = GlobalPurpleColor;
    
    UILabel *titleLabel = [UILabel new];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(verView.mas_centerY);
    }];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = @"猜你喜欢";
    
    UIButton *showMoreBtn = [UIButton new];
    [headerView addSubview:showMoreBtn];
    [showMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(verView.mas_centerY);
    }];
    [showMoreBtn setTitle:@"更多>" forState:UIControlStateNormal];
    showMoreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [showMoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [showMoreBtn addTarget:self action:@selector(didClickShowMoreActionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(150,130);
    layout.minimumInteritemSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 225 + _advImgH, SCREENWIDTH - 20, 130) collectionViewLayout:layout];
    _likeCollectionView = collectView;
    [headerView addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    collectView.tag = 200;
    [collectView registerClass:[SPZMainLikeCell class] forCellWithReuseIdentifier:@"mainLikeCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    
    UIView *lineView = [UIView new];
    [headerView addSubview:lineView];
    lineView.frame = CGRectMake(0, 355+ _advImgH, SCREENWIDTH, 5);
    lineView.backgroundColor = GlobalLightGreyColor;
    
    return headerView;
}

-(void)didClickShowMoreActionBtn:(UIButton *)sender{
    SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
    catListVC.vcType = LikeListType;
    catListVC.titleStr = @"猜你喜欢";
    [self.navigationController pushViewController:catListVC animated:YES];
}

-(void)setupScrollView
{
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = CGRectMake(0, _topY + 90, SCREENWIDTH, SCREENHEIGHT - _topY - 90 - 49);
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    scrollView.tag = 1000;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(SCREENWIDTH , SCREENHEIGHT - 64 - 49);
    
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        _pageNum = 1;
        if(_noMoreDataView){
            [_noMoreDataView removeFromSuperview];
            _noMoreDataView = nil;
        }
        [self getData];
        [self getRecommendToMeData];
        
    }];
    scrollView.mj_header = header;
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        _pageNum++;
        [self getRecommendToMeData];
    }];
    scrollView.mj_footer = footer;
}

-(void)setupTableView{
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [_scrollView addSubview:tableView];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - _topY - 90 - 49);
    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.scrollEnabled  = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[SPZMainPageTableViewCell class] forCellReuseIdentifier:@"mainPageCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.tableHeaderView = [self setupHeader];
}

-(void)setupCollectionView{
    
    UIView *verView = [UIView new];
    [self.scrollView addSubview:verView];
    verView.frame = CGRectMake(10, 10 + _advImgH + 2170, 2, 15);
    verView.backgroundColor = GlobalPurpleColor;
    
    UILabel *titleLabel = [UILabel new];
    [self.scrollView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(verView.mas_centerY);
    }];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = @"为我推荐";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemW = (SCREENWIDTH - 30)/2;
    layout.itemSize = CGSizeMake(itemW,120);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 2170 + _advImgH + 35 , SCREENWIDTH - 20, 120) collectionViewLayout:layout];
    [collectView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    _collectionView = collectView;
    [_scrollView addSubview:collectView];
    collectView.tag = 300;
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZCategoryListCell class] forCellWithReuseIdentifier:@"recommendMeCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
}

-(void)setNavigationView{

    UIView *navigationView = [UIView new];
    navigationView.frame = CGRectMake(0, 0, SCREENWIDTH, _topY + 90);
    navigationView.backgroundColor = GlobalPurpleColor;
    _navigationView = navigationView;
    [self.view addSubview:navigationView];
    UIButton *showMoreBtn = [UIButton new];
    [navigationView addSubview: showMoreBtn];
    [showMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(_topY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(60);
    }];
    [showMoreBtn setImage:[UIImage imageNamed:@"更多"] forState:UIControlStateNormal];
    [showMoreBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [showMoreBtn addTarget:self action:@selector(didClickShowMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemW = (SCREENWIDTH - 60 - 15)/5;
    layout.itemSize = CGSizeMake(itemW,40);
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _topY, SCREENWIDTH - 60, 40 ) collectionViewLayout:layout];
    _titleCollectionView = collectView;
    [navigationView addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    collectView.tag = 100;
    [collectView registerClass:[SPZMainTitleCollectionViewCell class] forCellWithReuseIdentifier:@"mainTitleCell"];
    collectView.backgroundColor = GlobalPurpleColor;
    
    UIView *navBottomView = [UIView new];
    [navigationView addSubview:navBottomView];
    navBottomView.frame = CGRectMake(0, _topY + 50, SCREENWIDTH, 40);
    _navBottomView = navBottomView;
    UISearchBar *searchBar = [UISearchBar new];
    [navBottomView addSubview:searchBar];
    searchBar.frame = CGRectMake(5, 0, SCREENWIDTH - 30 - 90 - 20 + 15  , 30);
    searchBar.barStyle = UIBarStyleDefault;
    [searchBar setBackgroundImage:[UIImage new]];
    searchBar.placeholder = @"搜索关键字";
    searchBar.tintColor = GlobalPurpleColor;
    searchBar.delegate = self;
    NSArray *titleArr = @[@"游戏推荐",@"历史",@"收藏列表"];
    for(int i = 0;i < titleArr.count;i++){
        UIButton *btn = [UIButton new];
        [navBottomView addSubview:btn];
        btn.frame = CGRectMake(SCREENWIDTH - 30 - 90 + i * 40, 0, 30, 30);
        btn.tag = 100 * (i + 1);
        [btn setImage:[UIImage imageNamed:titleArr[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClickTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(void)didClickTitleBtn:(UIButton *)sender{
    if(sender.tag == 100){
        //点击游戏推荐
        SPZGameListViewController *gameListVC = [SPZGameListViewController new];
        [self.navigationController pushViewController:gameListVC animated:YES];
        
    }else if (sender.tag == 200){
        //点击历史
        SPZUseHistoryViewController *histroyVC = [SPZUseHistoryViewController new];
        [self.navigationController pushViewController:histroyVC animated:YES];
    }else if (sender.tag == 300){
        //收藏列表
//        [MBProgressHUD showSuccess:@"敬请期待"];
        SPZAttentionListViewController *attentionListVC = [SPZAttentionListViewController new];
        [self.navigationController pushViewController:attentionListVC animated:YES];
    }
}

-(void)didClickShowMoreBtn:(UIButton *)sender{
    SPZCategoriesViewController *categoriesVC = [SPZCategoriesViewController new];
    [self.navigationController pushViewController:categoriesVC animated:YES];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if(scrollView.tag == 1000){
//        NSLog(@"%f",velocity.y);
        if(velocity.y > 0 ){
            if(!_isAnimationPlaying){
                _isAnimationPlaying = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    _navigationView.frame = CGRectMake(0, 0, SCREENWIDTH, _topY + 45);
                    _navBottomView.frame = CGRectMake(0, _topY + 5, SCREENWIDTH, 40);
                    _scrollView.frame = CGRectMake(0, _topY + 45, SCREENWIDTH, SCREENHEIGHT - _topY - 45 - 49);
                    _navBottomView.alpha = 0;
                }completion:^(BOOL finished) {
                    _isAnimationPlaying = NO;
                }];
            }
        }else{
            if(!_isAnimationPlaying){
                _isAnimationPlaying = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    _navigationView.frame = CGRectMake(0, 0, SCREENWIDTH, _topY + 90);
                    _navBottomView.frame = CGRectMake(0, _topY + 50, SCREENWIDTH, 40);
                    _scrollView.frame = CGRectMake(0, _topY + 90, SCREENWIDTH, SCREENHEIGHT - _topY - 90 - 49);
                    _navBottomView.alpha = 1;
                }completion:^(BOOL finished) {
                    _isAnimationPlaying = NO;
                }];
            }
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mainDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZMainPageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainPageCell" forIndexPath:indexPath];
    SPZMainPageDataModel *mainModel = self.mainDataArr[indexPath.row];
    cell.dataModel = mainModel;
    cell.didClickCollectionCellBlock = ^(NSInteger index) {
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        SPZUnitDataModel *dataModel =nil;
        if(mainModel.isChange && mainModel.isCountEnought){
           dataModel = mainModel.secondList[index];
        }else{
           dataModel = mainModel.dataList[index];
        }
        videoPlayerVC.Id = dataModel.Id;
        videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
        videoPlayerVC.titleStr = dataModel.fileName;
        videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    };
    cell.didClickShowMoreBtnBlock = ^{
        SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
        catListVC.vcType = CategoryListType;
        catListVC.categoryId = mainModel.dataList[0].categoryId;
        catListVC.titleStr = mainModel.titleStr;
        [self.navigationController pushViewController:catListVC animated:YES];
    };
    cell.didChangeAGroupsDataBtnBlock = ^{
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SPZMainPageDataModel *mainModel = self.mainDataArr[indexPath.row];
    if(indexPath.row == 0){
        mainModel.count = 4;
    }else if(indexPath.row == 1){
        mainModel.count = 2;
    }else if(indexPath.row == 2){
        mainModel.count = 3;
    }else if(indexPath.row == 3){
        mainModel.count = 2;
    }
    NSInteger row = mainModel.dataList.count % 2 ? mainModel.dataList.count / 2 + 1 : mainModel.dataList.count /2;
    row = row > mainModel.count ? mainModel.count : row;
    return row * 130  +  35 + 60;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView.tag == 200){
        return self.likeList.count > 8 ? 8 : self.likeList.count ;
    }else if (collectionView.tag == 100){
        return _titleArr.count;
    }
    return _dataSource.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView.tag == 100){
        SPZMainTItleDataModel *dataModel = _titleArr[indexPath.item];
        if(dataModel.type){
            SPZCatePhotoListViewController *catePhotoListVC = [SPZCatePhotoListViewController new];
            catePhotoListVC.titleStr = dataModel.titleName;
            [self.navigationController pushViewController:catePhotoListVC animated:YES];
        }else{
            SPZCategoriyListViewController *catListVC = [SPZCategoriyListViewController new];
            catListVC.vcType = CategoryListType;
            catListVC.categoryId = dataModel.Id;
            catListVC.titleStr = dataModel.titleName;
            [self.navigationController pushViewController:catListVC animated:YES];
        }
        
    }else if (collectionView.tag == 200){
        SPZUnitDataModel *dataModel = _likeList[indexPath.row];
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
        videoPlayerVC.Id = dataModel.Id;
        videoPlayerVC.titleStr = dataModel.fileName;
        videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }else if (collectionView.tag == 300){
        SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
        videoPlayerVC.Id = dataModel.Id;
        videoPlayerVC.titleStr = dataModel.fileName;
        videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView.tag == 200){
        SPZMainLikeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainLikeCell" forIndexPath:indexPath];
        cell.dataModel = _likeList[indexPath.item];
        return cell;
    }else if(collectionView.tag == 100){
        
        SPZMainTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainTitleCell" forIndexPath:indexPath];
        cell.dataModel = _titleArr[indexPath.item];
        return cell;
    }else{
        
        SPZCategoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"recommendMeCell" forIndexPath:indexPath];
        cell.dataModel = _dataSource[indexPath.item];
        return cell;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    SPZSearchViewController *searchVC = [SPZSearchViewController new];
    [self.navigationController pushViewController:searchVC animated:YES];
    return NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self getData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

-(NSMutableArray <SPZMainPageDataModel *>*)mainDataArr{
    if(_mainDataArr == nil){
        _mainDataArr = [NSMutableArray array];
    }
    return _mainDataArr;
}

@end
