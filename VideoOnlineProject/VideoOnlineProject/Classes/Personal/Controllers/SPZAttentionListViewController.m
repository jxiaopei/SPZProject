//
//  SPZAttentionListViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/2.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZAttentionListViewController.h"
#import "SPZUnitDataModel.h"
#import "SPZAttentionTableViewCell.h"
#import "SPZVideoPlayerViewController.h"
#import "SPZPhotoViewController.h"

@interface SPZAttentionListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*dataSource;

@property(nonatomic,strong)UITableView *picTableView;
@property(nonatomic,assign)NSInteger picPageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*picDataSource;

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIButton *selectedBtn;
@property(nonatomic,strong)UIView *underLineView;
@property(nonatomic,strong)UIView *titleView;


@end

@implementation SPZAttentionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    _picPageNum = 1;
    [self customTitleWith:@"我的收藏"];
    [self customBackBtn];
    [self setupScrollView];
    [self setupTitleView];
    [self setupTableView];
    [self getPicData];
    [self getVideoData];
}

-(void)delectAttentionVideoWithId:(NSInteger)videoId{

    NSDictionary *dict = @{
                           @"id":@(videoId),
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:RemoveVideoAtten parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            [self getVideoData];
            [MBProgressHUD showSuccess:@"取消收藏成功"];
        }else{
            [MBProgressHUD showSuccess:@"操作失败"];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)delectAttentionPictureWithId:(NSInteger)pictureId{
    NSDictionary *dict = @{
                           @"id":@(pictureId),
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:RemovePicAtten parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            [self getPicData];
            [MBProgressHUD showSuccess:@"取消收藏成功"];
        }else{
            [MBProgressHUD showSuccess:@"操作失败"];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)setupScrollView
{
    UIScrollView *scrollView = [UIScrollView new];
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, 40, SCREENWIDTH, SCREENHEIGHT - 64 - 40);
    _scrollView = scrollView;
    scrollView.tag = 1000;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(SCREENWIDTH *2, SCREENHEIGHT - 64 - 40);
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


-(void)getPicData{
    
    NSDictionary *paramters = @{
                                @"pageNum":@(_picPageNum),
                                @"pageSize":@10,
                                @"userId":[SPZUserModel shareModel].uid,
                                };
    
    [[SPZNetworkTool getInstance]postJsonWithUrl:AttenPicList parameters:paramters success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
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
        [MBProgressHUD showError:@"网络错误"];
    }];

}

-(void)getVideoData{
    NSDictionary *dict = @{@"pageNum":@(_pageNum),
                           @"pageSize":@10,
                           @"userId":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:AttenVideoList parameters:dict success:^(id responseObject) {
        
        if([responseObject[@"currentStatus"] integerValue]  == 0){
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
        [tableView registerClass:[SPZAttentionTableViewCell class] forCellReuseIdentifier:@"attentionListCell"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tableFooterView = [UIView new];
        tableView.rowHeight = 100;
        
        MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            if(tableView.tag == 0){
                _pageNum = 1;
                [self getVideoData];
            }else{
                _picPageNum = 1;
                [self getPicData];
            }
            
        }];
        tableView.mj_header = header;
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            if(tableView.tag == 0){
                _pageNum ++;
                [self getVideoData];
            }else{
                _picPageNum ++;
                [self getPicData];
            }
            
        }];
        tableView.mj_footer = footer;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZUnitDataModel *dataModel = nil;
    if(tableView.tag  == 0){
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        dataModel = _dataSource[indexPath.row];
        videoPlayerVC.Id = dataModel.Id;
        videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
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
    
    SPZAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attentionListCell" forIndexPath:indexPath];
    SPZUnitDataModel *dataModel = nil;
    if(tableView.tag ==0){
        dataModel = _dataSource[indexPath.row];
    }else{
        dataModel = _picDataSource[indexPath.row];
    }
    cell.dataModel = dataModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 0){
        SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
        [self delectAttentionVideoWithId:dataModel.Id];
    }else{
        SPZUnitDataModel *picDataModel = _picDataSource[indexPath.row];
        [self delectAttentionPictureWithId:picDataModel.Id];
    }
}


@end
