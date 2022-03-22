//
//  PathUtil.m
//  Record
//
//  Created by king on 2018/6/8.
//  Copyright © 2018年 CloudRoom. All rights reserved.
//

#import "PathUtil.h"

@implementation PathUtil
/* 获取 Cache 目录 */
+ (nullable NSString *)searchCacheDir {
    NSArray <NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [paths count] ? [paths firstObject] : nil;
}

/* 获取 Cache 目录相对路径*/
+ (nullable NSString *)searchPathInCacheDir:(nonnull NSString *)filePath {
    return (!filePath || !filePath.length) ? [self searchCacheDir] : [[self searchCacheDir] stringByAppendingPathComponent:filePath];
}
@end
