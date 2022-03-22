//
//  CloudroomVideoSDKEventHandler.m
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/16.
//

#import "CloudroomVideoSDKEventHandler.h"
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_IOS.h>
#import "NSObject+CRModel.h"
#import "CloudroomPlatformViewFactory.h"

#define GUARD_SINK if(!sink){NSLog(@"[%s] FlutterEventSink is nil", __FUNCTION__);}

@interface CloudroomVideoSDKEventHandler () <CloudroomVideoMgrCallBack, CloudroomVideoMeetingCallBack>

@end

@implementation CloudroomVideoSDKEventHandler

#pragma mark - singleton
static CloudroomVideoSDKEventHandler *shareInstance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
    });
    return shareInstance;
}

+ (void)setVideoSDKCallback {
    // 配置代理
    CloudroomVideoSDKEventHandler *videoSDKEventHandler = [CloudroomVideoSDKEventHandler shareInstance];
    [[CloudroomVideoMgr shareInstance] setMgrCallback:videoSDKEventHandler];
    
    [[CloudroomVideoMeeting shareInstance] setMeetingCallBack:videoSDKEventHandler];
}

+ (void)removeVideoSDKCallback {
    // 配置代理
    CloudroomVideoSDKEventHandler *videoSDKEventHandler = [CloudroomVideoSDKEventHandler shareInstance];
    [[CloudroomVideoMgr shareInstance] removeMgrCallback:videoSDKEventHandler];
    
    [[CloudroomVideoMeeting shareInstance] removeMeetingCallBack:videoSDKEventHandler];
}

#pragma mark - CloudroomVideoMgrCallBack
- (void)loginSuccess:(NSString *)usrID cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"loginSuccess",
            @"userID": usrID,
            @"cookie": cookie
        });
    }
}

- (void)loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"loginFail",
            @"sdkErr": @(sdkErr),
            @"cookie": cookie
        });
    }
}

- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"lineOff",
            @"sdkErr": @(sdkErr)
        });
    }
}

- (void)netStateChanged:(int)level {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"netStateChanged",
            @"level": @(level)
        });
    }
}

#pragma mark - CloudroomVideoMeetingCallBack

#pragma mark - Room

- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    [arguments setValue:@(code) forKey:@"code"];
    
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"enterMeetingRslt",
            @"sdkErr": @(code)
        });
    }
}

// 创建房间成功回调
- (void)createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"createMeetingSuccess",
            @"id": [NSNumber numberWithInt:meetInfo.ID],
            @"cookie": cookie
        });
    }
}

// 创建房间失败回调
- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"createMeetingFail",
            @"sdkErr": @(sdkErr),
            @"cookie": cookie
        });
    }
}

- (void)destroyMeetingRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"destroyMeetingRslt",
            @"sdkErr": @(sdkErr),
            @"cookie": cookie
        });
    }
}

#pragma mark - Member

- (void)userEnterMeeting:(NSString *)userID {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"userEnterMeeting",
            @"userID": userID
        });
    }
}

- (void)userLeftMeeting:(NSString *)userID {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"userLeftMeeting",
            @"userID": userID
        });
    }
}

#pragma mark - Video

- (void)openVideoRslt:(NSString *)devID success:(BOOL)bSuccess {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"openVideoRslt",
            @"success": @(bSuccess),
            @"deviceID": devID
        });
    }
}

- (void)videoDevChanged:(NSString *)userID {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"videoDevChanged",
            @"userID": userID
        });
    }
}

- (void)videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"videoStatusChanged",
            @"userID": userID,
            @"oldStatus": @(oldStatus),
            @"newStatus": @(newStatus)
        });
    }
}

#pragma mark - Audio

- (void)audioDevChanged {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"audioDevChanged"
        });
    }
}

- (void)audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"audioStatusChanged",
            @"userID": userID,
            @"oldStatus": @(oldStatus),
            @"newStatus": @(newStatus)
        });
    }
}

- (void)micEnergyUpdate:(NSString *)userID oldLevel:(int)oldLevel newLevel:(int)newLevel {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"micEnergyUpdate",
            @"userID": userID,
            @"oldLevel": @(oldLevel),
            @"newLevel": @(newLevel)
        });
    }
}

#pragma mark - IM

- (void)sendCustomMeetingMsgRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"sendMeetingCustomMsgRslt",
            @"cookie": cookie,
            @"sdkErr": @(sdkErr)
        });
    }
}

- (void)notifyCustomMeetingMsg:(NSString *)fromUserID jsonDat:(NSString *)jsonDat {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyMeetingCustomMsg",
            @"fromUserID": fromUserID,
            @"text": jsonDat
        });
    }
}

#pragma mark - ScreenShare

- (void)notifyScreenShareStarted {
    [[CloudroomPlatformViewFactory sharedInstance] clearScreenShareView];
    
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyScreenShareStarted"
        });
    }
}

- (void)notifyScreenShareStopped {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyScreenShareStopped"
        });
    }
}

- (void)notifyScreenMarkStarted {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyScreenMarkStarted"
        });
    }
}

- (void)notifyScreenMarkStopped {
    [[CloudroomPlatformViewFactory sharedInstance] clearScreenShareView];

    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyScreenMarkStopped"
        });
    }
}

#pragma mark - Record

- (void)locMixerOutputInfo:(NSString *)mixerID nameUrl:(NSString *)nameUrl outputInfo:(OutputInfo *)outputInfo {
    
}

- (void)svrMixerStateChanged:(MIXER_STATE)state err:(CRVIDEOSDK_ERR_DEF)sdkErr opratorID:(NSString *)opratorID {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"svrMixerStateChanged",
            @"state": @(state),
            @"sdkErr": @(sdkErr),
            @"opratorID": opratorID
        });
    }
}

- (void)svrMixerCfgChanged {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"svrMixerCfgChanged"
        });
    }
}

- (void)svrMixerOutPutJsonInfo:(NSString *)outputInfo {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"svrMixerOutputInfo",
            @"outputInfo": outputInfo
        });
    }
}

#pragma mark - Media

- (void)notifyMediaOpened:(long)totalTime size:(CGSize)picSZ {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyMediaOpened",
            @"totalTime": @(totalTime),
            @"width": [NSNumber numberWithInt:picSZ.width],
            @"height": [NSNumber numberWithInt:picSZ.height]
        });
    }
}

- (void)notifyMediaStart:(NSString *)userid {
    [[CloudroomPlatformViewFactory sharedInstance] clearMediaView];
    
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyMediaStart",
            @"userID": userid
        });
    }
}

- (void)notifyMediaPause:(NSString *)userid bPause:(BOOL)bPause {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyMediaPause",
            @"userID": userid,
            @"pause": @(bPause)
        });
    }
}

- (void)notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason {
    [[CloudroomPlatformViewFactory sharedInstance] clearMediaView];
    
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"method": @"notifyMediaStop",
            @"userID": userid,
            @"reason": @(reason)
        });
    }
}


@end
