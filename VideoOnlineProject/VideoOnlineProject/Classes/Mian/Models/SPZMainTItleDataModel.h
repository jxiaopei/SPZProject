//
//  SPZMainTItleDataModel.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/10/28.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPZMainTItleDataModel : NSObject

@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,assign)NSInteger Id;
@property(nonatomic,assign)BOOL isCollection;
@property(nonatomic,assign)BOOL isTop;
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *createUser;
@property(nonatomic,copy)NSString *lastModifyTime;
@property(nonatomic,copy)NSString *operatorUser;
@property(nonatomic,copy)NSString *remark;
@property(nonatomic,copy)NSString *removed;
@property(nonatomic,copy)NSString *titleName;
@property(nonatomic,assign)NSInteger type;


@end
