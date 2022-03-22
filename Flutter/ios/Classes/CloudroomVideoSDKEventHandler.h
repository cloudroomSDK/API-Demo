//
//  CloudroomVideoSDKEventHandler.h
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CloudroomVideoSDKEventHandler : NSObject
+ (instancetype)shareInstance;

@property (nonatomic, strong) FlutterEventSink eventSink;

+ (void)setVideoSDKCallback;
+ (void)removeVideoSDKCallback;

@end

NS_ASSUME_NONNULL_END
