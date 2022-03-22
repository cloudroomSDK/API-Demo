#ifndef __CLOUDROOMVIDEO_MGR_H__
#define __CLOUDROOMVIDEO_MGR_H__
#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#include <CloudroomVideoSDK_IOS/CloudroomQueue.h>
#include <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>
#include <CloudroomVideoSDK_IOS/CloudroomCommonType.h>

typedef NS_ENUM(NSInteger, CLIENT_STATUS) {
    OFFLINE = 0, // 离线
    ONLINE, // 在线
    BUSY, // 繁忙
    MEETING // 在会议中
};

typedef NS_ENUM(NSInteger, CR_INVITE_STATUS) {
    IS_RINGING = 0,
    IS_ACCEPTED,
    IS_DECLINED,
    IS_NORESPONSE,
    IS_HUNGUP,
};

/* 登录信息 */
CRVSDK_EXPORT
@interface LoginDat : NSObject

@property (nonatomic, copy) NSString *authAcnt; // 云屋鉴权帐号
@property (nonatomic, copy) NSString *authPswd; // 云屋鉴权密码
@property (nonatomic, copy) NSString *nickName; // 昵称
@property (nonatomic, copy) NSString *privAcnt; // 自定义帐号,云屋服务器将会去配置的服务器进行认证(当不使用自定义帐号时,acnt,pswd应为NULL)
@property (nonatomic, copy) NSString *privAuthCode; // 自定义验证码(有复杂要求的,可以使用json格式)
@property (nonatomic, copy) NSString *param; // 用户扩展信息

@end

/* 会议信息 */
CRVSDK_EXPORT
@interface MeetInfo : NSObject

@property (nonatomic, assign) int ID; // 会议ID

@end


/* 用户状态 */
CRVSDK_EXPORT
@interface UserStatus : NSObject

@property (nonatomic, copy) NSString *userID; // 用户ID
@property (nonatomic, assign) CLIENT_STATUS userStatus; // 客户端状态
@property (nonatomic, assign) int DNDType; // 用户自定义免打扰状态,0:未设置

@end

/* 企业网盘相关 */

@protocol CloudroomVideoMgrCallBack <NSObject>
@optional

/********登录*********/
/**
 登录成功回调
 @param usrID 用户ID
 @param cookie 用户自定义数据
 */
- (void)loginSuccess:(NSString *)usrID cookie:(NSString *)cookie;


/**
 登录失败回调
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

// 掉线通知
- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr;

/********免打扰*********/

/**
 设置免打扰状态成功回调
 @param cookie 用户自定义数据
 */
- (void)setDNDStatusSuccess:(NSString *)cookie;


/**
 设置免打扰状态失败回调
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)setDNDStatusFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/********好友状态*********/
// added by king 20171208
- (void)getUserStatusRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userStatus:(NSArray <UserStatus *> *)userStatus cookie:(NSString *)cookie;

- (void)notifyUserStatus:(UserStatus *)uStatus;

- (void)startStatusPushRsp:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)stopStatusPushRsp:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

/********会议*********/

/**
 创建会议成功回调
 @param meetInfo 会议信息
 @param cookie 用户自定义数据
 */
- (void)createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie;


/**
 创建会议失败回调
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)destroyMeetingRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

/**
 获取会议列表成功回调
 added by king 20170726
 @param meetList 会议列表
 @param cookie 用户自定义数据
 */
- (void)getMeetingListSuccess:(NSArray <MeetInfo *> *)meetList cookie:(NSString *)cookie;


/**
 获取会议列表失败回调
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)getMeetingListFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/********呼叫*********/

/**
 邀请他人参会成功回调
 @param callID 呼叫标识码
 @param cookie 用户自定义数据
 */
- (void)callSuccess:(NSString *)callID cookie:(NSString *)cookie;


/**
 邀请他人参会失败回调
 @param callID 呼叫标识码
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)callFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/**
 接受他人邀请成功回调
 @param callID 呼叫标识码
 @param cookie 用户自定义数据
 */
- (void)acceptCallSuccess:(NSString *)callID cookie:(NSString *)cookie;


/**
 接受他人邀请失败回调
 @param callID 呼叫标识码
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)acceptCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/**
 拒绝他人邀请成功回调
 @param callID 呼叫标识码
 @param cookie 用户自定义数据
 */
- (void)rejectCallSuccess:(NSString *)callID cookie:(NSString *)cookie;


/**
 拒绝他人邀请失败回调
 @param callID 呼叫标识码
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)rejectCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/**
 拆除呼叫成功回调
 @param callID 呼叫标识码
 @param cookie 用户自定义数据
 */
- (void)hangupCallSuccess:(NSString *)callID cookie:(NSString *)cookie;


/**
 拆除呼叫失败回调
 @param callID 呼叫标识码
 @param sdkErr 错误码
 @param cookie 用户自定义数据
 */
- (void)hangupCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;


/**
服务端通知被邀请
@param callID 呼叫标识码
@param meetInfo 会议信息
@param callerID 主叫ID
@param usrExtDat 用户扩展参数
*/
- (void)notifyCallIn:(NSString *)callID meetInfo:(MeetInfo *)meetInfo callerID:(NSString *)callerID usrExtDat:(NSString *)usrExtDat;


/**
 服务端通知会议邀请被接受回调
 @param callID 呼叫标识码
 @param meetInfo 会议信息
 @param usrExtDat 用户扩展参数
 */
- (void)notifyCallAccepted:(NSString *)callID meetInfo:(MeetInfo *)meetInfo usrExtDat:(NSString *)usrExtDat;


/**
 服务端通知邀请被拒绝回调
 @param callID 呼叫标识码
 @param reason 错误码
 @param usrExtDat 用户扩展参数
 */
- (void)notifyCallRejected:(NSString *)callID reason:(CRVIDEOSDK_ERR_DEF)reason usrExtDat:(NSString *)usrExtDat;


/**
 服务端通知呼叫被结束
 @param callID 呼叫标识码
 @param usrExtDat 用户扩展参数
 */
- (void)notifyCallHungup:(NSString *)callID usrExtDat:(NSString *)usrExtDat;

/********第三方呼叫*********/
- (void)callMorePartyRslt:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
- (void)cancelCallMorePartyRslt:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 呼叫状态通知
- (void)notifyCallMorePartyStatus:(NSString *)inviteID status:(CR_INVITE_STATUS)status;

/********透明通道*********/
// 发送信令结果
- (void)sendCmdRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送数据结果
- (void)sendBufferRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送文件结果
- (void)sendFileRlst:(NSString *)sendId fileName:(NSString *)fileName sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送数据进度(文件和数据共用)
- (void)sendProgress:(NSString *)sendId sendedLen:(int)sendedLen totalLen:(int)totalLen cookie:(NSString *)cookie;
// 取消发送数据结果
- (void)cancelSendRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 接收信令
- (void)notifyCmdData:(NSString *)sourceUserId data:(NSString *)data;
// 接收数据
- (void)notifyBufferData:(NSString *)sourceUserId data:(NSString *)data;
// 接收文件
- (void)notifyFileData:(NSString *)sourceUserId tmpFile:(NSString *)tmpFile orgFileName:(NSString *)orgFileName;
// 取消数据发送
- (void)notifyCancelSend:(NSString *)sendId;

//邀请
-(void)inviteSuccess:(NSString *)inviteID cookie:(NSString *)cookie;

-(void)inviteFail:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)cancelInviteSuccess:(NSString *)inviteID cookie:(NSString *)cookie;

-(void)cancelInviteFail:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)acceptInviteSuccess:(NSString *)inviteID cookie:(NSString *)cookie;

-(void)acceptInviteFail:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)rejectInviteSuccess:(NSString *)inviteID cookie:(NSString *)cookie;

-(void)rejectInviteFail:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)notifyInviteIn:(NSString *)inviteID  inviterUsrID:(NSString*)NSString usrExtDat:(NSString *)usrExtDat;

-(void)notifyInviteAccepted:(NSString *)inviteID usrExtDat:(NSString *)usrExtDat;

-(void)notifyInviteRejected:(NSString *)inviteID reason:(CRVIDEOSDK_ERR_DEF)reason usrExtDat:(NSString *)usrExtDat;

-(void)notifyInviteCanceled:(NSString *)inviteID reason:(CRVIDEOSDK_ERR_DEF)reason usrExtDat:(NSString *)usrExtDat;

/********企业网盘回调通知*********/
//-(void)notifyGetCompDiskSummary:(DiskSummary*)staRs;
//-(void)notifyGetCompDiskFileList:(NSMutableArray<FileInfo*>*)list;
//-(void)notifyCompDiskFileDeleteRslt:(NSString*)fileID isSucceed:(bool)isSucceed;
//-(void)notifyCompDiskTransforProgress:(NSString*)fileID percent:(int)percent isUpload:(bool)isUpload;
/********token鉴权回调通知*********/
-(void)notifyTokenNearTimeout;
@end

CRVSDK_EXPORT
@interface CloudroomVideoMgr : NSObject


/**
 单例方法
 @return 单例对象
 */
+ (CloudroomVideoMgr *)shareInstance;


/**
 设置回调
 @param callBack 代理对象
 */
- (void)setMgrCallback:(id <CloudroomVideoMgrCallBack>)callBack;

/**
 注册回调
 @param callBack 代理对象
 */
- (void)registerMgrCallback:(id <CloudroomVideoMgrCallBack>)callBack;

/**
 移除回调
 @param callBack 代理对象
 */
-(void) removeMgrCallback:(id<CloudroomVideoMgrCallBack>)callBack;

/********登录*********/

/**
 登录
 @param loginDat 登录数据
 */
- (void)login:(LoginDat *)loginDat;


/**
 登录
 @param loginDat 登录数据
 @param cookie 用户自定义数据
 */
- (void)login:(LoginDat *)loginDat cookie:(NSString *)cookie;

/**
 token登录鉴权
 @param token token
 @param nickName 昵称
 @param userID 用户ID
 @param userAuthCode 用户鉴权码
 @param cookie 用户自定义数据
 */
-(void)loginByToken:(NSString*)token nickName:(NSString*)nickName userID:(NSString*)userID userAuthCode:(NSString*)userAuthCode cookie:(NSString *)cookie;

/**
@param appID 账号
@param md5_appSecret 密码
@param nickName 昵称
@param userID 用户ID
@param userAuthCode 用户鉴权码
@param cookie 用户自定义数据
*/
-(void)login:(NSString*)appID appSecret:(NSString*)md5_appSecret nickName:(NSString*)nickName userID:(NSString*)userID userAuthCode:(NSString*)userAuthCode cookie:(NSString *)cookie;
/**
更新token
@param token token
*/
-(void)updateToken:(NSString*)token;


/**
 注销
 */
- (void)logout;


//第三方鉴权错误原因获取
-(int)getUserAuthErrCode;
-(NSString*)getUserAuthErrDesc;


/********免打扰*********/

/**
 客户端自定义免打扰状态
 (0:代表关闭免打扰,其它值代表开启免打扰,含义可自由定义)
 @param DNDStatus 免打扰状态
 */
- (void)setDNDStatus:(int)DNDStatus;


/**
 客户端自定义免打扰状态
 (0:代表关闭免打扰,其它值代表开启免打扰,含义可自由定义)
 @param DNDStatus 免打扰状态
 @param cookie 用户自定义数据
 */
- (void)setDNDStatus:(int)DNDStatus cookie:(NSString *)cookie;

/********好友状态*********/
// added by king 20171208
// 获取好友状态
- (void)getUserStatus:(NSString *)cookie;
- (void)getUserStatus:(NSString *)userID cookie:(NSString *)cookie;
// 开始好友状态监听
- (void)startUserStatusNotify:(NSString *)cookie;
// 停止好友状态监听
- (void)stopUserStatusNotify:(NSString *)cookie;

/********会议*********/

/**
 创建会议
 @param meetSubject 会议主题
 @param createPswd 会议密码
 */
- (void)createMeeting:(NSString *)meetSubject createPswd:(BOOL)createPswd;


/**
 创建会议
 @param meetSubject 会议主题
 @param createPswd 会议密码
 @param cookie 用户自定义数据
 */
- (void)createMeeting:(NSString *)meetSubject createPswd:(BOOL)createPswd cookie:(NSString *)cookie;

/**
 销毁房间
 @param meetID 会议ID
 @param cookie 用户自定义数据
 */
- (void)destroyMeeting:(int)meetID cookie:(NSString *)cookie;

/**
 结束指定会议
 @param meetID 会议ID
 */
- (void)stopMeeting:(int)meetID;


/**
 结束指定会议
 @param meetID 会议ID
 @param cookie 用户自定义数据
 */
- (void)stopMeeting:(int)meetID cookie:(NSString *)cookie;


/**
 获取会议列表
 added by king 20170726
 @param cookie 用户自定义数据
 */
- (void)getMeetingList:(NSString *)cookie;

/********呼叫*********/

/**
 邀请某人/某队列(返回callID)
 @param calledUserID 被叫ID
 @param meetInfo 会议信息
 @param param 参数
 @return 呼叫标识码
 */
- (NSString *)call:(NSString *)calledUserID meetInfo:(MeetInfo *)meetInfo param:(NSString *)param;


/**
 邀请某人/某队列(返回callID)
 @param calledUserID 被叫ID
 @param meetInfo 会议信息
 @param param 参数
 @param cookie 用户自定义数据
 @return 呼叫标识码
 */
- (NSString *)call:(NSString *)calledUserID
          meetInfo:(MeetInfo *)meetInfo
             param:(NSString *)param
            cookie:(NSString *)cookie;


/**
 接受邀请
 @param callID 呼叫标识码
 @param meetInfo 会议信息
 */
- (void)acceptCall:(NSString *)callID meetInfo:(MeetInfo *)meetInfo;


/**
 接受邀请
 @param callID 呼叫标识码
 @param meetInfo 会议信息
 @param usrExtDat 用户附带数据
 */
- (void)acceptCall:(NSString *)callID meetInfo:(MeetInfo *)meetInfo usrExtDat:(NSString *)usrExtDat;


/**
 接受邀请
 @param callID 呼叫标识码
 @param meetInfo 会议信息
 @param usrExtDat 用户附带数据
 @param cookie 用户自定义数据
 */
- (void)acceptCall:(NSString *)callID
          meetInfo:(MeetInfo *)meetInfo
         usrExtDat:(NSString *)usrExtDat
            cookie:(NSString *)cookie;


/**
 拒绝邀请
 @param callID 呼叫标识码
 */
- (void)rejectCall:(NSString *)callID;


/**
 拒绝邀请
 @param callID 呼叫标识码
 @param usrExtDat 用户附带数据
 */
- (void)rejectCall:(NSString *)callID usrExtDat:(NSString *)usrExtDat;


/**
 拒绝邀请
 @param callID 呼叫标识码
 @param usrExtDat 用户附带数据
 @param cookie 用户自定义数据
 */
- (void)rejectCall:(NSString *)callID usrExtDat:(NSString *)usrExtDat cookie:(NSString *)cookie;


/**
 取消/结束呼叫
 @param callID 呼叫标识码
 */
- (void)hungupCall:(NSString *)callID;


/**
 取消/结束呼叫
 @param callID 呼叫标识码
 @param usrExtDat 用户附带数据
 */
- (void)hungupCall:(NSString *)callID usrExtDat:(NSString *)usrExtDat;


/**
 取消/结束呼叫
 @param callID 呼叫标识码
 @param usrExtDat 用户附带数据
 @param cookie 用户自定义数据
 */
- (void)hungupCall:(NSString *)callID usrExtDat:(NSString *)usrExtDat cookie:(NSString *)cookie;

// 呼叫第三方
- (NSString *)callMoreParty:(NSString *)calledID
                   meetInfo:(MeetInfo *)meetInfo
                  usrExtDat:(NSString *)usrExtDat
                     cookie:(NSString *)cookie;
// 取消呼叫第三方
- (void)cancelCallMoreParty:(NSString *)inviteID usrExtDat:(NSString *)usrExtDat cookie:(NSString *)cookie;

/********透明通道*********/
- (NSString *)sendCmd:(NSString *)targetUserId data:(NSString *)data;
- (NSString *)sendCmd:(NSString *)targetUserId data:(NSString *)data cookie:(NSString *)cookie;

- (NSString *)sendBuffer:(NSString *)targetUserId data:(NSString *)data;
- (NSString *)sendBuffer:(NSString *)targetUserId data:(NSString *)data cookie:(NSString *)cookie;

- (NSString *)sendFile:(NSString *)targetUserId fileName:(NSString *)fileName;
- (NSString *)sendFile:(NSString *)targetUserId fileName:(NSString *)fileName cookie:(NSString *)cookie;
- (void)cancelSend:(NSString *)sendId;

/********视频打点相关*********/
-(void)setMarkText:(NSString*)videoFilePathName timestamp:(int)timestamp markText:(NSString*)markText;

// 移除打点信息
  -(void)removeMarkText:(NSString*)videoFilePathName timestamp:(int)timestamp;

// 获取所有打点信息
-(NSString*)getAllMarks:(NSString*)videoFilePathName;

// 获取打点文件的绝对文件路径名
-(NSString*)getVideoMarkFile:(NSString*)videoFilePathName;

#pragma mark ----------------------------------------------- 邀请功能
-(NSString*)invite:(NSString*)invitedUserID usrExtDat:(NSString*)usrExtDat cookie:(NSString*)cookie;

-(void)acceptInvite:(NSString*)inviteID usrExtDat:(NSString*)usrExtDat cookie:(NSString*)cookie;

-(void)rejectInvite:(NSString*)inviteID usrExtDat:(NSString*)usrExtDat cookie:(NSString*)cookie;

-(void)cancelInvite:(NSString*)inviteID usrExtDat:(NSString*)usrExtDat cookie:(NSString*)cookie;
@end

#endif  // __CLOUDROOMVIDEO_MGR_H__

