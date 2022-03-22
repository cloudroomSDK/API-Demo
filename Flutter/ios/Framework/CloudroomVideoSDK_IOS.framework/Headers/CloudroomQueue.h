#ifndef __CLOUDROOMQUEUE_H__
#define __CLOUDROOMQUEUE_H__
#import <Foundation/Foundation.h>
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>

/* 队列信息 */
CRVSDK_EXPORT
@interface QueueInfo : NSObject

@property (nonatomic, assign) int queID; // 队列ID
@property (nonatomic, copy) NSString *name; // 队列名称
@property (nonatomic, copy) NSString *desc; // 队列描述信息
@property (nonatomic, assign) int prio; // 队列优先级(约定:值越小优先级越高)

@end

/* 队列状态 */
CRVSDK_EXPORT
@interface QueueStatus : NSObject

@property (nonatomic, assign) int queID; // 队列ID
@property (nonatomic, assign) int agent_num; // 坐席数
@property (nonatomic, assign) int wait_num;	// 等待人数
@property (nonatomic, assign) int srv_num; // 正在服务人数

@end

/* 排队等待信息(客户) */
CRVSDK_EXPORT
@interface QueuingInfo : NSObject

@property (nonatomic, assign) int queID; // 我排的队列(-1:代表我没有排队;-2:代表我正在会话中,通过GetSessionInfo可获取相关信息)
@property (nonatomic, assign) int position; // 我的位置
@property (nonatomic, assign) int queuingTime; // 我排队的时长(单位s)

@end

/* 会话信息 */
CRVSDK_EXPORT
@interface VideoSessionInfo : NSObject

@property (nonatomic, copy) NSString *callID; // 我所在的会话(空字符串代表还未建立会话,以下数据都无效)
@property (nonatomic, copy) NSString *peerID; // 对方的id和昵称
@property (nonatomic, copy) NSString *peerName;
@property (nonatomic, assign) BOOL bCallAccepted; // 被叫是否已接受呼叫(被叫掉线重登后,如果曾接受呼叫直接入会,如果未接受应该弹屏提示(也可做自动应答处理))
@property (nonatomic, assign) int meetingID; // 为会话分配的会议号
@property (nonatomic, copy) NSString *meetingPswd; // 进入会议的密码
@property (nonatomic, assign) int duration; // 会话时长

@end

/* 用户信息 */
CRVSDK_EXPORT
@interface UserInfo : NSObject

@property (nonatomic, assign) int queID; // 用户所在队列
@property (nonatomic, copy) NSString *usrID; // 用户ID
@property (nonatomic, copy) NSString *name; // 用户的昵称
@property (nonatomic, assign) int queuingTime; // 排队的时长(单位s)

@end

/* 呼叫队列协议 */

@protocol CloudroomQueueCallBack <NSObject>
@optional
/**
 初始化队列回调
 (初始化成功:errCode为VCALLSDK_NOERR)
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)initQueueDatRslt:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 队列状态变化回调
 @param queStatus 队列状态
 */
- (void)queueStatusChanged:(QueueStatus *)queStatus;


/**
 排队信息变化通知
 @param queuingInfo 排队信息
 */
- (void)queuingInfoChanged:(QueuingInfo *)queuingInfo;


/**
 开始排队回调
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)startQueuingRslt:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 停止排队回调
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)stopQueuingRslt:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 开始服务指定队列回调
 @param queID 队列ID
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)startServiceRslt:(int)queID errCode:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 停止服务指定队列
 @param queID 队列ID
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)stopServiceRslt:(int)queID errCode:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 拒绝/接受系统自动分配的用户回调
 @param errCode 错误码
 @param cookie 用户自定义数据
 */
- (void)responseAssignUserRslt:(CRVIDEOSDK_ERR_DEF)errCode cookie:(NSString *)cookie;


/**
 服务器自动安排客户
 @param usr 用户信息
 */
- (void)autoAssignUser:(UserInfo *)usr;


/**
 手动请求分配客户回调
 @param errCode 错误码
 @param usr 用户信息
 @param cookie 用户自定义数据
 */
- (void)reqAssignUserRslt:(CRVIDEOSDK_ERR_DEF)errCode userInfo:(UserInfo *)usr cookie:(NSString *)cookie;


/**
 服务器撤消了安排的客户
 (如:座席超时未与分配的客户建议通话）
 @param queID 队列ID
 @param usrID 用户ID
 */
- (void)cancelAssignUser:(int)queID usrID:(NSString *)usrID;

@end


/* 呼叫队列管理类 */
CRVSDK_EXPORT
@interface CloudroomQueue : NSObject

/**
 单例方法
 获得呼叫队列管理对象
 @return 单例对象
 */
+ (CloudroomQueue *)shareInstance;


/**
 设置回调
 @param callBack 代理对象
 */
- (void)setQueueCallback:(id <CloudroomQueueCallBack>)callBack;

/**
 注册回调
 @param callBack 代理对象
 */
- (void)registerQueueCallback:(id <CloudroomQueueCallBack>)callBack;

/**
 移除回调
 @param callBack 移除多代理模式代理对象
 */
- (void)removeQueueCallback:(id <CloudroomQueueCallBack>)callBack;

/**
 初始化队列数据
 (初始化成功后,才能获取后面的数据）
 @param cookie 用户自定义数据
 */
- (void)initQueueDat:(NSString *)cookie;


/**
 刷新所有队列状态信息
 1. InitDat成功后,已有所有队列状态信息
 2. 客户排队的队列、座席所服务的队列,会有通知消息:QueueStatusChanged;如需要其它队列状态就要使用此接口
 3. RefreshAllQueueStatus后,有变化的会发出QueueStatusChanged通知消息
 */
- (void)refreshAllQueueStatus;


/**
 获取队列信息
 @return 队列信息
 */
- (NSMutableArray <QueueInfo *> *)getQueueInfo;


/**
 获取指定队列状态
 @param queID 队列ID
 @return 指定队列状态
 */
- (QueueStatus *)getQueueStatus:(int)queID;


/**
 获取我的排队信息
 (客户专用接口,如上次正在排队,异常退出后再启动时,可获取上次排队信息)
 @return 我的排队信息
 */
- (QueuingInfo *)getQueuingInfo;


/**
 获取我服务的所有队列
 (座席专用接口)
 @return 我服务的所有队列
 */
- (NSMutableArray <NSNumber *> *)getServiceQueues;


/**
 获取我的会话信息
 (如上次正在会话,异常退出后再启动时,可获取上次会话信息)
 @return 我的会话信息
 */
- (VideoSessionInfo *)getSessionInfo;


/********客户*********/

/**
 开始排队
 (只能在一个队列中排队)
 @param queID 队列ID
 @param cookie 用户自定义数据
 */
- (void)startQueuing:(int)queID cookie:(NSString *)cookie;
- (void)startQueuing:(int)queID usrExtDat:(NSString *)usrExtDat cookie:(NSString *)cookie;

/**
 停止排队
 @param cookie 用户自定义数据
 */
- (void)stopQueuing:(NSString *)cookie;


/********座席(客服)*********/

/**
 开始服务指定队列
 (可以为多个队列服务)
 @param queID 队列ID
 @param cookie 用户自定义数据
 */
- (void)startService:(int)queID cookie:(NSString *)cookie;
- (void)startService:(int)queID priority:(int)priority cookie:(NSString *)cookie;


/**
 停止服务指定队列
 @param queID 队列ID
 @param cookie 用户自定义数据
 */
- (void)stopService:(int)queID cookie:(NSString *)cookie;


/**
 接受系统自动安排的客户
 @param queID 队列ID
 @param userID 用户ID
 @param cookie 用户自定义数据
 */
- (void)acceptAssignUser:(int)queID userID:(NSString *)userID cookie:(NSString *)cookie;


/**
 拒绝系统自动安排的客户
 @param queID 队列ID
 @param userID 用户ID
 @param cookie 用户自定义数据
 */
- (void)rejectAssignUser:(int)queID userID:(NSString *)userID cookie:(NSString *)cookie;


/**
 手动请求分配一个客户
 (在免打扰状态下,系统不会自动分配,可以主动请求分配一个任务)
 @param cookie 用户自定义数据
 */
- (void)reqAssignUser:(NSObject *)cookie;

@end

#endif //__CLOUDROOMQUEUE_H__
