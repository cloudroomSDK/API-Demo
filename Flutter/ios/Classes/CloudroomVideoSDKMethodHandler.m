//
//  CloudroomVideoSDKMethodHandler.m
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/10/19.
//

#import "CloudroomVideoSDKMethodHandler.h"
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_IOS.h>
#import "NSObject+Json.h"
#import "PathUtil.h"
#import "NSObject+CRModel.h"
#import "CloudroomVideoSDKEventHandler.h"
#import "CloudroomPlatformViewFactory.h"
#import "NSNull+NullCast.h"

@interface CloudroomVideoSDKMethodHandler () <CloudroomVideoMgrCallBack, CloudroomVideoMeetingCallBack>
@property (nonatomic, copy) NSString *serverAddr;
@end

@implementation CloudroomVideoSDKMethodHandler

#pragma mark - singleton
static CloudroomVideoSDKMethodHandler *shareInstance;
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

#pragma mark - 会议外

- (void)GetCloudroomVideoSDKVer:(FlutterMethodCall *)call result:(FlutterResult)result {
    result([CloudroomVideoSDK getCloudroomVideoSDKVer]);
}

- (void)setServerAddr:(FlutterMethodCall *)call result:(FlutterResult)result {
    _serverAddr = [call.arguments objectForKey:@"serverAddr"];
    result(nil);
}

- (void)getServerAddr:(FlutterMethodCall *)call result:(FlutterResult)result {
    result([[CloudroomVideoSDK shareInstance] serverAddr]);
}

- (void)init:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dict = [NSDictionary objectWithJSONString:[call.arguments objectForKey:@"sdkInitDat"]];
    SdkInitDat *sdkInitData = [SdkInitDat CR_modelWithDictionary:dict];
    CloudroomVideoSDK *cloudroomVideoSDK = [CloudroomVideoSDK shareInstance];
    
    // 设置 SDK 内部使用的文件位置
    [sdkInitData setSdkDatSavePath:[PathUtil searchPathInCacheDir:@"CloudroomVideoSDK"]];
    // 是否在控制台显示 SDK 日志
    [sdkInitData setShowSDKLogConsole:YES];
    [sdkInitData setNoCall:NO];
    [sdkInitData setNoQueue:NO];
    [sdkInitData setNoMediaDatToSvr:NO];
    [sdkInitData setIsMultiDelegate:YES];
    //    sdkInitData.datEncType = @"0";
    [sdkInitData.params setValue:sdkInitData.datEncType forKey:@"VerifyHttpsCert"];
    NSString* rsaPublicKey = @"";
    if([rsaPublicKey length] <= 0) {
        [sdkInitData.params setValue:@"0" forKey:@"HttpDataEncrypt"];
    } else {
        [sdkInitData.params setValue:@"1" forKey:@"HttpDataEncrypt"];
        [sdkInitData.params setValue:rsaPublicKey forKey:@"RsaPublicKey"];
    }
    CRVIDEOSDK_ERR_DEF error = [cloudroomVideoSDK initSDK:sdkInitData];
    
    if (error != CRVIDEOSDK_NOERR) {
        NSLog(@"VideoCallSDK init error!");
        [[CloudroomVideoSDK shareInstance] uninit];
    } else {
        [CloudroomVideoSDKEventHandler setVideoSDKCallback];
    }
    result(@(error));
}

- (void)uninit:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    [CloudroomVideoSDKEventHandler removeVideoSDKCallback];
    
    [[CloudroomVideoSDK shareInstance] uninit];
    result(nil);
}

- (void)isInitSuccess:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL success = [[CloudroomVideoSDK shareInstance] isInitSuccess];
    result([NSNumber numberWithBool:success]);
}

- (void)login:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dict = [NSDictionary objectWithJSONString:[call.arguments objectForKey:@"loginDat"]];
    NSString *nickname = [dict objectForKey:@"nickName"];
    NSString *privAcnt = [dict objectForKey:@"privAcnt"];
    NSString *authAcnt = [dict objectForKey:@"authAcnt"];
    NSString *md5Pswd = [dict objectForKey:@"authPswd"];
    NSString *cookie = [call.arguments objectForKey:@"cookie"];
    
    // 设置服务器地址
    [[CloudroomVideoSDK shareInstance] setServerAddr:_serverAddr];
    
    [[CloudroomVideoMgr shareInstance] login:authAcnt appSecret:md5Pswd nickName:nickname userID:privAcnt userAuthCode:@"" cookie:cookie];
        
    result(nil);
}

- (void)logout:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomVideoMgr shareInstance] logout];
    result(nil);
}

- (void)createMeeting:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *meetSubject = [arguments objectForKey:@"meetSubject"];
    NSString *cookie = [arguments objectForKey:@"cookie"];
    [[CloudroomVideoMgr shareInstance] createMeeting:meetSubject createPswd:NO cookie:cookie];
    result(nil);
}

- (void)destroyMeeting:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSNumber *meetID = [arguments objectForKey:@"meetID"];
    NSString *cookie = [arguments objectForKey:@"cookie"];
    [[CloudroomVideoMgr shareInstance] destroyMeeting:meetID.intValue cookie:cookie];
    result(nil);
}

#pragma mark - 会议内

- (void)enterMeeting:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSString *meetID = [dict objectForKey:@"meetID"];
//    NSString *pswd = [dict objectForKey:@"pswd"];
//    NSString *userID = [dict objectForKey:@"userID"];
//    NSString *nickName = [dict objectForKey:@"nickName"];
    
    [[CloudroomVideoMeeting shareInstance] enterMeeting:meetID.intValue];
    
    result(nil);
}

- (void)exitMeeting:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomVideoMeeting shareInstance] exitMeeting];
    result(nil);
}

#pragma mark - Member

- (void)getMyUserID:(FlutterMethodCall *)call result:(FlutterResult)result {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    result([cloudroomVideoMeeting getMyUserID]);
}

- (void)getAllMembers:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSMutableArray<MemberInfo *> *members = [[CloudroomVideoMeeting shareInstance] getAllMembers];
    result([members CR_modelToJSONString]);
    result(nil);
}

- (void)getMemberInfo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    MemberInfo *member = [[CloudroomVideoMeeting shareInstance] getMemberInfo:userID];
    result([member CR_modelToJSONString]);
}

- (void)getNickName:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    NSString *nickname = [[CloudroomVideoMeeting shareInstance] getNickName:userID];
    result(nickname);
}

- (void)setNickName:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    NSString *nickName = [arguments objectForKey:@"nickName"];
    [[CloudroomVideoMeeting shareInstance] setNickName:userID nickName:nickName];
    result(nil);
}

- (void)isUserInMeeting:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    BOOL value = [[CloudroomVideoMeeting shareInstance] isUserInMeeting:userID];
    result([NSNumber numberWithBool:value]);
}

#pragma mark - Video

- (void)getAllVideoInfo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = arguments[@"userID"];
    NSMutableArray <UsrVideoInfo *> *videoInfos = [[CloudroomVideoMeeting shareInstance] getAllVideoInfo:userID];
    result([videoInfos CR_modelToJSONString]);
}

- (void)getVideoCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    VideoCfg *videoCfg = [[CloudroomVideoMeeting shareInstance] getVideoCfg];
    NSMutableDictionary *muDic = [[videoCfg CR_modelToJSONObject] mutableCopy];
    [muDic setValue:[NSNumber numberWithInt:videoCfg.minQuality] forKey:@"qp_min"];
    [muDic setValue:[NSNumber numberWithInt:videoCfg.maxQuality] forKey:@"qp_max"];
    NSMutableDictionary *size = [NSMutableDictionary dictionary];
    [size setValue:[NSNumber numberWithInt:videoCfg.size.width] forKey:@"width"];
    [size setValue:[NSNumber numberWithInt:videoCfg.size.height] forKey:@"height"];
    [muDic setValue:size forKey:@"size"];

    result([muDic CR_modelToJSONString]);
}

- (void)setVideoCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSString *cfgJson = arguments[@"videoCfg"];
    VideoCfg *videoCfg = [VideoCfg CR_modelWithJSON:cfgJson];
    NSDictionary *cfgDic = [NSDictionary objectWithJSONString:cfgJson];
    NSDictionary *size = [cfgDic objectForKey:@"size"];
    videoCfg.size = CGSizeMake([size[@"width"] intValue], [size[@"height"] intValue]);
    videoCfg.minQuality = [[cfgDic valueForKey:@"qp_min"] intValue];
    videoCfg.maxQuality = [[cfgDic valueForKey:@"qp_max"] intValue];
    [[CloudroomVideoMeeting shareInstance] setVideoCfg:videoCfg];
    result(nil);
}

- (void)getWatchableVideos:(FlutterMethodCall *)call result:(FlutterResult)result {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSMutableArray <UsrVideoId *> *watchableVideos = [cloudroomVideoMeeting getWatchableVideos];
    
    result([watchableVideos CR_modelToJSONString]);
}

- (void)openVideo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSString *userID = args[@"userID"];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting openVideo:userID];

    result(nil);
}

- (void)closeVideo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSString *userID = args[@"userID"];
    
    // 清理对应View的视频
    NSArray<CloudroomPlatformView *> *platformViews = [[CloudroomPlatformViewFactory sharedInstance] getAllCameraPlatformView];
    for (CloudroomPlatformView *obj in platformViews) {
        UIView *view = [obj getUIView];
        CLCameraView *cameraView = (CLCameraView *)view;
        if ([cameraView.usrVideoId.userId isEqualToString:userID]) {
            [cameraView clearFrame];
            break;
        }
    }
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting closeVideo:userID];

    result(nil);
}

- (void)getDefaultVideo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = arguments[@"userID"];
    short videoID = [[CloudroomVideoMeeting shareInstance] getDefaultVideo:userID];
    result([NSNumber numberWithShort:videoID]);
}

- (void)setDefaultVideo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = arguments[@"userID"];
    short videoID = [arguments[@"videoID"] shortValue];
    [[CloudroomVideoMeeting shareInstance] setDefaultVideo:userID videoID:videoID];
    result(nil);
}

- (void)setScaleType:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    BOOL scaleType = [args[@"scaleType"] boolValue];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if (viewID == nil || view == nil) {
        result(nil);
    }
    
    CLCameraView *camView = (CLCameraView *)[view getUIView];
    camView.keepAspectRatio = scaleType;
    result(nil);
}

- (void)getScaleType:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if (viewID == nil || view == nil) {
        result([NSNumber numberWithBool:NO]);
    }
    
    CLCameraView *camView = (CLCameraView *)[view getUIView];
    result([NSNumber numberWithBool:camView.keepAspectRatio]);
}

- (void)setUsrVideoId:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    UsrVideoId *usrVideoId = [UsrVideoId CR_modelWithJSON:args[@"usrVideoId"]];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    CLCameraView *camView = (CLCameraView *)[view getUIView];
    camView.usrVideoId = usrVideoId;

    result(nil);
}

- (void)destroyPlatformView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if (viewID == nil || view == nil) {
        result([NSNumber numberWithBool:NO]);
    }
    
    CLCameraView *camView = (CLCameraView *)[view getUIView]; 
    camView.usrVideoId = nil;
    [camView clearFrame];
    [camView removeFromSuperview];

    result([NSNumber numberWithBool:[[CloudroomPlatformViewFactory sharedInstance] destroyPlatformView:viewID]]);
}

#pragma mark - Audio

- (void)getAudioCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    AudioCfg *audioCfg = [[CloudroomVideoMeeting shareInstance] getAudioCfg];
    result([audioCfg CR_modelToJSONString]);
}

- (void)setAudioCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    AudioCfg *audioCfg = [AudioCfg CR_modelWithJSON:arguments[@"audioCfg"]];
    [[CloudroomVideoMeeting shareInstance] setAudioCfg:audioCfg];
    result(nil);
}

- (void)openMic:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    [[CloudroomVideoMeeting shareInstance] openMic:userID];
    result(nil);
}

- (void)closeMic:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *userID = [arguments objectForKey:@"userID"];
    [[CloudroomVideoMeeting shareInstance] closeMic:userID];
    result(nil);
}

- (void)getMicVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL micVolume = [[CloudroomVideoMeeting shareInstance] getMicVolume];
    result([NSNumber numberWithInt:micVolume]);
}

- (void)getSpeakerVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    int speakerVolume = [[CloudroomVideoMeeting shareInstance] getSpeakerVolume];
    result([NSNumber numberWithInt:speakerVolume]);
}

- (void)setSpeakerVolume:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    int speakerVolume = [[arguments objectForKey:@"speakerVolume"] intValue];
    [[CloudroomVideoMeeting shareInstance] setSpeakerVolume:speakerVolume];
    result(nil);
}

- (void)getSpeakerOut:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL speakerOut = [[CloudroomVideoMeeting shareInstance] getSpeakerOut];
    result([NSNumber numberWithBool:speakerOut]);
}

- (void)setSpeakerOut:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    BOOL speakerOut = [[arguments objectForKey:@"speakerOut"] boolValue];
    BOOL setResult = [[CloudroomVideoMeeting shareInstance] setSpeakerOut:speakerOut];
    
    result([NSNumber numberWithBool:setResult]);
}

#pragma mark - IM

- (void)sendMeetingCustomMsg:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *text = [arguments objectForKey:@"text"];
    NSString *cookie = [call.arguments objectForKey:@"cookie"];
    [[CloudroomVideoMeeting shareInstance] sendMeetingCustomMsg:text cookie:cookie];
    result(nil);
}

#pragma mark - Media

- (void)getMediaInfo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    MediaInfo *info = [[CloudroomVideoMeeting shareInstance] getMediaInfo];
    result([info CR_modelToJSONString]);
}

- (void)startPlayMedia:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomPlatformViewFactory sharedInstance] clearMediaView];
    
    NSDictionary *arguments = call.arguments;
    NSString *videoSrc = [arguments objectForKey:@"videoSrc"];
    int bLocPlay = [[arguments objectForKey:@"bLocPlay"] intValue];
    [[CloudroomVideoMeeting shareInstance] startPlayMedia:videoSrc bLocPlay:bLocPlay bPauseWhenFinished:0];
    result(nil);
}

- (void)pausePlayMedia:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    BOOL pause = [[arguments objectForKey:@"pause"] boolValue];
    [[CloudroomVideoMeeting shareInstance] pausePlayMedia:pause];
    result(nil);
}

- (void)stopPlayMedia:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomPlatformViewFactory sharedInstance] clearMediaView];
    
    [[CloudroomVideoMeeting shareInstance] stopPlayMedia];
    result(nil);
}

- (void)setMediaPlayPos:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    int pos = [[arguments objectForKey:@"pos"] intValue];
    [[CloudroomVideoMeeting shareInstance] setPlayPos:pos];
    result(nil);
}

- (void)createMediaView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    CLMediaView *camView = (CLMediaView *)[view getUIView];
    [camView clearFrame];

    result(nil);
}

- (void)destroyMediaView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if (viewID == nil || view == nil) {
        result([NSNumber numberWithBool:NO]);
    }
    
    CLMediaView *camView = (CLMediaView *)[view getUIView];
    [camView clearFrame];
    [camView removeFromSuperview];

    result([NSNumber numberWithBool:[[CloudroomPlatformViewFactory sharedInstance] destroyPlatformView:viewID]]);
}

#pragma mark - Record

- (void)getLocMixerState:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];
    
    MIXER_STATE state = [[CloudroomVideoMeeting shareInstance] getLocMixerState:mixerID];
    result([NSNumber numberWithInteger:state]);
}

- (void)createLocMixer:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];
    
    NSDictionary *mixerCfgDic = [NSDictionary objectWithJSONString:[arguments objectForKey:@"mixerCfg"]];
    MixerCfg *mixerCfg = [MixerCfg CR_modelWithDictionary:mixerCfgDic];
    NSDictionary *dstResolution = [mixerCfgDic objectForKey:@"dstResolution"];
    mixerCfg.dstResolution = CGSizeMake([dstResolution[@"width"] intValue], [dstResolution[@"height"] intValue]);
    mixerCfg.fps = [[mixerCfgDic objectForKey:@"frameRate"] intValue];
    mixerCfg.maxBPS = [[mixerCfgDic objectForKey:@"bitRate"] intValue];
    mixerCfg.gop = [[mixerCfgDic objectForKey:@"gop"] intValue];
    mixerCfg.defaultQP = [[mixerCfgDic objectForKey:@"defaultQP"] intValue];
    
    NSArray *mixerCotentRects = [NSArray objectWithJSONString:[arguments objectForKey:@"mixerCotentRects"]];
    NSMutableArray *kMuItemArr = [NSMutableArray array];
    for (NSDictionary *obj in mixerCotentRects) {
        RecContentItem *recContentItem = [[RecContentItem alloc] init];
        NSString *userID = [obj valueForKey:@"userId"];
        short camId = [[obj valueForKey:@"camId"] shortValue];
        CGFloat left = [[obj valueForKey:@"left"] floatValue];
        CGFloat top = [[obj valueForKey:@"top"] floatValue];
        CGFloat width = [[obj valueForKey:@"width"] floatValue];
        CGFloat height = [[obj valueForKey:@"height"] floatValue];
        REC_CONTENT_TYPE type = (REC_CONTENT_TYPE)[[obj valueForKey:@"type"] integerValue];
        recContentItem.type = type;
        recContentItem.itemRt = CGRectMake(left, top, width, height);
        switch (type) {
            case RECVTP_VIDEO:
            case RECVTP_SCREEN:
            case RECVTP_MEDIA:
            case RECVTP_REMOTE_SCREEN:
                recContentItem.keepAspectRatio = YES;
                recContentItem.itemDat = @{@"camid" : [NSString stringWithFormat:@"%@.%d", userID, camId]};
                break;
                
            case RECVTP_PIC:
                recContentItem.itemDat = @{@"resourceid" : @"picture"};
                break;
                
            case RECVTP_TIMESTAMP:
                recContentItem.itemDat = @{@"resourceid" : @"timestamp"};
                break;
                
            default:
                break;
        }

        [kMuItemArr addObject:recContentItem];
    }
    
    MixerContent *mixerContent = [[MixerContent alloc] init];
    mixerContent.contents = kMuItemArr;
    
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoMeeting shareInstance] createLocMixer:mixerID cfg:mixerCfg content:mixerContent];
    result([NSNumber numberWithInteger:error]);
}

- (void)updateLocMixerContent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];
    MixerContent *mixerCotentRects = [MixerContent CR_modelWithJSON:[arguments objectForKey:@"mixerCotentRects"]];
    
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoMeeting shareInstance] updateLocMixerContent:mixerID content:mixerCotentRects];
    result([NSNumber numberWithInteger:error]);
}

- (void)addLocMixerOutput:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];
    NSArray *mixerOutPutCfgs = [NSArray CR_modelArrayWithClass:[OutputCfg class] json:[arguments objectForKey:@"mixerOutPutCfgs"]];
    
    MixerOutput *mixerOutPut = [[MixerOutput alloc] init];
    mixerOutPut.outputs = [mixerOutPutCfgs mutableCopy];
    
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoMeeting shareInstance] addLocMixer:mixerID outputs:mixerOutPut];
    result([NSNumber numberWithInteger:error]);
}

- (void)rmLocMixerOutput:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];
    NSString *nameOrUrlsData = [arguments objectForKey:@"nameOrUrls"];
    NSArray<NSString *> *nameOrUrls = [NSArray objectWithJSONString:nameOrUrlsData];

    [[CloudroomVideoMeeting shareInstance] rmLocMixerOutput:mixerID nameOrUrls:nameOrUrls];
    result(nil);
}

- (void)destroyLocMixer:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mixerID = [arguments objectForKey:@"mixerID"];

    [[CloudroomVideoMeeting shareInstance] destroyLocMixer:mixerID];
    result(nil);
}

- (void)getSvrMixerState:(FlutterMethodCall *)call result:(FlutterResult)result {
    MIXER_STATE state = [[CloudroomVideoMeeting shareInstance] getSvrMixerState];
    result([NSNumber numberWithInteger:state]);
}

- (void)startSvrMixer:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mutiMixerCfg = [arguments objectForKey:@"mutiMixerCfg"];
    NSString *mutiMixerContents = [arguments objectForKey:@"mutiMixerContents"];
    NSString *mutiMixerOutput = [arguments objectForKey:@"mutiMixerOutput"];
    
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoMeeting shareInstance] startSvrMixerJson:mutiMixerCfg contents:mutiMixerContents outputs:mutiMixerOutput];
    result([NSNumber numberWithInteger:error]);
}

- (void)updateSvrMixerContent:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *mutiMixerContents = [arguments objectForKey:@"mutiMixerContents"];

    CRVIDEOSDK_ERR_DEF errCode = [[CloudroomVideoMeeting shareInstance] updateSvrMixerContentJson:mutiMixerContents];
    result([NSNumber numberWithInteger:errCode]);
}

- (void)stopSvrMixer:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomVideoMeeting shareInstance] stopSvrMixer];
    result(nil);
}

#pragma mark - ScreenShare

- (void)isScreenShareStarted:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL started = [[CloudroomVideoMeeting shareInstance] isScreenShareStarted];
    result([NSNumber numberWithBool:started]);
}

- (void)getScreenShareCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    ScreenShareCfg *cfg = [[CloudroomVideoMeeting shareInstance] getScreenShareCfg];
    result([cfg CR_modelToJSONString]);
}

- (void)setScreenShareCfg:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    ScreenShareCfg *screenShareCfg = [ScreenShareCfg CR_modelWithJSON:[arguments objectForKey:@"screenShareCfg"]];

    [[CloudroomVideoMeeting shareInstance] setScreenShareCfg:screenShareCfg];
    result(nil);
}

- (void)startScreenShare:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomPlatformViewFactory sharedInstance] clearScreenShareView];

    [[CloudroomVideoMeeting shareInstance] startScreenShare];
    result(nil);
}

- (void)stopScreenShare:(FlutterMethodCall *)call result:(FlutterResult)result {
    [[CloudroomPlatformViewFactory sharedInstance] clearScreenShareView];

    [[CloudroomVideoMeeting shareInstance] stopScreenShare];
    result(nil);
}

- (void)startScreenShareView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    CLShareView *camView = (CLShareView *)[view getUIView];
    [camView clearFrame];

    result(nil);
}

- (void)destroyScreenShareView:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [NSDictionary dictionaryWithDictionary:call.arguments];
    NSNumber *viewID = args[@"viewID"];
    
    CloudroomPlatformView *view = [[CloudroomPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if (viewID == nil || view == nil) {
        result([NSNumber numberWithBool:NO]);
    }
    
    CLShareView *shareView = (CLShareView *)[view getUIView];
    [shareView clearFrame];
    [shareView removeFromSuperview];

    result([NSNumber numberWithBool:[[CloudroomPlatformViewFactory sharedInstance] destroyPlatformView:viewID]]);

}

@end
