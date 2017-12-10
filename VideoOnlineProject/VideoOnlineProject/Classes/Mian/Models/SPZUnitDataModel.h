//
//  SPZUnitDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZUnitDataModel : NSObject

@property(nonatomic,assign)NSInteger Id;
@property(nonatomic,assign)NSInteger videoTypeId;
@property(nonatomic,assign)NSInteger property;
@property(nonatomic,assign)NSInteger hitCount;
@property(nonatomic,copy)NSString *isHotRecommend;
@property(nonatomic,copy)NSString *logo;
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *playSourcePath;
@property(nonatomic,copy)NSString *isVideo;
@property(nonatomic,copy)NSString *isLike;
@property(nonatomic,copy)NSString *introduce;
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,copy)NSString *isRecommend;
@property(nonatomic,assign)NSInteger categoryId;
@property(nonatomic,copy)NSString *mediaId;
@property(nonatomic,copy)NSString *videoPath;
@property(nonatomic,copy)NSString *previewPath;
@property(nonatomic,assign)BOOL isOwned;
@property(nonatomic,copy)NSString *registerPic;
@property(nonatomic,copy)NSString *registerUrl;
@property(nonatomic,copy)NSString *confirmPic;
@property(nonatomic,assign)BOOL openStatus;

@property(nonatomic,assign)BOOL isSelected;

@property(nonatomic,copy)NSString *pictureIntroduce;
@property(nonatomic,copy)NSString *pictureLogo;
@property(nonatomic,copy)NSString *pictureName;
@property(nonatomic,assign)NSInteger picturehitCount;

@property(nonatomic,assign)NSInteger filmId;
@property(nonatomic,assign)NSInteger pictureId;
@property(nonatomic,copy)NSString *pictPreviewPath;

@end
