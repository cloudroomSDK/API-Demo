//
//  CloudroomPlatformViewFactory.h
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/FlutterPlatformViews.h>
#import "CloudroomPlatformView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CloudroomPlatformViewFactory : NSObject<FlutterPlatformViewFactory>

+ (instancetype)sharedInstance;

/// Called when dart invoke `destroyPlatformView`
- (BOOL)destroyPlatformView:(NSNumber *)viewID;

/// Get PlatformView to pass to native when dart invoke `startPreview` or `startPlayingStream`
- (nullable CloudroomPlatformView *)getPlatformView:(NSNumber *)viewID;

- (NSArray<CloudroomPlatformView *> *)getAllCameraPlatformView;

- (void)clearMediaView;
- (void)clearScreenShareView;

@end

NS_ASSUME_NONNULL_END
