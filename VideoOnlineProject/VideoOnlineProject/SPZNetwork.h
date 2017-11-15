//
//  SPZNetwork.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/25.
//  Copyright © 2017年 eirc. All rights reserved.
//

#ifndef SPZNetwork_h
#define SPZNetwork_h

#define NETWORK_STATE 1  //1是正式环境 0是测试环境

#define BaseHttpUrl   NETWORK_STATE ?  @"http://101.102.225.216:9977" : @"http://172.16.3.237:9977" //@"http://101.102.225.216:9977" @"http://172.16.1.69:9977" @"http://172.16.6.99:9977"

#define BaseUrl(url)   [NSString stringWithFormat:@"%@%@",BaseHttpUrl,url]
#define BaseHost(url)  [SPZNetworkTool contectbaseHostWithPath:url]

#define AppNetwork              @"http://119.9.107.44:9999/getDomainMapper"                    //请求动态域名
#define AppUpdateInvalidUrl     @"http://119.9.107.44:9999/updateDomainMapper"                 //上传失效域名
#define AppCheckHostAvailable   @"/user/homepage/checkDomainName"                              //握手
#define AppUpdateUrl            @"https://tpfw.083075.com/system/getAppLastChange"             //检测新版本更新
#define AppInitialize           @"/user/homepage/getLotteryInitialization"                     //app初始化信息接口
#define AppHttpDNS              @"http://47.74.19.250:9888/dns/queryDNS?uri=acp58.com"         //app初始化HttpDNS
//校验会员
#define ComfirmVipRegist  @"/video/confirmRegister"                             //校验是否注册vip成功
#define ComfirmVipRight   @"/video/confirmMedia"                                //校验是否注册了vip
//首页
#define HomepageBanner    @"/app/getBanner"                                     //首页banner
#define HomeCategory      @"/app/getCategory"                                   //首页分类
#define HomeLikeList      @"/app/getLikeList"                                   //首页猜你喜欢
#define HomeRecommend     @"/app/getRecommendList"                              //首页推荐
#define HomeHotRecom      @"/app/getHotRecommendList"                           //首页热门推荐
#define HomeCateList      @""                         //首页分类展示
#define CategoryList      @"/app/getFilmLibraryByCateId"                        //分类下列表
#define SearchVideoList   @"/app/getFilmLibraryByName"                          //搜索视频列表
#define SearchPhotoList   @"/app/getPictureLibraryByName"                       //搜索图片列表
//频道
#define ChannelList       @"/app/getFilmLibrary"                                //频道列表
#define VideoType         @"/app/getVideoType"                                  //视频类型列表
#define VideoDetail       @"/app/getFilmLibraryById"                            //视频详情
#define SmallChannelList  @"/app/getFilmLibraryByVideoTypeId"                   //频道小类别类别
//图片
#define PhotoLikeList     @"/app/getLikePictureList"                            //图片猜你喜欢
#define PhotoDetail       @"/app/getPictureLibraryById"                         //图片详情
#define PhotoGroups       @"/pictureLibrary/getPictureByParentId"               //图片集合
//个人
#define AttenVideoList    @"/collect/getCollectLibraryByUserId"                 //视频收藏列表
#define AttenVideoAction  @"/collect/addCollectLibrary"                         //视频收藏
#define AttenPicList      @"/collect/getCollectPictureLibraryByUserId"          //图片收藏列表
#define AttenPicAction    @"/collect/addPictureCollectLibrary"                  //图片收藏
#define RemoveVideoAtten  @"/collect/removeCollectLibrary"                      //删除视频收藏
#define CancelVideoAtten  @"/collect/canceCollectLibrary"                       //取消视频收藏
#define CancelPicAtten    @"/collect/cancePictureCollectLibrary"                //取消图片收藏
#define RemovePicAtten    @"/collect/removePictureCollectLibrary"               //删除图片收藏
#define GameList          @"/recommend/getGameRecommend"                        //游戏推荐
#define HistoryList       @"/app/getBrowserHistory"                             //浏览历史
#define RemoveHistory     @"/app/removeBrowserHistory"                          //删除浏览历史

#endif /* SPZNetwork_h */
