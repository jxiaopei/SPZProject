//
//  SPZVideoPlayerViewController.m
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/30.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import "SPZVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SPZUnitDataModel.h"
#import "SPZCommentDataModel.h"
#import "SPZCommentTableViewCell.h"
#import "SPZMainLikeCell.h"
#import "SPZBaseWebViewController.h"

@interface SPZVideoPlayerViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UIView *backView;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
//底部BottmView
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *fullScreenButton;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,strong) UILabel *nowLabel;
@property (nonatomic,strong) UILabel *remainLabel;
//是否全屏
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,strong) UIButton *backBtn;
//自动消失定时器
@property (nonatomic,strong) NSTimer *autoDismissTimer;
@property (nonatomic,assign) BOOL isDragSlider;

@property (nonatomic,strong) UIButton *attentionBtn;

@property(nonatomic,strong)NSArray <SPZUnitDataModel *>*likeList;
@property(nonatomic,strong)UICollectionView *collectView;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray <SPZCommentDataModel *>*dataSource;
@property(nonatomic,strong)SPZUnitDataModel *dataModel;

@property(nonatomic,assign)NSInteger seconds;
@property(nonatomic,strong)UIView *markView;
@property(nonatomic,assign)NSInteger bottomSeconds;

@property(nonatomic,assign)BOOL isVip;
@property(nonatomic,assign)BOOL isHavePush;
//@property(nonatomic,copy)NSString *registUrl;
@property(nonatomic,assign)CGSize imageSize;

@end

@implementation SPZVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self customBackBtn];
    [self setupPlayerUI];
    [self setupTableView];
    [self setupRightBtn];
    _isVip = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customTitleWith:_titleStr];
    [self getVipState];
    [self getData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
}

-(void)dealloc{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
}

-(void)getVipState{
    NSDictionary *dict = @{@"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:ComfirmVipRight parameters:dict success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _isVip = YES;
        }else if ([responseObject[@"currentStatus"] integerValue]  == 1){
            _isVip = NO;
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
    }];
}

-(void)getData{
    NSDictionary *dict = @{@"id":@(_Id),
                           @"mediaUID":[SPZUserModel shareModel].uid,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:VideoDetail parameters:dict success:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _dataModel = [SPZUnitDataModel mj_objectWithKeyValues:responseObject[@"currentData"][0]];
            _attentionBtn.selected = _dataModel.isOwned;
        }
    } fail:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [MBProgressHUD showError:@"网络错误"];
    }];
    
    NSDictionary *parameters = @{@"pageNum":@1,
                                 @"pageSize":@10,
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:HomeLikeList parameters:parameters success:^(id responseObject) {
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
        NSDictionary *dict = @{@"videoId":@(_Id),
                               @"userId":[SPZUserModel shareModel].uid,
                               };
        [[SPZNetworkTool getInstance]postJsonWithUrl:CancelVideoAtten parameters:dict success:^(id responseObject) {
            if([responseObject[@"currentStatus"] integerValue]  == 0){
                sender.selected = NO;
                [MBProgressHUD showSuccess:@"取消收藏成功"];
            }else{
                [MBProgressHUD showSuccess:@"操作失败"];
            }
            
        } fail:^(NSError *error) {
            [MBProgressHUD showError:@"网络错误"];
        }];
        
    }else{
        NSDictionary *dict = @{@"videoId":@(_Id),
                               @"userId":[SPZUserModel shareModel].uid,
                               };
        [[SPZNetworkTool getInstance]postJsonWithUrl:AttenVideoAction parameters:dict success:^(id responseObject) {
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

-(UIView *)setupHeaderView{
    
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, SCREENWIDTH,190);
//    headerView.backgroundColor = [UIColor yellowColor];
    UIView *verView = [UIView new];
    [headerView addSubview:verView];
    verView.frame = CGRectMake(10, 10, 2, 15);
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
    layout.itemSize = CGSizeMake(150,130);
    layout.minimumInteritemSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 30, SCREENWIDTH - 20, 130) collectionViewLayout:layout];
    _collectView = collectView;
    [headerView addSubview:collectView];
    collectView.delegate = self;
    collectView.dataSource = self;
    [collectView registerClass:[SPZMainLikeCell class] forCellWithReuseIdentifier:@"videoLikeCell"];
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.showsVerticalScrollIndicator = NO;
    
    UIView *lineView = [UIView new];
    [headerView addSubview:lineView];
    lineView.frame = CGRectMake(0, 160, SCREENWIDTH, 5);
    lineView.backgroundColor = GlobalLightGreyColor;
    
    UIView *verView1 = [UIView new];
    [headerView addSubview:verView1];
    verView1.frame = CGRectMake(10, 175, 2, 15);
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
    tableView.frame = CGRectMake(0, SCREENWIDTH / 1.5, SCREENWIDTH, SCREENHEIGHT - 64 - 49 - SCREENWIDTH / 1.5);
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

- (void)setupPlayerUI{
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH/1.5)];
    self.backView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backView];
    
    // 初始化播放器
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: _videoPath]];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
     _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH/1.5);
    [self.backView.layer addSublayer:self.playerLayer];
    
    // 监听播放器状态变化
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓存大小
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //添加手势动作,隐藏下面的进度条
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.backView addGestureRecognizer:tap];
    
    // 布局底部功能栏
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.backView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    // 播放或暂停
    self.playButton = [UIButton new];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    self.playButton.showsTouchWhenHighlighted = YES;
    [self.bottomView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    //播放
    [self.playButton addTarget:self action:@selector(pauseOrPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    // 底部全屏按钮
    self.fullScreenButton = [UIButton new];
    [self.fullScreenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    self.fullScreenButton.showsTouchWhenHighlighted = YES;
    [self.bottomView addSubview:self.fullScreenButton];

    self.fullScreenButton.frame = CGRectMake(SCREENWIDTH - 35, 0, 30, 30);
    //点击全屏
    [self.fullScreenButton addTarget:self action:@selector(clickFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    // 底部进度条
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 0.0;
    self.slider.minimumTrackTintColor = [UIColor greenColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.value = 0.0;
    [self.slider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    [self.bottomView addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.playButton.mas_right).offset(5);
        make.right.mas_equalTo(self.fullScreenButton.mas_left).offset(-5);
        make.centerY.equalTo(self.bottomView);
        
    }];
    [self.slider addTarget:self action:@selector(sliderDragValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSlider:)];
    [self.slider addGestureRecognizer:tapSlider];
    [self.bottomView addSubview:self.slider];
    // 底部缓存进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor blueColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:self.progressView];
    [self.progressView setProgress:0.0 animated:NO];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.slider);
        make.height.mas_equalTo(2);
        make.centerY.mas_equalTo(self.slider).mas_offset(1);
    }];
    [self.bottomView sendSubviewToBack:self.progressView];
    
    // 底部左侧时间轴
    self.nowLabel = [[UILabel alloc] init];
    self.nowLabel.textColor = [UIColor whiteColor];
    self.nowLabel.font = [UIFont systemFontOfSize:13];
    self.nowLabel.textAlignment = NSTextAlignmentLeft;
    [self.bottomView addSubview:self.nowLabel];
    [self.nowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.slider);
        make.top.mas_equalTo(self.slider.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    self.nowLabel.hidden = YES;
    
    // 底部右侧时间轴
    self.remainLabel = [[UILabel alloc] init];
    self.remainLabel.textColor = [UIColor whiteColor];
    self.remainLabel.font = [UIFont systemFontOfSize:13];
    self.remainLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomView addSubview:self.remainLabel];
    [self.remainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.slider);
        make.top.mas_equalTo(self.slider.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    self.remainLabel.hidden =YES;
}

#pragma mark - 暂停或者播放
- (void)pauseOrPlay:(UIButton *)sender{
    if(_isHavePush){
        [self initVipViewWithTitle:@"点击图片注册VIP" detail:@"尚未开通会员或会员已过期,开通会员可享受高清无码大片!"];
        return;
    }
    if (self.player.rate != 1){
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.player play];
        _seconds = 0;
    }else{
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.player pause];
    }
}
#pragma mark - 点击全屏按钮
- (void)clickFullScreen:(UIButton *)button{
    
    if (!self.isFullScreen){
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        [self.fullScreenButton setImage:[UIImage imageNamed:@"nonfullscreen@3x"] forState:UIControlStateNormal];
    }else{
        [self toSmallScreen];
        [self.fullScreenButton setImage:[UIImage imageNamed:@"fullscreen@3x"] forState:UIControlStateNormal];
    }
    self.isFullScreen = !self.isFullScreen;
}
#pragma mark - 显示全屏
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    // 先移除之前的
    [self.backView removeFromSuperview];
    // 初始化
    self.backView.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        self.backView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        self.backView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    // BackView 全屏
    self.backView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    // layer的方向宽和高对调
    self.playerLayer.frame = CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH);
    
    self.backBtn = [UIButton new];
    [self.backView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.backBtn setImage:[UIImage imageNamed:@"返回键"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(clickFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(SCREENWIDTH-50);
        make.left.equalTo(self.backView).with.offset(0);
        make.width.mas_equalTo(SCREENHEIGHT);
    }];
    
    self.fullScreenButton.frame = CGRectMake(SCREENHEIGHT - 55, 10, 30, 30);
    
    [self.nowLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider.mas_left).with.offset(0);
        make.top.equalTo(self.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    [self.remainLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.slider.mas_right).with.offset(0);
        make.top.equalTo(self.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    // 加到window上面
    [[UIApplication sharedApplication].keyWindow addSubview:self.backView];
    
}
#pragma mark - 缩小全屏
-(void)toSmallScreen{
    // 先移除
    [self.backBtn removeFromSuperview];
    [self.backView removeFromSuperview];
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        weakSelf.backView.transform = CGAffineTransformIdentity;
        weakSelf.backView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH / 1.5);
        weakSelf.playerLayer.frame =  weakSelf.backView.bounds;
        [weakSelf.view addSubview:weakSelf.backView];

        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        self.fullScreenButton.frame = CGRectMake(SCREENWIDTH - 35, 0, 30, 30);
        
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 单击手势
- (void)singleTap:(UITapGestureRecognizer *)tap{
    
    [UIView animateWithDuration:1.0 animations:^{
        if (self.bottomView.alpha == 1)
        {
            self.bottomView.alpha = 0;
        }else if (self.bottomView.alpha == 0){
            self.bottomView.alpha = 1;
        }
    }];
}

#pragma mark - slider的更改
// 不更新视频进度
- (void)sliderDragValueChange:(UISlider *)slider
{
    if(!_isVip){
        return;
    }
    self.isDragSlider = YES;
}
// 点击调用  或者 拖拽完毕的时候调用
- (void)sliderTapValueChange:(UISlider *)slider
{
    if(!_isVip){
        [self initVipViewWithTitle:@"点击图片注册VIP" detail:@"自由操控进度,想看哪就看哪,开通会员可享受高清无码大片!"];
        [self.player pause];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        return;
    }
    self.isDragSlider = NO;
    // 直接用秒来获取CMTime
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.playerItem.currentTime.timescale)];
}

// 点击Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap
{
    if(!_isVip){
        [self initVipViewWithTitle:@"点击图片注册VIP" detail:@"自由操控进度,想看哪就看哪,开通会员可享受高清无码大片!"];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.player pause];
        return;
    }
    // 根据点击的坐标计算对应的比例
    CGPoint touch = [tap locationInView:self.slider];
    CGFloat scale = touch.x / self.slider.bounds.size.width;
    self.slider.value = CMTimeGetSeconds(self.playerItem.duration) * scale;
    [self.player seekToTime:CMTimeMakeWithSeconds(self.slider.value, self.playerItem.currentTime.timescale)];
    if (self.player.rate != 1)
    {
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.player play];
    }
}


// 监听播放器的变化属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus statues = [change[NSKeyValueChangeNewKey] integerValue];
        switch (statues) {
            case AVPlayerItemStatusReadyToPlay:
                self.slider.maximumValue = CMTimeGetSeconds(self.playerItem.duration);
                [self initTimer];
                // 自动隐藏底栏
                if (!self.autoDismissTimer)
                {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(autoDismissView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }
                break;
            case AVPlayerItemStatusUnknown:
                
                break;
            case AVPlayerItemStatusFailed:
                
                break;
                
            default:
                break;
        }
    }
    // 监听缓存进度的属性
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        // 计算缓存进度
        NSTimeInterval timeInterval = [self availableDuration];
        // 获取总长度
        CMTime duration = self.playerItem.duration;
        
        CGFloat durationTime = CMTimeGetSeconds(duration);
        // 监听到了给进度条赋值
        [self.progressView setProgress:timeInterval / durationTime animated:NO];
    }

}

//调用plaer进行UI更新
- (void)initTimer
{
    //player的定时器
    __weak typeof(self)weakSelf = self;
    // 每秒更新一次UI Slider
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前时间
        CGFloat nowTime = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
        //总时间
        CGFloat duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        //sec 转换成时间点
        weakSelf.nowLabel.text = [weakSelf convertToTime:nowTime];
        weakSelf.remainLabel.text = [weakSelf convertToTime:(duration - nowTime)];
        //不是拖拽中的话更新UI
        if (!weakSelf.isDragSlider)
        {
            weakSelf.slider.value = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
        }
        
    }];
}
//自动隐藏底部功能栏
- (void)autoDismissView:(NSTimer *)timer{
    
    if (self.player.rate == 1){
        
        if(!_isVip){
            if(_seconds == 60){
                [self initVipViewWithTitle:@"点击图片注册VIP" detail:@"尚未开通会员或会员已过期,开通会员可享受高清无码大片!"];
                _bottomSeconds = 0;
                self.bottomView.alpha = 1;
                [self.player pause];
                [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//                self.playButton.enabled = NO;
                self.isHavePush = YES;
                return;
            }
        }
        _seconds++;
        _bottomSeconds++;
    
        if(_bottomSeconds % 8 == 0){
            [UIView animateWithDuration:2.0 animations:^{
                self.bottomView.alpha = 0;
            }];
        }
    }
}

-(void)initVipViewWithTitle:(NSString *)title detail:(NSString *)detail{
    
    UIView *markView = [UIView new];
    markView.backgroundColor = GlobalMarkViewColor;
    _markView = markView;
    
    CGFloat imgW = SCREENWIDTH - 20;
    
    UIImageView *vipBackImage = [UIImageView new];
    [markView addSubview:vipBackImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickContactImgView:)];
    [vipBackImage addGestureRecognizer:tap];
    vipBackImage.userInteractionEnabled = YES;
    
//    UILabel *titleLabel = [UILabel new];
//    [vipBackImage addSubview:titleLabel];
//    titleLabel.font = [UIFont systemFontOfSize:20];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = title;
//
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.top.mas_equalTo((SCREENWIDTH - 20)/6);
//    }];
//
//    UILabel *detailLabel = [UILabel new];
//    [vipBackImage addSubview:detailLabel];
//    detailLabel.numberOfLines = 2;
//    detailLabel.font = [UIFont systemFontOfSize:14];
////    detailLabel.adjustsFontSizeToFitWidth = YES;
//    detailLabel.textColor = [UIColor whiteColor];
//    detailLabel.text = detail;
//
//    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(10);
//        make.centerX.mas_equalTo(0);
//        make.width.mas_equalTo((SCREENWIDTH - 20)*0.65);
//    }];
//
//    UIImageView *contactImgView = [UIImageView new];
//    [vipBackImage addSubview:contactImgView];
//    [contactImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(detailLabel.mas_bottom).mas_offset(10);
//        make.centerX.mas_equalTo(0);
//        make.width.mas_equalTo((SCREENWIDTH - 20)*0.65);
//        make.height.mas_equalTo((SCREENWIDTH - 20)*0.25);
//    }];
//    contactImgView.userInteractionEnabled = YES;
//    [contactImgView sd_setImageWithURL:[NSURL URLWithString:BaseHost(_dataModel.registerPic)] placeholderImage:ImagePlaceHolder];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickContactImgView:)];
//    [contactImgView addGestureRecognizer:tap];
    
    UIButton *cancelBtn = [UIButton new];
    [markView addSubview:cancelBtn];
    [cancelBtn setImage:[UIImage imageNamed:@"关闭Vip弹窗"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(didClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *comfirmBtn = [UIButton new];
    [markView addSubview:comfirmBtn];
    comfirmBtn.backgroundColor = [UIColor whiteColor];
    comfirmBtn.layer.masksToBounds = YES;
    comfirmBtn.layer.cornerRadius = 5;
    comfirmBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [comfirmBtn setTitle:@"确认已注册" forState:UIControlStateNormal];
    [comfirmBtn setTitleColor:GlobalPurpleColor forState:UIControlStateNormal];
    [comfirmBtn addTarget:self action:@selector(didClickComfirmRegistBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.isFullScreen){
        markView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        markView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        
        [vipBackImage sd_setImageWithURL:[NSURL URLWithString:BaseHost(_dataModel.registerPic)] placeholderImage:ImagePlaceHolder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            [vipBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo((SCREENHEIGHT- imgW)/2);
                make.top.mas_equalTo((SCREENWIDTH - image.size.height * imgW / image.size.width)/2);
                make.height.mas_equalTo(image.size.height * imgW / image.size.width);
                make.width.mas_equalTo(imgW);
            }];
            
            [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(vipBackImage.mas_top).mas_offset(10);
                make.right.mas_equalTo(vipBackImage.mas_right).mas_offset(-10);
                make.width.height.mas_equalTo(30);
            }];
            
            [comfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo((SCREENHEIGHT- imgW + 120)/2);
                make.bottom.mas_equalTo(vipBackImage.mas_bottom).mas_offset(-(imgW)/10);
                make.width.mas_equalTo(imgW *0.65);
                make.height.mas_equalTo(30);
            }];
        }];
        
        // 加到window上面
        [[UIApplication sharedApplication].keyWindow addSubview:markView];
        
    }else{
        
        markView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);
        
        [vipBackImage sd_setImageWithURL:[NSURL URLWithString:BaseHost(_dataModel.registerPic)] placeholderImage:ImagePlaceHolder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            [vipBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(image.size.height * imgW / image.size.width);
                make.width.mas_equalTo(imgW);
                make.left.mas_equalTo((SCREENWIDTH - imgW)/2);
                make.centerY.mas_equalTo(0);
            }];
            
            [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(vipBackImage.mas_top).mas_offset(10);
                make.right.mas_equalTo(-40);
                make.width.height.mas_equalTo(30);
            }];
            
            [comfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.bottom.mas_equalTo(vipBackImage.mas_bottom).mas_offset(-(imgW)/10);
                make.width.mas_equalTo(imgW * 0.65);
                make.height.mas_equalTo(30);
            }];
            
        }];
        
        [self.view addSubview:markView];
    }

}

-(void)didClickContactImgView:(UITapGestureRecognizer *)tap{
    [self registAction];
}

-(void)registAction{
    if(_isFullScreen){
        [self clickFullScreen:self.fullScreenButton];
        [_markView removeFromSuperview];
        [self initVipViewWithTitle:@"点击图片注册VIP" detail:@"尚未开通会员或会员已过期,开通会员可享受高清无码大片!"];
    }
    SPZBaseWebViewController *webVC = [SPZBaseWebViewController new];
    webVC.urlString = [NSString stringWithFormat:@"%@%@",_dataModel.registerUrl,[SPZUserModel shareModel].uid];
    webVC.titleStr = @"注册VIP";
    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)didClickComfirmRegistBtn:(UIButton *)sender{
    NSDictionary *dict = @{@"mediaUID":[SPZUserModel shareModel].uid,
                           @"id":@(_Id),
                           };
    [[SPZNetworkTool getInstance]postJsonWithUrl:ComfirmVipRegist parameters:dict success:^(id responseObject) {
        if([responseObject[@"currentStatus"] integerValue]  == 0){
            _isVip = YES;
            _isHavePush = NO;
        }else if ([responseObject[@"currentStatus"] integerValue]  == 1){
            _isVip = NO;
        }
        [_markView removeFromSuperview];
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"网络错误"];
        [_markView removeFromSuperview];
    }];
}

-(void)didClickCancelBtn:(UIButton *)sender{
    [_markView removeFromSuperview];
}

//计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
    //获取缓冲区域
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    //开始的点
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    //已缓存的时间点
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    //计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

- (NSString *)convertToTime:(CGFloat)time
{
    // 初始化格式对象
    NSDateFormatter *fotmmatter = [[NSDateFormatter alloc] init];
    // 根据是否大于1H，进行格式赋值
    if (time >= 3600){
        [fotmmatter setDateFormat:@"HH:mm:ss"];
    }else{
        [fotmmatter setDateFormat:@"mm:ss"];
    }
    // 秒数转换成NSDate类型
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    // date转字符串
    return [fotmmatter stringFromDate:date];
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SPZUnitDataModel *dataModel = _likeList[indexPath.row];
    SPZVideoPlayerViewController *videoPlayerVC = [SPZVideoPlayerViewController new];
    videoPlayerVC.Id = dataModel.Id;
    videoPlayerVC.titleStr = dataModel.fileName;
    videoPlayerVC.videoPath = BaseHost(dataModel.previewPath);
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _likeList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SPZMainLikeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoLikeCell" forIndexPath:indexPath];
    cell.dataModel = _likeList[indexPath.item];
    return cell;
}

@end