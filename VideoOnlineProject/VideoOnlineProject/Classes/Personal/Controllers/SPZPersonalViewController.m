//
//  SPZPersonalViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZPersonalViewController.h"
#import "SPZPersonalTableViewCell.h"
#import "SPZCleanCacheManager.h"

#import "SPZAboutUsViewController.h"
#import "SPZServiceCenterViewController.h"
#import "SPZAttentionListViewController.h"
#import "SPZUseHistoryViewController.h"

@interface SPZPersonalViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSArray *titleArr;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIImageView *iconView;
@property(nonatomic,strong)UILabel *userNameLabel;

@property(nonatomic,strong)UILabel *cacheLabel;
@end

@implementation SPZPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTitleWith:@"我的"];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLoginSuccessed) name:@"loginSuccessed" object:nil];
    [self setupTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _cacheLabel.text = [NSString stringWithFormat:@"%.2fM",[SPZCleanCacheManager folderSizeAtPath]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginSuccessed" object:nil];
}

-(void)setupTableView
{
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64 - 49);
    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.bounces = NO;
    tableView.rowHeight = 50;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[SPZPersonalTableViewCell class] forCellReuseIdentifier:@"personalCell"];
    tableView.tableFooterView = [UIView new];
    tableView.tableHeaderView = [self setHeadView];
}

-(UIView *)setHeadView{
    
    UIView *header = [UIView new];
    header.frame = CGRectMake(0, 0, SCREENWIDTH, 100);
    header.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconView = [UIImageView new];
    [header addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(70);
    }];
    iconView.image = [UIImage imageNamed:@"默认头像"];
    
    UILabel *accountLabel = [UILabel new];
    [header addSubview:accountLabel];
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconView.mas_right).mas_offset(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(iconView);
    }];
    accountLabel.text = [SPZUserModel shareModel].uid;
    accountLabel.font = [UIFont systemFontOfSize:15];
    accountLabel.numberOfLines = 2;
    
    UILabel *levelLabel = [UILabel new];
    [header addSubview:levelLabel];
    [levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconView.mas_right).mas_offset(15);
        make.top.mas_equalTo(accountLabel.mas_bottom).mas_offset(10);
    }];
    levelLabel.text = @"普通用户";
    levelLabel.textColor = GlobalPurpleColor;
    levelLabel.font = [UIFont systemFontOfSize:14];
    
    UIButton *vipBtn = [UIButton new];
    [header addSubview:vipBtn];
    [vipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(iconView);
    }];
    [vipBtn setImage:[UIImage imageNamed:@"开通vip"] forState:UIControlStateNormal];
    vipBtn.hidden = YES;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [header addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(5);
    }];
    
    return header;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
//        [MBProgressHUD showSuccess:@"敬请期待"];
        SPZAttentionListViewController *attentionListVC = [SPZAttentionListViewController new];
        [self.navigationController pushViewController:attentionListVC animated:YES];
        
    }else if (indexPath.row == 1){
        SPZUseHistoryViewController *histroyVC = [SPZUseHistoryViewController new];
        [self.navigationController pushViewController:histroyVC animated:YES];
        
    }else if(indexPath.row == 2){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理缓存" message:@"确定要清理缓存吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            CGFloat cacheSize = [SPZCleanCacheManager folderSizeAtPath];
            NSString *baseURL = BaseHttpUrl;
            
            [SPZCleanCacheManager cleanCache:^{
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"成功清理%.2fM缓存空间",cacheSize]];
                 _cacheLabel.text = [NSString stringWithFormat:@"%.2fM",[SPZCleanCacheManager folderSizeAtPath]];
                [[YYCache cacheWithName:CacheKey] setObject:baseURL forKey: @"serviceHost"];
            }];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:commitAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (indexPath.row == 3){
//        SPZServiceCenterViewController *serviceCenterVC = [SPZServiceCenterViewController new];
//        [self.navigationController pushViewController:serviceCenterVC animated:YES];
//    }else if (indexPath.row == 4){
        SPZAboutUsViewController *aboutUsVC = [SPZAboutUsViewController new];
        [self.navigationController pushViewController:aboutUsVC animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.titleArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZPersonalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
    cell.titleLabel.text = _titleArr[indexPath.row];
    cell.iconView.image = [UIImage imageNamed:_titleArr[indexPath.row]];
    if(indexPath.row == 2){
        _cacheLabel = cell.detailLabel;
    }//else if (indexPath.row == 3){
//       cell.detailLabel.text = @"客服qq: 695830000";
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(NSArray *)titleArr{
    
    if(_titleArr == nil){
        _titleArr = @[@"我的收藏",@"浏览历史",@"清理缓存",@"关于我们"];//@"联系客服",
    }
    return _titleArr;
}

@end
