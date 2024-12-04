#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

// 屏幕录制进程入口
@interface CRReplayKitExt : NSObject

//获得单例对象
+ (CRReplayKitExt*)shareInstance;

- (void)broadcastStarted:(RPBroadcastSampleHandler*)sampleHandler setupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo;

- (void)broadcastPaused;

- (void)broadcastResumed;

- (void)broadcastFinished;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType;

/// 首选语言，如果设置了就用该语言，不设则取当前系统语言。
/// 支持zh-Hans、en
@property (copy, nonatomic) NSString *preferredLanguage;

@end

NS_ASSUME_NONNULL_END
