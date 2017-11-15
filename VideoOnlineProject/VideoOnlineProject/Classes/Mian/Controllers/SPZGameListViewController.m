//
//  SPZGameListViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/3.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZGameListViewController.h"
#import "SPZGameListDataModel.h"
#import "SPZGameListTableViewCell.h"

#import "SPZBaseWebViewController.h"

@interface SPZGameListViewController ()<UITableViewDelegate, UITableViewDataSource,SDCycleScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property (nonatomic, strong) NSMutableArray <SPZGameListDataModel *>*dataArr;
@property (nonatomic, strong) SDCycleScrollView *bannerView;

@end

@implementation SPZGameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTitleWith:@"游戏推荐"];
    [self customBackBtn];
    [self setupTableView];
//    [self setupBannerView];
    [self getData];
}

-(void)getData{
    NSDictionary *dict = @{@"pageNum":@1,
                           @"pageSize":@10,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:GameList parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _dataArr = [SPZGameListDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
//            NSMutableArray *imageArr = [NSMutableArray array];
//            for(int i = 0; i < _dataArr.count;i++){
//                SPZGameListDataModel *model = _dataArr[i];
//                [imageArr addObject:model.gameBanner];
//            }
//            _bannerView.imageURLStringsGroup = imageArr;
            if(_pageNum == 1){
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                _dataArr = [SPZGameListDataModel  mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            }else{
                NSMutableArray *mutableArr = [NSMutableArray array];
                mutableArr = [SPZGameListDataModel  mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
                if(!mutableArr.count)
                {
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshing];
                    [self.dataArr addObjectsFromArray:mutableArr];
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

-(void)setupBannerView{
    _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREENWIDTH, 180) delegate:self placeholderImage:[UIImage imageNamed:@"占位图"]];
    [self.view addSubview:_bannerView];
    _bannerView.showPageControl = YES;
    _bannerView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
}

-(void)setupTableView
{
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);
    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[SPZGameListTableViewCell class] forCellReuseIdentifier:@"gameListCell"];
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 100;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZBaseWebViewController *partnerVC = [SPZBaseWebViewController new];
    partnerVC.title = self.dataArr[indexPath.section].gameName;
    partnerVC.urlString = [NSString stringWithFormat:@"https://%@",self.dataArr[indexPath.section].gameImageUrl];
    [self.navigationController pushViewController:partnerVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPZGameListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameListCell" forIndexPath:indexPath];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:self.dataArr[indexPath.row].icon] placeholderImage:[UIImage imageNamed:@"占位图"]];
    cell.titleLabel.text = self.dataArr[indexPath.row].gameName;
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
