//
//  SPZSearchViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/2.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZSearchViewController.h"
#import "SPZAttentionTableViewCell.h"
#import "SPZUnitDataModel.h"
#import "SPZVideoPlayerViewController.h"
#import "SPZPhotoViewController.h"
#import "SPZSearchHisCollectionViewCell.h"

@interface SPZSearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)UITableView *picTableView;
@property(nonatomic,assign)NSInteger picPageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*dataSource;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*picDataSource;
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,assign)BOOL isSearching;

@property(nonatomic,strong)NSMutableArray *historyArr;
@property(nonatomic,strong)UICollectionView *historyCollectionView;
@property(nonatomic,strong)UILabel *noDataLabel;
@property(nonatomic,strong)UIView *historyView;
@property(nonatomic,copy)NSString *searchStr;

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIButton *selectedBtn;
@property(nonatomic,strong)UIView *underLineView;
@property(nonatomic,strong)UIView *titleView;

@end

@implementation SPZSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    _picPageNum = 1;
    [self setupNavigationBar];
    [self setupTitleView];
    [self setupScrollView];
    [self setupTableView];
    [self setupHeader];
}

-(void)setupNavigationBar{
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.frame = CGRectMake(0, 0, SCREENWIDTH - 90, 30);
    searchBar.barTintColor = GlobalPurpleColor;
    [searchBar setBackgroundImage:[UIImage new]];
    searchBar.tintColor = [UIColor whiteColor];
    searchBar.placeholder = @"搜索关键字";
    searchBar.delegate = self;
    _searchBar = searchBar;
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:searchBar];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [searchBar becomeFirstResponder];
    
    UIButton *cancelBtn = [UIButton new];
    _cancelBtn = cancelBtn;
    cancelBtn.frame = CGRectMake(0, 0, 40, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(didClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)didClickRightBtn:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self setupHeader];
    NSLog(@"%zd",self.historyArr.count);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _isSearching = YES;
    NSString *searchStr = searchBar.text;
    _searchStr = searchStr;
    BOOL isHaveWord =NO;
    if(self.historyArr.count){
        for(NSString *str in self.historyArr){
            if([searchStr isEqualToString:str]){
                isHaveWord = YES;
            }
        }
    }
    if(!isHaveWord){
      [self.historyArr addObject:searchStr];
      [[YYCache cacheWithName:CacheKey] setObject:self.historyArr forKey:@"searchHisArr"];
    }
    [self getDataWithSearchStr:searchStr];
}

-(void)getDataWithSearchStr:(NSString *)str{
    [self searchPicWithSearchStr:str];
    [self searchVideoWithSearchStr:str];
}

-(void)searchVideoWithSearchStr:(NSString *)str{
    NSDictionary *dict = @{@"pageNum":@(_pageNum),
                           @"pageSize":@10,
                           @"fileName":str,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:SearchVideoList parameters:dict success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _scrollView.hidden = NO;
            if(_historyView){
                [_historyView removeFromSuperview];
                _historyView = nil;
            }
            if(_pageNum == 1){
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                _dataSource = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                if(!mutableArr.count)
                {
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshing];
                    [self.dataSource addObjectsFromArray:mutableArr];
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
        [_historyCollectionView reloadData];
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)searchPicWithSearchStr:(NSString *)str{
    NSDictionary *paramters = @{
                                @"pageNum":@(_picPageNum),
                                @"pageSize":@10,
                                @"pictureName":str,
                                };
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:SearchPhotoList parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _scrollView.hidden = NO;
            if(_historyView){
                [_historyView removeFromSuperview];
                _historyView = nil;
            }
            if(_picPageNum == 1){
                [_picTableView.mj_header endRefreshing];
                [_picTableView.mj_footer endRefreshing];
                _picDataSource = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                mutableArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                if(!mutableArr.count){
                    [_picTableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_picTableView.mj_footer endRefreshing];
                    [self.picDataSource addObjectsFromArray:mutableArr];
                }
            }
            [_picTableView reloadData];
        }else{
            [_picTableView.mj_header endRefreshing];
            [_picTableView.mj_footer endRefreshing];
        }
    } fail:^(NSError *error) {
        [_picTableView.mj_header endRefreshing];
        [_picTableView.mj_footer endRefreshing];
        [_historyCollectionView reloadData];
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)setupTableView
{
    for(int i = 0;i < 2;i++)
    {
        UITableView *tableView = [UITableView new];
        [_scrollView addSubview:tableView];
        tableView.tag = i;
        if(i == 1){
            self.picTableView = tableView;
        }else if (i == 0){
            self.tableView = tableView;
        }
        tableView.frame = CGRectMake(SCREENWIDTH *i, 0, SCREENWIDTH, SCREENHEIGHT - 64 - 40);
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[SPZAttentionTableViewCell class] forCellReuseIdentifier:@"searchListCell"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        tableView.tableFooterView = [UIView new];
        tableView.rowHeight = 100;
        
        MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            if(tableView.tag == 0){
                _pageNum = 1;
                [self searchVideoWithSearchStr:_searchStr];
            }else{
                _picPageNum = 1;
                [self searchPicWithSearchStr:_searchStr];
            }
            
        }];
        tableView.mj_header = header;
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            if(tableView.tag == 0){
                _pageNum ++;
                [self searchVideoWithSearchStr:_searchStr];
            }else{
                _picPageNum ++;
                [self searchPicWithSearchStr:_searchStr];
            }
           
        }];
        tableView.mj_footer = footer;
    }
}

-(void)setupScrollView
{
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = CGRectMake(0, 40, SCREENWIDTH, SCREENHEIGHT - 64 - 40);
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    scrollView.tag = 1000;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(SCREENWIDTH *2, SCREENHEIGHT - 64 - 40);
    scrollView.hidden = YES;
}

-(void)setupTitleView
{
    UIView *titleView = [UIView new];
    [self.view addSubview:titleView];
    _titleView = titleView;
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    NSArray *titleArr = @[@"视频",@"图片"];
    for(int i = 0 ; i < titleArr.count;i++)
    {
        UIButton *btn = [UIButton new];
        [titleView addSubview:btn];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(i * SCREENWIDTH/2, 0, SCREENWIDTH/2, 36);
        btn.tag = i;
        [btn addTarget:self action:@selector(didClickTitleViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        if(i == 0)
        {
            [self didClickTitleViewBtn:btn];
            btn.selected = YES;
            self.selectedBtn = btn;
            UIView *underLineView = [UIView new];
            [titleView addSubview:underLineView];
            _underLineView = underLineView;
            underLineView.frame = CGRectMake(0, 35, SCREENWIDTH/2, 3);
            underLineView.backgroundColor = GlobalPurpleColor;
        }
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tag == 1000)
    {
        CGFloat offsetX =scrollView.contentOffset.x;
        if(offsetX == SCREENWIDTH || offsetX == 0)
        {
            NSInteger tag =  offsetX/SCREENWIDTH;
            for(int i = 0;i < _titleView.subviews.count ; i++)
            {
                if([_titleView.subviews[i] isKindOfClass:[UIButton class]])
                {
                    if(tag == _titleView.subviews[i].tag )
                    {
                        UIButton *btn = _titleView.subviews[i];
                        btn.selected = YES;
                        self.selectedBtn.selected = NO;
                        self.selectedBtn = btn;
                        [self didClickTitleViewBtn:btn];
                    }
                }
            }
        }
    }
}

-(void)didClickTitleViewBtn:(UIButton *)sender
{
    [_scrollView setContentOffset:CGPointMake(sender.tag * SCREENWIDTH, 0) animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        _underLineView.frame = CGRectMake(SCREENWIDTH/2 * sender.tag, 35, SCREENWIDTH/2, 3);
    }];
}

-(void)setupHeader{
    if(_historyView){
        [_historyCollectionView reloadData];
        return;
    }
    UIView *headerView = [UIView new];
    _historyView = headerView;
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);
    NSInteger count = self.historyArr.count;
    
    
    NSInteger row = count % 2 == 0 ? count /2 : count / 2 + 1;
    
    UIButton *delectHisBtn = [UIButton new];
    [headerView addSubview:delectHisBtn];
    [delectHisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(10);
        make.width.height.mas_equalTo(30);
    }];
    [delectHisBtn setImage:[UIImage imageNamed:@"删除历史记录"] forState:UIControlStateNormal];
    [delectHisBtn addTarget:self action:@selector(didClickDelectHisBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [UILabel new];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(delectHisBtn);
    }];
    titleLabel.text = @"历史搜索";
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((SCREENWIDTH - 30)/2,40);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 5;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 45, SCREENWIDTH, 40 + (row - 1)* 45) collectionViewLayout:layout];
    _historyCollectionView = collectView;
    [headerView addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    [collectView registerClass:[SPZSearchHisCollectionViewCell class] forCellWithReuseIdentifier:@"searchHisCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    
    UILabel *nodataLabel = [UILabel new];
    [headerView addSubview:nodataLabel];
    _noDataLabel = nodataLabel;
    [nodataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(60);
    }];
    nodataLabel.text = @"暂无搜索历史";
    nodataLabel.font = [UIFont systemFontOfSize:14];
    nodataLabel.textColor = [UIColor grayColor];
    
    if(count != 0){
        nodataLabel.hidden = YES;
    }else{
        nodataLabel.hidden = NO;
    }
    
    [self.view addSubview:headerView];
}

-(void)didClickDelectHisBtn:(UIButton *)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要删除所有搜索历史吗?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.historyArr removeAllObjects];
        [[YYCache cacheWithName:CacheKey] setObject:self.historyArr forKey:@"searchHisArr"];
        [_historyCollectionView reloadData];
        _noDataLabel.hidden = NO;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:commitAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchBar.text = self.historyArr[indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.historyArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZSearchHisCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchHisCell" forIndexPath:indexPath];
    NSString *title = _historyArr[indexPath.item];
    cell.titleLabel.text = title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    SPZUnitDataModel *dataModel = nil;
    if(tableView.tag ==0){
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        dataModel = _dataSource[indexPath.row];
        videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
        videoPlayerVC.Id = dataModel.Id;
        videoPlayerVC.titleStr = dataModel.fileName;
        videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }else{
        dataModel = _picDataSource[indexPath.row];
        SPZPhotoViewController *photoVC = [SPZPhotoViewController new];
        photoVC.Id = dataModel.Id;
        photoVC.titleStr = dataModel.pictureName;
        [self.navigationController pushViewController:photoVC animated:YES];

    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView.tag == 0){
        return _dataSource.count;
    }else{
        return _picDataSource.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SPZAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchListCell" forIndexPath:indexPath];
    SPZUnitDataModel *dataModel = nil;
    if(tableView.tag  == 0){
       dataModel = _dataSource[indexPath.row];
    }else{
        dataModel = _picDataSource[indexPath.row];
    }
    cell.dataModel = dataModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSMutableArray *)historyArr{
    if(_historyArr == nil){
        _historyArr = [SPZUserModel shareModel].searchHisArr;
    }
    return _historyArr;
}

@end
