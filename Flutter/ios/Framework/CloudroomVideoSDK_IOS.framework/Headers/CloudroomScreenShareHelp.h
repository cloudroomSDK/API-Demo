//
//  CloudroomScreenShareHelp.h
//  CloudroomVideoSDK_IOS
//
//  Created by LyuBook on 2020/4/20.
//  Copyright © 2020 cloudroom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudroomVideoSDK_IOS/CloudroomCommonType.h>

NS_ASSUME_NONNULL_BEGIN

CRVSDK_EXPORT
@interface CloudroomScreenShareHelp : NSObject

@property (nonatomic, copy) void (^BroadcastStatuCallBack)(BOOL);

- (void)stopSocket;

- (void)setupSocket;

- (void)setOrientation:(YWOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
