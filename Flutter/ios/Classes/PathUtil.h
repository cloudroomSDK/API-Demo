//
//  PathUtil.h
//  Record
//
//  Created by king on 2018/6/8.
//  Copyright © 2018年 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtil : NSObject

/* 获取 Cache 目录 */
+ (nullable NSString *)searchCacheDir;

/* 获取 Cache 目录相对路径*/
+ (nullable NSString *)searchPathInCacheDir:(nonnull NSString *)filePath;

@end
