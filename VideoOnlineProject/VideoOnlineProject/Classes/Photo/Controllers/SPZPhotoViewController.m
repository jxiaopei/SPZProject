//
//  SPZPhotoViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/30.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZPhotoViewController.h"
#import "SCAdView.h"
#import "SDPhotoBrowser.h"
#import "SPZUnitDataModel.h"
#import "SPZPhotoRecCollectionViewCell.h"
#import "SPZCommentDataModel.h"
#import "SPZCommentTableViewCell.h"

@interface SPZPhotoViewController ()<SCAdViewDelegate,SDPhotoBrowserDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)SCAdView *adView;
@property(nonatomic,strong)SCAdViewBuilder *advBuilder;
@property(nonatomic,strong)NSArray *imageArr;
@property(nonatomic,assign)NSInteger index;

@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*likeList;
@property(nonatomic,strong)UICollectionView *collectView;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray <SPZCommentDataModel *>*dataSource;
@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*dataModelArr;
@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*baseInforModelArr;

@property(nonatomic,assign)BOOL isVip;
@property(nonatomic,strong)UIButton *attentionBtn;

@property(nonatomic,assign)NSInteger seconds;
@property(nonatomic,strong)UIView *markView;
@property(nonatomic,assign)NSInteger bottomSeconds;

@end

@implementation SPZPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self customBackBtn];
    _imageArr = @[@"占位图",@"占位图",@"占位图"];
    UILabel *tipLabel = [UILabel new];
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(20);
    }];
    tipLabel.text = @"点击浏览全屏大图";
    tipLabel.font = [UIFont systemFontOfSize:13];
    [self setupPhotoScrollView];
    [self setupTableView];
    [self setupRightBtn];
    [self getData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customTitleWith:_titleStr];
    [self getVipState];
}

-(void)getVipState{
    NSDictionary *dict = @{@"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:ComfirmVipRight parameters:dict success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            if([responseObject[@"currentStatus"] integerValue]  == 0){
                _isVip = YES;
            }else if ([responseObject[@"currentStatus"] integerValue]  == 1){
                _isVip = NO;
            }
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)getData{
    NSDictionary *dict = @{@"id":@(_Id),
                           @"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:PhotoDetail parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _dataModelArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray :responseObject[@"currentData"][@"pictureParentList"]];
            _baseInforModelArr = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray :responseObject[@"currentData"][@"isOwned"]];
            if(_baseInforModelArr.count){
              _attentionBtn.selected = _baseInforModelArr[0].isOwned;
            }
            
            if(_dataModelArr.count){
              
                NSMutableArray *imageArr = [NSMutableArray array];
                for(SPZUnitDataModel *dataModel in _dataModelArr){
                    [imageArr addObject:[NSURL URLWithString:BaseHost(dataModel.previewPath)]];
                }
                if(imageArr.count){
                    _imageArr = imageArr.copy;
                    if(imageArr.count == 1){
                        self.advBuilder.scrollEnabled = NO;
                        self.advBuilder.allowedInfinite = NO;
                    }else{
                        self.advBuilder.scrollEnabled = YES;
                        self.advBuilder.allowedInfinite = YES;
                    }
                    [self.adView reloadWithDataArray:imageArr];
            }
            
            }
        }
        
    } fail:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [MBProgressHUD showError:@"网络错误"];
    }];
    
    NSDictionary *parameters = @{@"pageNum":@1,
                                 @"pageSize":@10,
                                 };
    [[SPZNetworkTool getInstance]postJsonWithUrl:PhotoLikeList parameters:parameters success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _likeList = [SPZUnitDataModel mj_objectArrayWithKeyValuesArray:responseObject[@"currentData"][@"currentData"]];
            [_collectView reloadData];
        }
    } fail:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [MBProgressHUD showError:@"网络错误"];
    }];
    
}

-(void)setupRightBtn{
    UIButton *attentionBtn = [UIButton new];
    attentionBtn.frame = CGRectMake(0, 0, 30, 30);
    _attentionBtn = attentionBtn;
    [attentionBtn setImage: [UIImage imageNamed: @"未收藏"] forState:UIControlStateNormal];
    [attentionBtn setImage: [UIImage imageNamed: @"收藏"] forState:UIControlStateSelected];
    [attentionBtn addTarget:self action:@selector(didClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:attentionBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)didClickRightBtn:(UIButton *)sender{
    if(sender.selected){
        NSDictionary *dict = @{@"pictureId":@(_Id),
                               @"userId":[SPZUserModel shareModel].uid,
                               };
        [[SPZNetworkTool getInstance]postJsonWithUrl:CancelPicAtten parameters:dict success:^(id responseObject) {
            if([responseObject[@"currentStatus"] integerValue]  == 0){
                sender.selected = YES;
                [MBProgressHUD showSuccess:@"取消收藏成功"];
            }else{
                [MBProgressHUD showSuccess:@"操作失败"];
            }
            
        } fail:^(NSError *error) {
            [MBProgressHUD showError:@"网络错误"];
        }];
        
    }else{
        NSDictionary *dict = @{@"pictureId":@(_Id),
                               @"userId":[SPZUserModel shareModel].uid,
                               };
        [[SPZNetworkTool getInstance]postJsonWithUrl:AttenPicAction parameters:dict success:^(id responseObject) {
            if([responseObject[@"currentStatus"] integerValue]  == 0){
                sender.selected = YES;
                [MBProgressHUD showSuccess:@"收藏成功"];
            }else{
                [MBProgressHUD showSuccess:@"操作失败"];
            }
            
        } fail:^(NSError *error) {
            [MBProgressHUD showError:@"网络错误"];
        }];
    }
}

-(void)setupPhotoScrollView
{
    SCAdView *adView = [[SCAdView alloc] initWithBuilder:^(SCAdViewBuilder *builder) {
        builder.adArray =_imageArr;
        builder.viewFrame = (CGRect){0,40,SCREENWIDTH,150};
        builder.adItemSize = (CGSize){SCREENWIDTH/1.8,100};
        builder.minimumLineSpacing = 0;
        builder.secondaryItemMinAlpha = 0.6;
        builder.threeDimensionalScale = 1.45;
        builder.itemCellClassName = @"SPZPhotoCollectionViewCell";
        self.advBuilder = builder;
    }];
    adView.backgroundColor = [UIColor whiteColor];
    adView.delegate = self;
    _adView = adView;
    [self.view addSubview:adView];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = GlobalLightGreyColor;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(adView.mas_bottom).mas_offset(20);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(5);
    }];
    
}

-(UIView *)setupHeaderView{
    
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH,230);
    //    headerView.backgroundColor = [UIColor yellowColor];
    UIView *verView = [UIView new];
    [headerView addSubview:verView];
    verView.frame = CGRectMake(10, 0, 2, 15);
    verView.backgroundColor = GlobalPurpleColor;
    
    UILabel *titleLabel = [UILabel new];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(verView.mas_centerY);
    }];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = @"猜你喜欢";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(180,150);
    layout.minimumInteritemSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 20, SCREENWIDTH - 20, 150) collectionViewLayout:layout];
    _collectView = collectView;
    [headerView addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZPhotoRecCollectionViewCell class] forCellWithReuseIdentifier:@"photoRecoCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    
    UIView *lineView = [UIView new];
    [headerView addSubview:lineView];
    lineView.frame = CGRectMake(0, 175, SCREENWIDTH, 5);
    lineView.backgroundColor = GlobalLightGreyColor;
    
    UIView *verView1 = [UIView new];
    [headerView addSubview:verView1];
    verView1.frame = CGRectMake(10, 190, 2, 15);
    verView1.backgroundColor = GlobalPurpleColor;
    
    UILabel *titleLabel1 = [UILabel new];
    [headerView addSubview:titleLabel1];
    [titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(verView1.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(verView1.mas_centerY);
    }];
    titleLabel1.font = [UIFont systemFontOfSize:13];
    titleLabel1.text = @"评论";
    
    return headerView;
}

-(void)setupTableView{
    UITableView *tableView = [UITableView new];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 225, SCREENWIDTH, SCREENHEIGHT - 64);
    //    tableView.backgroundColor = GlobalLightGreyColor;
    tableView.dataSource = self;
    tableView.delegate =self;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[SPZCommentTableViewCell class] forCellReuseIdentifier:@"commentCell"];
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 180;
    tableView.tableHeaderView = [self setupHeaderView];
    
}

//-(void)initVipView{
//    
//    UIView *markView = [UIView new];
//    markView.backgroundColor = GlobalMarkViewColor;
//    markView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);
//    _markView = markView;
//    
//    UIImageView *vipBackImage = [UIImageView new];
//    [markView addSubview:vipBackImage];
//    [vipBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(10);
//        make.right.mas_equalTo(-10);
//        make.top.mas_equalTo(80);
//        make.height.mas_equalTo(SCREENWIDTH - 20);
//    }];
//    vipBackImage.image = [UIImage imageNamed:@"vip背景图片"];
//    
//    UILabel *titleLabel = [UILabel new];
//    [vipBackImage addSubview:titleLabel];
//    titleLabel.font = [UIFont systemFontOfSize:20];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = @"点击图片注册VIP";
//    
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.top.mas_equalTo((SCREENWIDTH - 20)/6);
//    }];
//    
//    UILabel *detailLabel = [UILabel new];
//    [vipBackImage addSubview:detailLabel];
//    detailLabel.numberOfLines = 2;
//    detailLabel.font = [UIFont systemFontOfSize:15];
//    detailLabel.textColor = [UIColor whiteColor];
//    detailLabel.text = @"尚未开通会员或会员已过期,开通会员可享受高清无码大片!";
//    
//    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(10);
//        make.left.mas_equalTo(60);
//        make.right.mas_equalTo(-60);
//    }];
//    
//    UIImageView *contactImgView = [UIImageView new];
//    [vipBackImage addSubview:contactImgView];
//    [contactImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(detailLabel.mas_bottom).mas_offset(10);
//        make.left.mas_equalTo(60);
//        make.right.mas_equalTo(-60);
//        make.centerX.mas_equalTo(0);
//    }];
//    contactImgView.userInteractionEnabled = YES;
//    contactImgView.image = ImagePlaceHolder;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickContactImgView:)];
//    [contactImgView addGestureRecognizer:tap];
//    
//    UIButton *cancelBtn = [UIButton new];
//    [markView addSubview:cancelBtn];
//    [cancelBtn setImage:[UIImage imageNamed:@"关闭关闭Vip弹窗"] forState:UIControlStateNormal];
//    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(vipBackImage.mas_top).mas_offset(10);
//        make.right.mas_equalTo(-40);
//        make.width.height.mas_equalTo(30);
//    }];
//    [cancelBtn addTarget:self action:@selector(didClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *comfirmBtn = [UIButton new];
//    [markView addSubview:comfirmBtn];
//    [comfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.bottom.mas_equalTo(vipBackImage.mas_bottom).mas_offset(-(SCREENWIDTH - 20)/5);
//        make.width.mas_equalTo(SCREENWIDTH - 140);
//        make.height.mas_equalTo(30);
//    }];
//    comfirmBtn.backgroundColor = [UIColor whiteColor];
//    comfirmBtn.layer.masksToBounds = YES;
//    comfirmBtn.layer.cornerRadius = 5;
//    comfirmBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//    [comfirmBtn setTitle:@"确认已注册" forState:UIControlStateNormal];
//    [comfirmBtn setTitleColor:GlobalPurpleColor forState:UIControlStateNormal];
//    [comfirmBtn addTarget:self action:@selector(didClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
//        
//    [self.view addSubview:markView];
//}

-(void)didClickContactImgView:(UITapGestureRecognizer *)tap{
    
}

-(void)didClickComfirmRegistBtn:(UIButton *)sender{
    NSDictionary *dict = @{@"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:ComfirmVipRegist parameters:dict success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _isVip = YES;
        }else if ([responseObject[@"currentStatus"] integerValue]  == 1){
            _isVip = NO;
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)didClickCancelBtn:(UIButton *)sender{
    [_markView removeFromSuperview];
}


- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    
//    if(index > 3){
//        [self initVipView];
//        return [UIImage new];
//    }
    
    if([self.imageArr[index]isKindOfClass:[NSString class]]){
      return [UIImage imageNamed:self.imageArr[index]];
    }else{
        return ImagePlaceHolder;
    }
    
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return self.imageArr[index];
}

-(void)sc_didClickAd:(id)adModel{
    NSLog(@"sc_didClickAd-->%@",adModel);
    SDPhotoBrowser *browser = [SDPhotoBrowser new];
    browser.sourceImagesContainerView = self.view;
    browser.imageCount = _imageArr.count;
    browser.currentImageIndex = _index;//当前需要展示图片的index
    browser.delegate = self;
    [browser show];
}

-(void)sc_scrollToIndex:(NSInteger)index{
    
    _index = index%_imageArr.count;
//    if(_index > 3){
//        [self initVipView];
//    }
    NSLog(@"sc_scrollToIndex-->%ld",_index);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZPhotoViewController *photoVC = [SPZPhotoViewController new];
    SPZUnitDataModel *dataModel = _likeList[indexPath.item];
    photoVC.Id = dataModel.Id;
    photoVC.titleStr = dataModel.pictureName;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPZPhotoRecCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoRecoCell" forIndexPath:indexPath];
    cell.dataModel = _likeList[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _likeList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SPZCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    cell.dataModel = self.dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
