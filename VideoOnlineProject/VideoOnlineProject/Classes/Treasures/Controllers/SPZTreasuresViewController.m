//
//  SPZTreasuresViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZTreasuresViewController.h"
#import "SPZTreasuresListCell.h"
#import "SPZUnitDataModel.h"
#import "SPZVideoPlayerViewController.h"

@interface SPZTreasuresViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*dataSource;

@end

@implementation SPZTreasuresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNum = 1;
    [self customTitleWith:@"精品"];
    [self setupTableView];
    [self getData];
}

-(void)getData{
    NSDictionary *dict = @{@"pageNum":@(_pageNum),
                           @"pageSize":@10,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeHotRecom parameters:dict success:^(id responseObject) {
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
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64 );
    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[SPZTreasuresListCell class] forCellReuseIdentifier:@"treasuresListCell"];
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 235;
    
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
    SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
    SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
    videoPlayerVC.Id = dataModel.Id;
    videoPlayerVC.isOpenVipTipView = dataModel.openStatus;
    videoPlayerVC.titleStr = dataModel.fileName;
    videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SPZTreasuresListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"treasuresListCell" forIndexPath:indexPath];
    cell.dataModel = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
