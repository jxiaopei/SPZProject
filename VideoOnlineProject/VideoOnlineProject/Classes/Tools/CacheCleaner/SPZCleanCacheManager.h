//
//  SPZCleanCacheManager.h
//  VideoOnlineProject
//
//  Created by iMac on 2017/11/2.
//  Copyright © 2017年 eirc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^cleanCacheBlock)();

@interface SPZCleanCacheManager : NSObject

/**
 *  清理缓存
 */
+(void)cleanCache:(cleanCacheBlock)block;
/**
 *  整个缓存目录的大小
 */
+(float)folderSizeAtPath;

@end
