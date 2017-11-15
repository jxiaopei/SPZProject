//
//  SPZUseHistoryViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/7.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZUseHistoryViewController.h"
#import "SPZUnitDataModel.h"
#import "SPZAttentionTableViewCell.h"
#import "SPZVideoPlayerViewController.h"
#import "SPZPhotoViewController.h"

@interface SPZUseHistoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*dataSource;
@property(nonatomic,strong)UIButton *editBtn;
@property(nonatomic,assign)BOOL isEditing;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)NSMutableArray <SPZUnitDataModel *>*selectArr;
@property(nonatomic,strong)UIButton *delectBtn;

@end

@implementation SPZUseHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isEditing = NO;
    _pageNum = 1;
    [self customTitleWith:@"浏览历史"];
    [self customBackBtn];
//    [self setupRightBtn];
    [self setupTableView];
    [self getData];
}

-(void)delectAttentionDataWithUnitId:(NSInteger)dataId{
    
    NSDictionary *dict = @{
                           @"id":@(dataId),
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:RemoveHistory parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            [self getData];
            [MBProgressHUD showSuccess:@"删除成功"];
        }else{
            [MBProgressHUD showError:@"删除失败"];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)setupRightBtn{
    
    UIButton *editBtn = [UIButton new];
    _editBtn = editBtn;
    editBtn.frame = CGRectMake(0, 0, 40, 30);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(didClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)didClickRightBtn:(UIButton *)sender{
    
    if([sender.titleLabel.text isEqualToString:@"取消"]){
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        _isEditing = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _bottomView.frame = CGRectMake(0, SCREENHEIGHT - 64, SCREENWIDTH, 44);
        }completion:^(BOOL finished) {
            if(_dataSource.count){
                for(int i = 0; i < _dataSource.count;i++){
                    SPZUnitDataModel *model = _dataSource[i];
                    model.isSelected = NO;
                }
            }
            [_selectArr removeAllObjects];
            _delectBtn = nil;
            [_bottomView removeFromSuperview];
        }];
    }else if([sender.titleLabel.text isEqualToString:@"编辑"]){
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        _isEditing = YES;
        [self initBottomView];
    }
    [self.tableView reloadData];
}

-(void)initBottomView{
    
    UIView *bottomView = [UIView new];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.frame = CGRectMake(0, SCREENHEIGHT - 64, SCREENWIDTH, 44);
    _bottomView = bottomView;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [bottomView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];
    
    UIView *verView = [UIView new];
    [bottomView addSubview:verView];
    [verView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(0);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(34);
    }];
    verView.backgroundColor = GlobalLightGreyColor;
    
    UIButton *allSelectBtn = [UIButton new];
    [bottomView addSubview:allSelectBtn];
    [allSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(verView.mas_left).mas_offset(-10);
    }];
    [allSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [allSelectBtn addTarget:self action:@selector(didClickAllSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *delectBtn = [UIButton new];
    [bottomView addSubview:delectBtn];
    [delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView.mas_right).mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.bottom.right.mas_equalTo(-10);
    }];
    _delectBtn = delectBtn;
    [delectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [delectBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delectBtn addTarget:self action:@selector(didClickDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.3 animations:^{
        bottomView.frame = CGRectMake(0, SCREENHEIGHT - 64 - 44, SCREENWIDTH, 44);
    }];
    
}

-(void)didClickAllSelectBtn:(UIButton *)sender{
    
}

-(void)didClickDelectBtn:(UIButton *)sender{
    
}

-(void)getData{
    NSDictionary *dict = @{@"pageNum":@(_pageNum),
                           @"pageSize":@10,
                           @"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:HistoryList parameters:dict success:^(id responseObject) {
        
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
    [tableView registerClass:[SPZAttentionTableViewCell class] forCellReuseIdentifier:@"historyListCell"];
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 100;
    
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
    SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
    if([dataModel.fileName isNotNil]){
        SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
        videoPlayerVC.Id = dataModel.filmId;
        videoPlayerVC.titleStr = dataModel.fileName;
        videoPlayerVC.videoPath = BaseHost(dataModel.pictPreviewPath);
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }else{
        SPZPhotoViewController *photoVC = [SPZPhotoViewController new];
        photoVC.Id = dataModel.pictureId;
        photoVC.titleStr = dataModel.pictureName;
        [self.navigationController pushViewController:photoVC animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SPZAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyListCell" forIndexPath:indexPath];
    SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
    cell.dataModel = dataModel;
    cell.isEditing = _isEditing;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.didClickCollectBtnBlock = ^(BOOL selected) {
        if(selected){
            dataModel.isSelected = YES;
            [self.selectArr addObject:dataModel];
            [_delectBtn setTitleColor:GlobalPurpleColor forState:UIControlStateNormal];
            [_delectBtn setTitle:[NSString stringWithFormat:@"删除(%zd)",self.selectArr.count] forState:UIControlStateNormal];
        }else{
            dataModel.isSelected = NO;
            [self.selectArr removeObject:_dataSource[indexPath.row]];
            if(self.selectArr.count == 0){
                [_delectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_delectBtn setTitle:@"删除" forState:UIControlStateNormal];
            }else{
                [_delectBtn setTitleColor:GlobalPurpleColor forState:UIControlStateNormal];
                [_delectBtn setTitle:[NSString stringWithFormat:@"删除(%zd)",self.selectArr.count] forState:UIControlStateNormal];
            }
        }
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:dataModel];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SPZUnitDataModel *dataModel = _dataSource[indexPath.row];
    [self delectAttentionDataWithUnitId: dataModel.Id];
}

-(NSMutableArray <SPZUnitDataModel *>*)selectArr{
    if(_selectArr == nil){
        _selectArr = [NSMutableArray new];
    }
    return _selectArr;
}

@end
