#ifndef __CLOUDROOMVIDEO_SDK_H__
#define __CLOUDROOMVIDEO_SDK_H__
#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#include <CloudroomVideoSDK_IOS/CloudroomQueue.h>
#include <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>

/* SDK 日志级别*/
typedef NS_ENUM(NSInteger, SDK_LOG_LEVEL)
{
    SDK_LOG_LEVEL_DEBUG, // 调试日志
    SDK_LOG_LEVEL_INFO, // 重要日志
    SDK_LOG_LEVEL_WARN, // 警告日志
    SDK_LOG_LEVEL_ERR, // 错误日志
    SDK_LOG_LEVEL_CRIT // 崩溃日志
};

/* 初始化信息*/
CRVSDK_EXPORT
@interface SdkInitDat : NSObject

@property (nonatomic, copy) NSString *sdkDatSavePath; // sdk内部使用的文件位置
@property (nonatomic, assign) BOOL showSDKLogConsole; // 显示日志到控制台
@property (nonatomic, assign) BOOL noCall; // 是否有呼叫功能
@property (nonatomic, assign) BOOL noQueue; // 是否有排队功能
@property (nonatomic, assign) BOOL noMediaDatToSvr; // 是否上传影音数据到服务器
@property (nonatomic, assign) int timeOut; // 超时时间设置(单位:ms)
@property (nonatomic, copy) NSString *datEncType; // 数据加密类型(0:敏感数据加密，1:全面加密; 缺省:1)
@property (nonatomic, assign) BOOL isMultiDelegate; // 配置是否启用代理模式
@property (nonatomic, assign) BOOL useHardwareEncode; // 是否使用硬编
@property (nonatomic, assign) BOOL useHardwareDecode; // 是否使用硬解
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSString*>* params;

@end

CRVSDK_EXPORT
@interface CloudroomVideoSDK : NSObject

/**
 单例方法
 @return 单例对象
 */
+ (CloudroomVideoSDK *)shareInstance;

/**
 获取SDK版本号
 @return SDK版本号
 */
+ (NSString *)getCloudroomVideoSDKVer;

/**
 初始化SDK
 @param dat 初始化参数
 @return 初始化结果
 */
- (CRVIDEOSDK_ERR_DEF)initSDK:(SdkInitDat *)dat;

-(void)setSDKParams:(NSMutableDictionary<NSString*,NSString*>*)params;
/**
 初始化是否成功
 @return 初始化是否成功
 */
- (BOOL)isInitSuccess;

/**
 是否启用多代理模式
 @return 是否启用多代理模式
 */
- (BOOL)isMultiDelegate;

/**
 反初始化(即使init失败)
 */
- (void)uninit;

/**
 设置是否输出日志到日志文件
 @param isOpen 是否输出日志到日志文件
 */
- (void)setLogOpen:(BOOL)isOpen;


/**
 开始上传日志
 @param reporter 上传者
 @param server 服务器地址
 */
- (void)startLogReport:(NSString *)reporter server:(NSString *)server;

/**
 写日志
 @param level 等级(SDK_LOG_LEVEL_DEBUG = 0, SDK_LOG_LEVEL_INFO, SDK_LOG_LEVEL_WARN, SDK_LOG_LEVEL_ERR, SDK_LOG_LEVEL_CRIT)
 @param log 日志信息
 */
- (void)writeLog:(SDK_LOG_LEVEL)level message:(NSString *)log;

/**
 停止上传日志
 */
- (void)stopLogReport;

/**
 服务器配置
 支持如下格式:
 www.cloudroom.com
 www.cloudroom.com:8080;183.60.47.52:8080;
 @param serverList 服务器列表
 */
- (void)setServerAddr:(NSString *)serverList;

/**
 获取服务器地址
 @return 服务器地址
 */
- (NSString *)serverAddr;


-(void)setAliyunOssAccountInfo:(NSString *)accessKey accessSecret:(NSString *)accessSecret;

@end

#endif  // __CLOUDROOMVIDEO_SDK_H__

