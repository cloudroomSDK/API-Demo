//
//  CloudroomPlatformViewFactory.m
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/8.
//

#import "CloudroomPlatformViewFactory.h"

@interface CloudroomPlatformViewFactory ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, CloudroomPlatformView*> *platformViewMap;

@end

@implementation CloudroomPlatformViewFactory

+ (instancetype)sharedInstance {
    static CloudroomPlatformViewFactory *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CloudroomPlatformViewFactory alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _platformViewMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)destroyPlatformView:(NSNumber *)viewID {

    CloudroomPlatformView *platformView = self.platformViewMap[viewID];

    if (!platformView) {
        NSLog(@"[destroyPlatformView] platform view for viewID:%d not exists", viewID.intValue);
        [self logCurrentPlatformViews];
        return NO;
    }

    NSLog(@"[destroyPlatformView] viewID:%d, UIView:%p", viewID.intValue, [platformView getUIView]);

    [self.platformViewMap removeObjectForKey:viewID];

    [self logCurrentPlatformViews];

    return YES;
}

- (nullable CloudroomPlatformView *)getPlatformView:(NSNumber *)viewID {

    NSLog(@"[getPlatformView] viewID:%d", viewID.intValue);

    [self logCurrentPlatformViews];
    
    return [self.platformViewMap objectForKey:viewID];
}

- (NSArray<CloudroomPlatformView *> *)getAllCameraPlatformView {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewType == 'platformview'"];
    NSArray *results = [_platformViewMap.allValues filteredArrayUsingPredicate:predicate];
    
    return results;
}

- (NSArray<CloudroomPlatformView *> *)getAllMediaPlatformView {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewType == 'mediaview'"];
    NSArray *results = [_platformViewMap.allValues filteredArrayUsingPredicate:predicate];
    
    return results;
}

- (NSArray<CloudroomPlatformView *> *)getAllScreenSharePlatformView {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"viewType == 'screenshareview'"];
    NSArray *results = [_platformViewMap.allValues filteredArrayUsingPredicate:predicate];
    
    return results;
}

- (void)clearMediaView {
    // 清理对应View的视频
    NSArray<CloudroomPlatformView *> *platformViews = [[CloudroomPlatformViewFactory sharedInstance] getAllMediaPlatformView];
    for (CloudroomPlatformView *obj in platformViews) {
        UIView *view = [obj getUIView];
        CLMediaView *cameraView = (CLMediaView *)view;
        [cameraView clearFrame];
    }
}

- (void)clearScreenShareView {
    // 清理对应View的视频
    NSArray<CloudroomPlatformView *> *platformViews = [[CloudroomPlatformViewFactory sharedInstance] getAllScreenSharePlatformView];
    for (CloudroomPlatformView *obj in platformViews) {
        UIView *view = [obj getUIView];
        CLShareView *cameraView = (CLShareView *)view;
        [cameraView clearFrame];
    }
}

- (void)addPlatformView:(CloudroomPlatformView *)view viewID:(NSNumber *)viewID {

    NSLog(@"[createPlatformView] viewID:%d, UIView:%p", viewID.intValue, [view getUIView]);

    [self.platformViewMap setObject:view forKey:viewID];

    [self logCurrentPlatformViews];
}

- (void)logCurrentPlatformViews {
    NSMutableString *desc = [[NSMutableString alloc] init];
    for (NSNumber *i in self.platformViewMap) {
        CloudroomPlatformView *eachPlatformView = self.platformViewMap[i];
        if (eachPlatformView) {
            [desc appendFormat:@"[ID:%d|View:%p] ", i.intValue, eachPlatformView.getUIView];
        }
    }
    NSLog(@"[CloudroomPlatformViewFactory] currentPlatformViews: %@", desc);
}

#pragma mark FlutterPlatformViewFactory Delegate

/// Called when dart invoke `createPlatformView`, that is, when Widget `UiKitView` is added to the flutter render tree
- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    NSString *viewType = [(NSDictionary *)args objectForKey:@"viewType"];
    CloudroomPlatformView *view = [[CloudroomPlatformView alloc] initWithRect:frame viewID:viewId viewType:viewType];
    [self addPlatformView:view viewID:@(viewId)];
    
    return view;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

@end
