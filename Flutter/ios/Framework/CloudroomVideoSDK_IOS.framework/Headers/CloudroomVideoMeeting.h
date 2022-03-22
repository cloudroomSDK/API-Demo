#ifndef __CLOUDROOMVIDEO_MEETING_H__
#define __CLOUDROOMVIDEO_MEETING_H__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#include <CloudroomVideoSDK_IOS/CloudroomQueue.h>
#include <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>
#import <CloudroomVideoSDK_IOS/CloudroomCommonType.h>


/* 会议成员信息 */
CRVSDK_EXPORT
@interface MemberInfo : NSObject

@property (nonatomic, copy) NSString *userId; // 用户ID
@property (nonatomic, copy) NSString *nickName; // 昵称
@property (nonatomic, assign) int audioStatus; // 音频状态
@property (nonatomic, assign) int videoStatus; // 视频状态
@end

/* 会议属性 */
CRVSDK_EXPORT
@interface MeetingAttr : NSObject
@property (nonatomic, copy) NSString *value; // 属性值
@property (nonatomic, copy) NSString *lastModifyUserID; // 最后修改者
@property (nonatomic, assign) int lastModifyTs;  //最后的修改时间，1970-1-1 0:00:00以来的秒数|
@end

typedef NSMutableDictionary<NSString*, MeetingAttr*> MeetingAttrs;
typedef NSMutableDictionary<NSString*, MeetingAttrs*> UsrMeetingAttrs;


/* 音频配置信息 */
CRVSDK_EXPORT
@interface AudioCfg : NSObject

@property (nonatomic, copy) NSString *micName; // 麦克风设备(空代表默认设备)
@property (nonatomic, copy) NSString *speakerName; // 喇叭设备(空代表默认设备)
@property (nonatomic, assign) int agc; // 是否开启声音增益，0：不开启；1：开启(默认值)
@property (nonatomic, assign) int ans; // 是否开启降噪，0：不开启；1：开启（默认值）
@property (nonatomic, assign) int aec; // 是否开启回声消除，0：不开启；1：开启（默认值）
@property (nonatomic, assign) BOOL echoSuppression;
@property (nonatomic, assign) BOOL echoCancelDelay; 

@end

/* 麦克风状态 */

typedef enum
{
    AUNKNOWN = 0,
    ANULL,
    ACLOSE, // 关闭
    AOPEN, // 打开
    AOPENING, // 请求开麦中
} AUDIO_STATUS;

CRVSDK_EXPORT
@interface UsrVideoId : NSObject

@property (nonatomic, copy) NSString *userId; // 用户ID
@property (nonatomic, assign) short videoID; // 摄像头ID

@end

CRVSDK_EXPORT
@interface UsrVideoInfo : UsrVideoId

@property (nonatomic, copy) NSString *videoName; // 设备名
@property (nonatomic, copy) NSString *videoDevPath; // 设备路径

@end


typedef enum
{
    VSIZE_SZ_128 = 0, // 224*128,缺省:72kbps
    VSIZE_SZ_160, // 288*160,缺省:100kbps
    VSIZE_SZ_192, // 336*192,缺省:150kbps
    VSIZE_SZ_256, // 448*256,缺省:200kbps
    VSIZE_SZ_288, // 512*288,缺省:250kbps
    VSIZE_SZ_320, // 576*320,缺省:300kbps
    VSIZE_SZ_360, // 640*360,缺省:350kbps
    VSIZE_SZ_400, // 720*400,缺省:420kbps
    VSIZE_SZ_480, // 848*480,缺省:500kbps
    VSIZE_SZ_576, // 1024*576,缺省:650kbps
    VSIZE_SZ_720, // 1280*720,缺省:1mbps
    VSIZE_SZ_1080, // 1920*1080,缺省:2mbps
} VIDEO_SIZE_TYPE;

/* 视频格式 */

typedef enum
{
    VFMT_UNKNOW = -1,    //未知格式
    VFMT_YUV420P = 0,
    VFMT_ARGB32,        //ARGB format (0xAARRGGBB).
    VFMT_RGBA32,
} VIDEO_FORMAT;

// added by king 20170906

typedef NS_ENUM(NSInteger, VIDEO_WHRATE_TYPE)
{
    WHRATE_16_9 = 0, // default w:d = 16:9
    WHRATE_4_3, // w:d = 4:3
    WHRATE_1_1 // w:d = 1:1
};

/* 图像信息 */
CRVSDK_EXPORT
@interface VideoFrame : NSObject
@property (nonatomic, strong) NSData* picData;
@property (nonatomic, assign) int camShowNo; // 摄像头显示序号(0开始编号)
@property (nonatomic, assign) VIDEO_FORMAT fmt;	// 图像格式
@property (nonatomic, assign) int datLength; // 图像大小
@property (nonatomic, assign) int frameWidth; // 图像大小
@property (nonatomic, assign) int frameHeight;
@property (nonatomic, assign) unsigned long long frmTime;

@end

/* 视频配置信息 */
CRVSDK_EXPORT
@interface VideoCfg : NSObject
@property (nonatomic, assign) CGSize size; // 视频尺寸
@property (nonatomic, assign) int fps; // 视频帧率(5~30)
@property (nonatomic, assign) int maxbps; // 视频码率
@property (nonatomic, assign) int minQuality; // 质量范围_最小
@property (nonatomic, assign) int maxQuality; // 质量范围_最大(质量最差)
@end

CRVSDK_EXPORT
@interface VideoEffects : NSObject
@property (nonatomic, assign) CGSize size; // 视频尺寸
@property (nonatomic, assign) BOOL denoise; // 视频降噪
@property (nonatomic, assign) BOOL upsideDown; // 视频上下翻转
@property (nonatomic, assign) int degree; // 视频旋转
@property (nonatomic, assign) int mirror; // 视频左右镜像
@end


CRVSDK_EXPORT
@interface CamAttribute : NSObject
@property (nonatomic, assign) bool disabled; // 视频帧率(5~30)
@property (nonatomic, strong) VideoCfg*  quality1_cfg;
@property (nonatomic, strong) VideoCfg*  quality2_cfg;
@end


/* 摄像头状态 */

typedef enum
{
    VUNKNOWN = 0,
    VNULL,
    VCLOSE, // 关闭
    VOPEN, // 打开
    VOPENING // 请求开摄像头中
} VIDEO_STATUS;

/**********屏幕共享**********/
CRVSDK_EXPORT
@interface ScreenShareCfg : NSObject
@property (nonatomic, assign) int maxFPS;                //最大帧率(缺省8)
@property (nonatomic, assign) int maxKbps;            //最大码率(缺省800kbps)
@end

/* 屏幕共享图像信息 */
CRVSDK_EXPORT
@interface ScreenShareImg : NSObject
{
@public void *rgbDat; // 图像数据
}

@property (nonatomic, assign) int datLength; // 图像大小
@property (nonatomic, assign) int rgbWidth; // 宽
@property (nonatomic, assign) int rgbHeight; // 高

@end

/* 标注 */
CRVSDK_EXPORT
@interface MarkData : NSObject

@property (nonatomic, assign) short termid; // ID
@property (nonatomic, copy) NSString* markid; // SN
@property (nonatomic, assign) int type; // 画笔颜色
@property (nonatomic, copy) NSArray<NSNumber *> *mousePosSeq;

@end


typedef enum
{
    MEDIA_CLOSE = 0,
    MEDIA_FINI,
    MEDIA_FILEOPEN_ERR, // 打开文件错误
    MEDIA_FORMAT_ERR, // 格式错误
    MEDIA_UNSUPPORT, // 不支持
    MEDIA_EXCEPTION, // 异常
} MEDIA_STOP_REASON;


typedef enum
{
    MEDIA_START, // 开始
    MEDIA_PAUSE, // 暂停
    MEDIA_STOP // 停止
} MEDIA_STATE;

/**********录制**********/
// added by king 20170801
typedef NS_ENUM(NSInteger, REC_CONTENT_TYPE) {
    RECVTP_VIDEO = 0, // 摄像头,_itemDat中应有:camid=MeetingSDK::CamID
    RECVTP_PIC, // 图片,_itemDat中应有:resourceid=xxx
    RECVTP_SCREEN, // 整个屏幕,_itemDat中可以有:screenid=-1;pid=x;area=QRect
    RECVTP_MEDIA, // 影音共享
    RECVTP_TIMESTAMP, // 时间戳水印,_itemDat中应有:resourceid=xxx
    RECVTP_REMOTE_SCREEN,    //远端屏幕
};


typedef NS_ENUM(NSInteger, REC_FILE_STATE) {
    RFS_NoUpload = 0, // 初始值
    RFS_Uploading, // 上传中
    RFS_Uploaded, // 已上传
    RFS_UploadFail // 上传失败
};


typedef NS_ENUM(NSInteger, REC_ERR_TYPE) {
    ERR_NULL = 0, // 初始值
    CATCH_SCREEN_ERR, // 捕捉屏幕出错
    RECORD_MAX, // 超越阈值
    NO_DISK, // 空间不足
    OTHRE_ERR ,// 其他错误
    PARAMS_ERR,
    CFG_RESTRICTED,
    MIXER_NOT_EXIST,
    MIXER_ALREADY_EXIST,
    FILE_ERR,
};





typedef NS_OPTIONS(NSInteger, REC_DATA_TYPE) {
    REC_AV_DEFAULT	= 0x0,
    //音频
    REC_AUDIO_LOC	= 0x1,
    REC_AUDIO_OTHER	= 0x2,
    //视频
    REC_VIDEO		= 0x4,
};

/* 媒体信息 */
CRVSDK_EXPORT
@interface MediaInfo : NSObject

@property (nonatomic, copy) NSString *userID; // 用户ID
@property (nonatomic, assign) MEDIA_STATE state; // 状态
@property (nonatomic, copy) NSString *mediaName; // 名称

@end

/* 媒体数据信息 */
CRVSDK_EXPORT
@interface MediaDataFrame : NSObject
{
@public void *buf; // 图像数据
}

@property (nonatomic, assign) int datLength; // 图像大小
@property (nonatomic, assign) int fmt; // 格式
@property (nonatomic, assign) int w; // 宽
@property (nonatomic, assign) int h; // 高
@property (nonatomic, assign) int64_t ms; // PTS

@end

/**********录制**********/
// added by king 20170801
/* 录制配置信息 */
CRVSDK_EXPORT
@interface RecCfg : NSObject

@property (nonatomic, copy) NSString *filePathName;	// 目标文件名
@property (nonatomic, assign) int fps; // 帧率,建议不要太高(取值1~24)
@property (nonatomic, assign) CGSize dstResolution; // 目标分辨率
@property (nonatomic, assign) int maxBPS; // 码率(720p 1mbps, 1080p 2mbps)
@property (nonatomic, assign) int defaultQP; // 目标质量(推荐:低:36, 中:28, 高:22)
@property (nonatomic, assign) REC_DATA_TYPE recDataType; // 录制内容类型(视频+音频)
@property (nonatomic, assign) BOOL isUploadOnRecording; // 是否边录边上传,默认是NO
@property (nonatomic, copy) NSString *serverPathFileName; // 文件上传后在服务器上的相对路径和文件名
@property (nonatomic, assign) BOOL createRepairFile; // 产生异常终止修复文件（mp4/avi需要)
@property (nonatomic, assign) BOOL bEncrypt; // 是否加密录制文件
@end

/* 录制信息 */
CRVSDK_EXPORT
// modified by king 20170919
/* 录制元素基类 */
@interface RecContentItem : NSObject
{
@public
    NSDictionary<NSString *, NSString *> *_itemDat;
}

@property (nonatomic, assign) REC_CONTENT_TYPE type; // 录制类型
@property (nonatomic, assign) CGRect itemRt; // 区域
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *itemDat; // 数据
@property (nonatomic, assign) BOOL keepAspectRatio; // 保持比例

@end
/* 视频 */
CRVSDK_EXPORT
@interface RecVideoContentItem : RecContentItem

- (instancetype)initWithRect:(CGRect)itemRt userID:(NSString *)userID camID:(short)camID;

@end

/* 图片 */
CRVSDK_EXPORT
@interface RecPictureContentItem : RecContentItem

- (instancetype)initWithRect:(CGRect)itemRt resID:(NSString *)resID;

@end

/* 时间戳 */
CRVSDK_EXPORT
@interface RecTimeStampContentItem : RecContentItem

- (instancetype)initWithRect:(CGRect)itemRt resID:(NSString *)resID;

@end

/* 影音共享 */
CRVSDK_EXPORT
@interface RecMediaContentItem : RecContentItem

- (instancetype)initWithRect:(CGRect)itemRt;

@end

/* 整个屏幕 */
CRVSDK_EXPORT
@interface RecScreenContentItem : RecContentItem

@end

/* 录制文件信息 */
CRVSDK_EXPORT
@interface RecFileShow : NSObject

@property (nonatomic, copy) NSString *fileName; // 文件名
@property (nonatomic, assign) int fileSize; // 文件大小
@property (nonatomic, copy) NSString *startTime; // 开始时间
@property (nonatomic, assign) REC_FILE_STATE state; // 录制状态
@property (nonatomic, assign) int uploadPercent; // 上传进度
@property (nonatomic, assign) int duration;
@property (nonatomic, copy) NSString *resolution;
@end

typedef NS_ENUM(NSInteger, MIXER_STATE) {
    NO_RECORD = 0, // 初始值
    STARTING, // 准备开始
    RECORDING, // 录制中
    PAUSED, // 暂停
    STOPPING // 停止中
};
CRVSDK_EXPORT
@interface MixerCfg : NSObject
@property (nonatomic, assign) int fps; // 帧率,建议不要太高(取值1~24)
@property (nonatomic, assign) CGSize dstResolution; // 目标分辨率
@property (nonatomic, assign) int maxBPS; // 码率(720p 1mbps, 1080p 2mbps)
@property (nonatomic, assign) int defaultQP; // 目标质量(推荐:低:36, 中:28, 高:22)
@property (nonatomic, assign) int gop; // I帧周期（直播建议fps*4 普通文件录制建议fps*15）
@end

CRVSDK_EXPORT
@interface MixerContent : NSObject
@property (nonatomic, strong) NSMutableArray <RecContentItem *>* contents; //混图器内容配置
@end

typedef NS_ENUM(NSInteger, OUT_TYPE) {
    
    OUT_FILE = 0,
    OUT_LIVE,
};

typedef NS_ENUM(NSInteger,OUTPUT_STATE)
{
    OUTPUT_NONE = 0,
    OUTPUT_CREATED,
    OUTPUT_WRITING,
    OUTPUT_CLOSED,
    
    OUTPUT_ERR,
};

CRVSDK_EXPORT
@interface OutputInfo : NSObject
@property (nonatomic, assign) OUTPUT_STATE  state;
@property (nonatomic, assign) long long int durationMs;
@property (nonatomic, assign) long long int fileSize;
@property (nonatomic, assign) REC_ERR_TYPE errCode;
@end

CRVSDK_EXPORT
@interface OutputCfg : NSObject
@property (nonatomic, assign) OUT_TYPE type;
//录制配置
@property (nonatomic, copy) NSString *fileName; // 文件名
@property (nonatomic, assign) int encryptType; //是否加密
@property (nonatomic, assign) BOOL isUploadOnRecording; // 是否边录边上传，默认是false
@property (nonatomic, copy) NSString *serverPathFileName; //文件上传后在服务器上的相对路径和文件名
//直播配置
@property (nonatomic, copy) NSString *liveUrl; //目标url
@property (nonatomic, assign) BOOL live; //开启云屋直播（由服务器替换_liveUrl）
@property (nonatomic, assign) int errRetryTimes; //失败时重试次数CRVSDK_EXPORT
@end

CRVSDK_EXPORT
@interface MixerOutput : NSObject
@property (nonatomic, strong) NSMutableArray <OutputCfg *> *outputs;
@end

/* added by king 20180312 */
CRVSDK_EXPORT
@interface CLBaseView : UIView

@property (nonatomic, assign) BOOL keepAspectRatio;
/**
 绘制视频size
 */
-(CGSize)getVideoSize;
/**
 清除画面
 */
- (void)clearFrame;
@end

CRVSDK_EXPORT
@interface CLCameraView : CLBaseView

@property (nonatomic, strong) UsrVideoId *usrVideoId;
@property (nonatomic, assign) int camShowNO;
@property (nonatomic, assign) CGSize videoSize;

-(UIImage*)getVideoImage;
-(void)setUsrVideoId:(UsrVideoId *)usrVideoId;
-(void)setUsrVideoId:(UsrVideoId *)usrVideoId qualityLv:(int)qualityLv;
@end

CRVSDK_EXPORT
@interface CLCameraFloatView : CLCameraView

@end

CRVSDK_EXPORT
@interface CLMediaView : CLBaseView

@end

CRVSDK_EXPORT
@interface CLShareView : UIView
@property (nonatomic, assign) BOOL isSharer;
-(void)clearFrame;
- (void)setShareSrcSize:(CGSize)shareSrcSize;
-(void)updateScreenView;
-(void)setDelTime:(double)time;
-(void)setMarkColor:(UIColor*)color;
-(void)setMarkLineW:(int)lineW;
@end

/**< 画笔形状 */
typedef NS_ENUM(NSInteger, ShapeType)
{
    ST_curve = 0, /**< 曲线(默认) */
    ST_line, /**< 直线 */
    ST_ellipse, /**< 椭圆 */
    ST_rect, /**< 矩形 */
};

@class CLBrushView;
@protocol BKBrushViewDelegate <NSObject>

@optional
- (void)brushView:(CLBrushView *)brushView touchMovedWithImage:(UIImage *)image;
- (void)brushView:(CLBrushView *)brushView touchEndWithImage:(UIImage *)image;

- (void)brushView:(CLBrushView *)brushView touchEndWithMarkData:(MarkData *)markData;

@end

CRVSDK_EXPORT
@interface CLBrushView : UIView

@property (nonatomic, strong) UIColor *brushColor; /** 颜色 */
@property (nonatomic, assign) CGFloat brushWidth; /**< 宽度 */
@property (nonatomic, assign) ShapeType shapeType; /**< 形状 */
@property (nonatomic, strong) id <BKBrushViewDelegate> delegate; /**< 代理 */
@property (nonatomic, assign) CGSize shareSrcSize;

/**
 撤销
 */
- (void)unDo;

/**
 清除绘制
 */
- (void)clean;

- (void)drawLine:(MarkData *)markData;

@end

/**个各个模块 */
typedef NS_ENUM(NSInteger, MainPageType)
{
    MAINPAGE_UNKNOW = -1,
    MAINPAGE_VIDEOWALL = 0,
    MAINPAGE_SCREENSHARE,
    MAINPAGE_WHITEBOARD,
    MAINPAGE_MEDIASHARE
};//视频墙、共享、白板

/* 白板 (king 20180716) */
CRVSDK_EXPORT
@interface SubPage : NSObject

@property (nonatomic, assign) short termID;
@property (nonatomic, assign) short localID;

@end

CRVSDK_EXPORT
@interface SubPageInfo : NSObject

@property (nonatomic, strong) SubPage *boardID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int pageCount;
@property (nonatomic, assign) int curPage;
@property (nonatomic, assign) int pagePos1;
@property (nonatomic, assign) int pagePos2;
@end

/* 文档列表*/
CRVSDK_EXPORT
@interface NetDiskDocDir : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray <FileInfo *>* files;
@property (nonatomic, strong) NSMutableArray <NetDiskDocDir *>* dirs;
@end

/*获取文档页信息结果 */
CRVSDK_EXPORT
@interface GetDocPageInfoRslt : NSObject
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) NSMutableArray <NSString *>* files;
@end

#pragma mark ----------------------------------------------- 视频会议回调接口
@protocol CloudroomVideoMeetingCallBack <NSObject>

@optional

/**********会议**********/

/**
 进入会议回调
 (入会失败,将自动发起releaseCall）
 @param code 结果码
 */
- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code;


/**
 结束会议回调
 @param code 结果码
 */
- (void)stopMeetingRslt:(CRVIDEOSDK_ERR_DEF)code;


/**
 会议被结束回调
 */
- (void)meetingStopped;


- (void)kickoutRslt:(CRVIDEOSDK_ERR_DEF)sdkErr userID:(NSString*)userID;

/**
 会议状态改变
 */
-(void)notifyRoomStateChanged:(bool)lock;

/**
 会议锁门失败
 */
-(void)notifyLockRoomFail:(bool)lock;

/**
 成员进入会议
 @param userID 用户ID
 */
- (void)userEnterMeeting:(NSString *)userID;


/**
 成员离开会议
 @param userID 用户ID
 */
- (void)userLeftMeeting:(NSString *)userID;


/**
 网络状态改变回调
 最新网络评分0~10(10分为最佳网络)
 @param level 网络等级
 */
- (void)netStateChanged:(int)level;


/**********音频**********/

/**
 麦声音强度更新回调
 (level取值0~10)
 @param userID 用户ID
 @param oldLevel 旧等级
 @param newLevel 新等级
 */
- (void)micEnergyUpdate:(NSString *)userID oldLevel:(int)oldLevel newLevel:(int)newLevel;


/**
 本地音频设备变化回调
 */
- (void)audioDevChanged;


/**
 通知语音PCM数据
 
 @param aSiden 声道类型
 @param audioDat  PCM数据
 */
-(void)audioPCMData:(int)aSiden audioDat:(NSData*)audioDat;


/**
 全体静音通知
 */
-(void)notifyAllAudioClose:(NSString*)userID;
/**
 音频设备状态变化
 @param userID 用户ID
 @param oldStatus 旧状态
 @param newStatus 新状态
 */
- (void)audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus;


/**********视频**********/

/**
 视频设备状态变化回调
 @param userID 用户ID
 @param oldStatus 旧状态
 @param newStatus 新状态
 */
- (void)videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus;


/**
 打开视频设备回调
 @param bSuccess 是否成功打开
 */
- (void)openVideoRslt:(NSString *)devID success:(BOOL)bSuccess;


/**
 成员有新的视频图像数据到来回调
 (通过GetVideoImg获取）
 @param userID 用户ID
 @param frameTime 视频帧
 */
- (void)notifyVideoData:(UsrVideoId *)userID frameTime:(long)frameTime;


/**
 本地视频设备变化回调
 @param userID 用户ID
 */
- (void)videoDevChanged:(NSString *)userID;


/**
 本地默认视频设备变化回调
 @param userID 用户ID
 @param videoID 摄像头ID
 */
- (void)defVideoChanged:(NSString *)userID videoID:(short)videoID;


/**********屏幕共享**********/

/**
 主动开启了屏幕共享结果
 
 @param sdkErr sdkErr
 */
-(void)startScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 主动停止了屏幕共享
 
 @param sdkErr sdkErr
 */
-(void)stopScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;
/**
 通知他人屏幕共享开始回调
 */
- (void)notifyScreenShareStarted;

/**
 请求屏幕共享通知
 */
-(void)notifyRequestShare:(NSString*)shareId requestId:(NSString*)requestId param:(NSString*)param;

/**
 取消屏幕共享通知
 */
-(void)notifyCancelShareRequestion:(NSString*)shareId requestId:(NSString*)requestId;

/**
 拒绝屏幕共享请求通知
 */
-(void)notifyRejectShareRequestion:(NSString*)shareId requestId:(NSString*)requestId param:(NSString*)param;


/**
 通知他人屏幕共享停止回调
 */
- (void)notifyScreenShareStopped;


/**
 屏幕共享数据更新回调
 用户收到该回调消息后应该调用getShareScreenDecodeImg获取最新的共享数据
 @param userID 用户ID
 @param changedRect 改变区域
 @param size 帧数据大小
 */
- (void)notifyScreenShareData:(NSString *)userID changedRect:(CGRect)changedRect frameSize:(CGSize)size;

/**
 通知该自定义抓屏了
 */
-(void)notifyCatchScreen;

/**
 赋予控制权限通知
 */
-(void)notifyGiveCtrlRight:(NSString*)operId targetId:(NSString*)targetId;


/**
 收回控制权限通知
 */
-(void)notifyReleaseCtrlRight:(NSString*)operId targetId:(NSString*)targetId;


/**
 屏幕共享尺寸变化
 */
-(void)notifyShareRectChanged:(CGRect)rect;

-(void)notifyScreenShareCtrlMouseMsg:(int)eventType xPos:(int)xPos yPos:(int)yPos mouseData:(int)mouseData;

-(void)notifyScreenShareCtrlKeyMsg:(int)keyCode bExtendedKey:(BOOL)bExtendedKey bKeyDonw:(BOOL)bKeyDonw;
/**********IM**********/
// IM消息发送结果
- (void)sendIMmsgRlst:(NSString *)taskID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 通知收到文本消息
- (void)notifyIMmsg:(NSString *)romUserID text:(NSString *)text sendTime:(int)sendTime;

-(void)sendCustomMeetingMsgRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)notifyCustomMeetingMsg:(NSString *)fromUserID jsonDat:(NSString *)jsonDat;

/**********录制**********/
// added by king 20170802

/**
 录制过程出错(导致录制停止)回调
 @param sdkErr 错误码
 */
- (void)recordErr:(REC_ERR_TYPE)sdkErr;


/**
 本地录制文件，本地直播信息通知
 @param mixerID 混图器唯一标识
 @param nameUrl 录像名称或直播Url
 @param outputInfo 输出信息
 */
-(void)locMixerOutputInfo:(NSString*)mixerID nameUrl:(NSString*)nameUrl outputInfo:(OutputInfo*)outputInfo;

/**
 录制过程状态改变回调
 @param state 录制状态
 */
- (void)recordStateChanged:(MIXER_STATE)state;

/**
 录制过程状态改变回调
 @param state 录制状态
 */
- (void)locMixerStateChanged:(NSString*)mixerID state:(MIXER_STATE)state;
/**
 录制文件上传进度回调
 @param fileName 录制文件路径
 @param percent 上传进度
 */
- (void)notifyRecordFileUploadProgress:(NSString *)fileName percent:(int)percent;


- (void)notifyRecordFileStateChanged:(NSString *)fileName state:(REC_FILE_STATE)state;

/**
 录制文件上传成功回调
 @param fileName 录制文件名称
 @param fileUrl 录制文件路径
 */
- (void)uploadRecordFileSuccess:(NSString *)fileName fileUrl:(NSString *)fileUrl;


/**
 录制文件上传出错回调
 @param fileName 录制文件路径
 @param sdkErr 错误码
 */
- (void)uploadRecordFile:(NSString *)fileName err:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**********云端录制**********/
// added by king 20180327

/**
 云端录制状态改变
 @param state 云端录制状态
 @param sdkErr 错误码
 */
- (void)svrRecordStateChanged:(MIXER_STATE)state err:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 云端录制状态改变 新接口
 @param state 云端录制状态
 @param sdkErr 错误码
 @param opratorID 混图id
 */
- (void)svrMixerStateChanged:(MIXER_STATE)state err:(CRVIDEOSDK_ERR_DEF)sdkErr opratorID:(NSString*)opratorID;


- (void)startSvrMixerFailed:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 云端录制、云端直播内容变化通知
 */
-(void)svrMixerCfgChanged;

/**
 云端录制文件、云端直播信息变化通知
 @param outputInfo 录制文件、直播信息通知
 */
-(void)svrMixerOutPutInfo:(OutputInfo*)outputInfo;

-(void)svrMixerOutPutJsonInfo:(NSString*)outputInfo;


/**********影音**********/

/**
 影音开始播放回调
 @param userid 用户ID
 */
- (void)notifyMediaStart:(NSString *)userid;


/**
 影音暂停播放回调
 @param userid 用户ID
 @param bPause 影音是否暂停
 */
- (void)notifyMediaPause:(NSString *)userid bPause:(BOOL)bPause;


/**
 影音停止播放回调
 @param userid 用户ID
 @param reason 停止播放原因
 */
- (void)notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason;


/**
 视频帧数据已解好回调
 @param userid 用户ID
 */
- (void)notifyMemberMediaData:(NSString *)userid curPos:(int)curPos;


// added by king 20170818

/**
 本地播放成功
 @param totalTime 时长
 @param picSZ 图像尺寸
 */
- (void)notifyMediaOpened:(long)totalTime size:(CGSize)picSZ;


/**
 设定播放位置完成
 @param setPTS 播放位置
 */
- (void)notifyPlayPosSetted:(int)setPTS;


/**********UI回调同步**********/
// added by king 20170803
/**
 视频墙分屏模式回调
 @param wallMode 分屏模式(0:互看 1:1分屏 2:2分屏 3:4分屏 4:5分屏 5:6分屏 6:9分屏 7:13分屏 8:16分屏)
 */
- (void)notifyVideoWallMode:(int)wallMode;


// added by king 20170810

/**
 开始屏幕共享时, 标注操作结果
 @param sdkErr sdkErr
 */
-(void)startScreenMarkRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 结束屏幕共享时, 标注操作结果
 @param sdkErr sdkErr
 */
-(void)stopScreenMarkRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;
/**
 主视频回调
 */
- (void)notifyMainVideo;

/**********标注回调**********/
- (void)notifyScreenMarkStarted;
- (void)notifyScreenMarkStopped;
- (void)enableOtherMark:(BOOL)enable;
- (void)sendMarkData:(MarkData *)markData;
- (void)sendAllMarkData:(NSArray<MarkData *> *)markDatas;
- (void)clearAllMarks;
//v4接口
- (void)delMarkData:(NSArray<NSString *> *)data operatorID:(NSString*)operatorID;


-(void)getSharerSrcPicRsp:(NSData*)picDat picSZ:(CGSize)picSZ;

/* 网盘 */
-(void)getNetDiskFileListRslt:(NetDiskDocDir*)dirNode;

//通知会议网盘上传下载进度
-(void)notifyNetDiskTransforProgress:(NSString*)fileID percent:(int)percent isUpload:(bool)isUpload;


/* 白板 (king 20180716) */
/**
 通知之前已经创建好的白板
 @param boards 已经创建好的白板列表
 */
- (void)notifyInitBoards:(NSArray<SubPageInfo *> *)boards;

/**
 通知之前已经创建好的白板上的图元数据
 @param boardID 白板子功能页ID
 @param boardPageNo 图元数据
 @param bkImgID 背景图片
 @param elements 图元信息列表
 @param operatorID 操作者
 */
- (void)notifyInitBoardPageDat:(SubPage *)boardID boardPageNo:(int)boardPageNo bkImgID:(NSString *)bkImgID elements:(NSString *)elements operatorID:(NSString *)operatorID;

/**
 通知创建子功能页白板
 @param board 子功能页信息
 @param operatorID 操作者
 */
- (void)notifyCreateBoard:(SubPageInfo *)board operatorID:(NSString *)operatorID;

/**
 通知关闭白板
 @param boardID 白板子功能页ID
 @param operatorID 操作者
 */
- (void)notifyCloseBoard:(SubPage *)boardID operatorID:(NSString *)operatorID;

/**
 通知添加图元信息
 @param boardID 白板子功能页ID
 @param boardPageNo 页码
 @param element 图元信息
 @param operatorID 操作者
 */
- (void)notifyAddBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID;

/**
 通知修改图元信息
 @param boardID 白板子功能页ID
 @param boardPageNo 页码
 @param element 图元信息
 @param operatorID 操作者
 */
- (void)notifyModifyBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID;

/**
 通知删除图元
 @param boardID 白板子功能页ID
 @param boardPageNo 页码
 @param elementIDs 图元ID列表
 @param operatorID 操作者
 */
- (void)notifyDelBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementIDs:(NSArray<NSString *> *)elementIDs operatorID:(NSString *)operatorID;

/**
 通知设置鼠标热点消息
 @param boardID 白板子功能页ID
 @param boardPageNo 页码
 @param x 位置x
 @param y 位置y
 @param operatorID 操作者
 */
- (void)notifyMouseHotSpot:(SubPage *)boardID boardPageNo:(int)boardPageNo x:(int)x y:(int)y operatorID:(NSString *)operatorID;

-(void)notifyBoardCurPageNo:(SubPage *)boardID boardPageNo:(int)boardPageNo pos1:(int)pos1 pos2:(int)pos2 operatorID:(NSString*)operatorID;

-(void)notifySwitchToPage:(MainPageType)mainPage subPage:(SubPage*)sPage;

-(void)setNickNameRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userid:(NSString*)userid newName:(NSString*)newName;

-(void)notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName;

//通知查询文档列表结果
-(void)listNetDiskDocFileRslt:(NSString*)dir err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(NetDiskDocDir*)rslt;

//通知查询文档转换结果
-(void)getNetDiskDocFilePageInfoRslt:(NSString*)svrPathFileName err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(GetDocPageInfoRslt*)rslt;

//通知删除文档结果
-(void)deleteNetDiskDocFileRslt:(NSString*)svrPathFileName sdkERR:(int)sdkERR;

//通知网盘文档传输进度
-(void)notifyNetDiskDocFilePageTransforProgress:(NSString*)svrPathFileName percent:(int)percent isUpload:(bool)isUpload;

//会议属性  用户属性
-(void)getMeetingAllAttrsSuccess:(MeetingAttrs*)attrSeq cookie:(NSString *)cookie;

-(void)getMeetingAllAttrsFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)resetMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)addOrUpdateMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)delMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)clearMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)getUserAttrsSuccess:(UsrMeetingAttrs*)attrMap cookie:(NSString *)cookie;

-(void)getUserAttrsFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)setUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)addOrUpdateUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)delUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)clearAllUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)clearUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

-(void)notifyMeetingAttrsChanged:(MeetingAttrs*)add updates:(MeetingAttrs*)updates delKeys:(NSMutableArray<NSString*>*)delKeys;

-(void)notifyUserAttrsChanged:(NSString*)uid adds:(MeetingAttrs*)adds updates:(MeetingAttrs*)updates delKeys:(NSMutableArray<NSString*>*)delKeys;

@end

#pragma mark ----------------------------------------------- 视频会议类
CRVSDK_EXPORT
@interface CloudroomVideoMeeting : NSObject

/**
 单例方法
 @return 单例对象
 */
+ (CloudroomVideoMeeting *)shareInstance;


/**
 设置回调
 @param callBack 代理对象
 */
- (void)setMeetingCallBack:(id <CloudroomVideoMeetingCallBack>)callBack;

/**
 注册回调
 @param callBack 代理对象
 */
- (void)registerMeetingCallback:(id <CloudroomVideoMeetingCallBack>)callBack;

/**
 移除回调
 @param callBack 多代理模式移除代理对象
 */
-(void) removeMeetingCallBack:(id<CloudroomVideoMeetingCallBack>)callBack;

#pragma mark ----------------------------------------------- 会议接口

/**
 进入会议
 (只有入会成功,才能进行后续操作)
 @param meetID 会议ID
 */
- (void)enterMeeting:(int)meetID;

/**
 进入会议
 (只有入会成功,才能进行后续操作)
 @param meetID 会议ID
 @param pswd 会议密码
 @param userID 用户ID
 @param nikeName 用户昵称
 */
- (void)enterMeeting:(int)meetID
                pswd:(NSString *)pswd
              userID:(NSString *)userID
            nikeName:(NSString *)nikeName DEPRECATED_MSG_ATTRIBUTE("use enterMeeting: instead");

/**
 离开会议
 */
- (void)exitMeeting;

// 锁门
- (void)lockRoom:(bool)lock;
- (bool)isRoomLocked;

/**
 检查指定用户是否进入了会议
 @param userID 用户ID
 @return 指定用户是否进入了会议
 */
- (BOOL)isUserInMeeting:(NSString *)userID;

/**
 获取自身的 userID(进入会议成功才能使用)
 @return 自身的 userID
 */
- (NSString *)getMyUserID;


-(short)getMyTermID;

/**
 获取指定用户昵称
 @param userID 用户ID
 @return 用户昵称
 */
- (NSString *)getNickName:(NSString *)userID;

- (void)setNickName:(NSString*)userID nickName:(NSString*)nickName;

/**
 获取会议成员列表
 @return 会议成员列表
 */
- (NSMutableArray <MemberInfo *> *)getAllMembers;

/**
 获取指定会议成员信息
 @param userId 用户ID
 @return 指定会议成员信息
 */
- (MemberInfo *) getMemberInfo:(NSString *)userId;

#pragma mark ----------------------------------------------- 音频接口
/**
 麦克风设置
 */
-(void) setAudioCfg:(AudioCfg*)cfg;

/**
 获取麦克风设置
 
 @return 麦克风设置
 */
-(AudioCfg*) getAudioCfg;

/**
 麦克风音量增益
 
 @param scale  麦克风音量增益（范围：1-20）
 @return 是否成功
 */
-(bool)setMicVolumeScaling:(int)scale;

/**
 获取本地麦音量(level:0~100)
 @return 本地麦音量
 */
- (int)getMicVolume;

/**
 设置本地麦音量(level:0~100)
 @param level 本地麦音量
 @return 设置是否成功
 */
- (bool)setMicVolume:(int)level;

/**
 获取本地喇叭音量(level:0~100)
 @return 本地喇叭音量
 */
- (int)getSpeakerVolume;

/**
 设置本地喇叭音量(level:0~100)
 @param level 本地喇叭音量
 @return 设置是否成功
 */
- (bool)setSpeakerVolume:(int)level;

/**
 开麦
 @param userId 用户ID
 */
- (void)openMic:(NSString *)userId;


/**
 关麦
 @param userId 用户ID
 */
- (void)closeMic:(NSString *)userId;

/**
 全体静音
 */
-(void)setAllAudioClose;

/**
 得到自已或对端的说话声音大小
 (userID为登录成功后分配的userID)
 @param userID 用户ID
 @return 声音大小
 */
- (int)getMicEnergy:(NSString *)userID;


/**
 获取音频状态
 @param userID 用户ID
 @return 音频状态
 */
- (AUDIO_STATUS)getAudioStatus:(NSString *)userID;


/**
 设置外放状态
 @param speakerOut 外放状态
 @return 设置是否成功
 */
- (BOOL)setSpeakerOut:(BOOL)speakerOut;


/**
 获取外放状态
 @return 外放状态
 */
- (BOOL)getSpeakerOut;


/**
 设置扬声器是否静音
 @param bMute 扬声器是否静音
 */
- (void)setSpeakerMute:(BOOL)bMute;


/**
 查询扬声器是否静音
 @return 扬声器是否静音
 */
- (BOOL)getSpeakerMute;

// added by king 201710131139

/**
 设置图片资源
 @param resID 资源ID
 @param frame 媒体数据
 */
- (void)setPicResource:(NSString *)resID mediaDataFrame:(MediaDataFrame *)frame;

-(void) rmPicResource:(NSString *)resID;

#pragma mark ----------------------------------------------- 视频接口
/**
 设置视频配置信息
 @param cfg 视频配置信息
 @return 设置是否成功
 */
- (BOOL)setVideoCfg:(VideoCfg *)cfg;


/**
 获取视频配置信息
 @return 视频配置信息
 */
- (VideoCfg *)getVideoCfg;

-(BOOL)setVideoEffects:(VideoEffects*)effects;

-(VideoEffects*)getVideoEffects;

/**
 获取指定用户视频状态
 @param userID 用户ID
 @return 指定用户视频状态
 */
- (VIDEO_STATUS)getVideoStatus:(NSString *)userID;


/**
 打开本地视频
 @param userID 用户ID
 */
- (void)openVideo:(NSString *)userID;


/**
 关闭本地视频
 @param userID 用户ID
 */
- (void)closeVideo:(NSString *)userID;


/**
 设置视频订阅者
 @param videoIds 视频订阅者列表
 */
- (void)watchVideos:(NSMutableArray <UsrVideoId *> *)videoIds;

/**
 获取自己或他人的图像数据
 @param userID 用户ID
 @return 图像数据
 */
- (VideoFrame *)getVideoImg:(UsrVideoId *)userID;


/**
 设置/获取默认摄像头、多摄像头信息(自己videoIdList可以多个,远端只能一个)
 @param userId 用户ID
 @return 摄像头信息列表
 */
- (NSMutableArray <UsrVideoInfo *> *)getAllVideoInfo:(NSString *)userId;


/**
 设置默认摄像头
 @param userId 用户ID
 @param videoID 摄像头ID
 */
- (void)setDefaultVideo:(NSString *)userId videoID:(short)videoID;


/**
 获取默认摄像头
 @param userId 用户ID
 @return 摄像头ID
 */
- (short)getDefaultVideo:(NSString *)userId;


/**
 获取视频订阅者
 @return 视频订阅者列表
 */
- (NSMutableArray <UsrVideoId *> *)getWatchableVideos;

//custom Cams
-(int) createCustomVideoDev:(NSString*)camName pixFmt:(VIDEO_FORMAT)pixFmt width:(int)width height:(int)height extParams:(NSString*)extParams;

-(void) destroyCustomVideoDev:(int)devID;

-(void) inputCustomVideoDat:(int)devID data:(NSData*)data timeStamp:(int)timeStamp;

-(int) createScreenCamDev:(NSString*)camName  monitor:(int)monitor;

-(bool) updateScreenCamDev:(int)devID tmonitor:(int)monitor;

-(void) destroyScreenCamDev:(int)devID;
#pragma mark ----------------------------------------------- 屏幕共享接口
/**
 屏幕共享是否已开始
 @return 是否已开始
 */
- (BOOL)isScreenShareStarted;

/**
 获取屏幕共享者
 @return 屏幕共享者
 */
- (NSString *)getScreenSharer;

/**
 获取屏幕共享图像数据
 此共享Image数据应该每次获取,外界不能缓存使用
 @return 屏幕共享图像数据
 */
- (UIImage *)getShareScreenDecodeImg;

-(UIImage*)getSharerSrcPic;

//设置屏幕共享参数
-(void) setScreenShareCfg:(ScreenShareCfg *)cfg;

//获取屏幕共享的参数
-(ScreenShareCfg*) getScreenShareCfg;

-(CGRect)getShareRect;

//发起屏幕共享
-(void) startScreenShare;

//停止取消屏幕共享
-(void) stopScreenShare;

-(void)startScreenMark;

-(void)stopScreenMark;

//赋予控制权限
-(void) giveCtrlRight:(NSString*)userId;
//收回控制权限
-(void) releaseCtrlRight:(NSString*)userId;

-(CGPoint)parseToScreenPoint:(CGPoint)point;

-(void) setCustomizeCatchScreen:(BOOL)bCustomize;//设置是否自定义抓屏

-(BOOL) isCustomizeCatchScreen;

-(void) setCustomizeScreenImg:(NSData*)yuvDat datLenght:(int)datLenght width:(int)width height:(int)height orientation:(YWOrientation)orientation;

#pragma mark ----------------------------------------------- IM接口
- (NSString *)sendIMmsg:(NSString *)text toUserID:(NSString *)toUserID;
- (NSString *)sendIMmsg:(NSString *)text toUserID:(NSString *)toUserID cookie:(NSString *)cookie;

-(void) sendMeetingCustomMsg:(NSString *)text cookie:(NSString *)cookie;

#pragma mark ----------------------------------------------- 录制接口
// added by king 20170801

/**
 设置录制设备
 @param videoIDs 录制设备列表
 */
- (void)setRecordVideos:(NSArray <RecContentItem *> *)videoIDs;


/**
 开始录制
 @param cfg 录制配置信息
 @return 录制开始是否成功
 */
- (BOOL)startRecording:(RecCfg *)cfg;


/**
 停止录制
 */
- (void)stopRecording;

/**
 获取录制文件大小
 @return 录制文件大小
 */
- (int)recordFileSize;


/**
 获取录制时间
 @return 录制时间
 */
- (int)recordDuration;


/**
 设置录制文件是否加密
 @param encrypt 是否加密
 */
- (void)setRecordFileEncrypt:(BOOL)encrypt;


/**
 回放指定录制文件
 @param fileName 录制文件路径
 */
- (void)playbackRecordFile:(NSString *)fileName;

/**********录制新接口**********/
-(CRVIDEOSDK_ERR_DEF)createLocMixer:(NSString*)mixerID  cfg:(MixerCfg*)cfg content:(MixerContent*)content;
-(CRVIDEOSDK_ERR_DEF)updateLocMixerContent:(NSString*)mixerID content:(MixerContent*)content;
-(void)destroyLocMixer:(NSString*)mixerID;
-(MIXER_STATE)getLocMixerState:(NSString*)mixerID;
-(CRVIDEOSDK_ERR_DEF)addLocMixer:(NSString*)mixerID outputs:(MixerOutput*)outputs;
-(void)rmLocMixerOutput:(NSString*)mixerID  nameOrUrls:(NSArray<NSString*>*)nameOrUrls;

//云端录制
-(CRVIDEOSDK_ERR_DEF)startSvrMixer:(NSMutableDictionary<NSString*,MixerCfg*>*)cfgs contents:(NSMutableDictionary<NSString*,MixerContent*>*)contents outputs:(NSMutableDictionary<NSString*,MixerOutput*>*)outputs;
-(CRVIDEOSDK_ERR_DEF)updateSvrMixerContent:(NSMutableDictionary<NSString*,MixerContent*>*)contents;
-(void)stopSvrMixer;
-(MIXER_STATE)getSvrMixerState;

-(CRVIDEOSDK_ERR_DEF)startSvrMixerJson:(NSString*)cfgs contents:(NSString*)contents outputs:(NSString*)outputs;
-(CRVIDEOSDK_ERR_DEF)updateSvrMixerContentJson:(NSString*)contents;

/**********录制文件管理**********/

/**
 获取所有录制文件
 @return 所有录制文件列表
 */
- (NSArray <RecFileShow *> *)getAllRecordFiles;

/**
 添加指定录制文件到录制管理
 @param fileName 录制文件名称
 @param filePath 录制文件路径
 @return 移除是否成功
 */
- (int)addFileToRecordMgr:(NSString *)fileName filePath:(NSString *)filePath;

/**
 移除指定录制文件从录制管理
 @param fileName 录制文件路径
 @return 移除是否成功
 */
- (int)removeFromFileMgr:(NSString *)fileName;


/**
 上传指定录制文件
 @param fileName 录制文件名称
 */
- (void)uploadRecordFile:(NSString *)fileName;


/**
 上传指定录制文件
 @param fileName 录制文件名称
 @param svrPathFileName 服务器录制文件路径
 */
- (void)uploadRecordFile:(NSString *)fileName svrPathFileName:(NSString *)svrPathFileName;

/**
 取消上传指定录制文件
 @param fileName 录制文件路径
 */
- (void)cancelUploadRecordFile:(NSString *)fileName;


#pragma mark ----------------------------------------------- 云端录制接口
// added by king 20180327

/**
 开始云端录制
 @param cfg 云端录制配置信息
 @param videoIDs 云端录制内容列表
 */
- (void)startSvrRecording:(RecCfg *)cfg contents:(NSArray <RecContentItem *> *)videoIDs;

/**
 设置云端录制内容
 @param videoIDs 云端录制内容列表
 */
- (void)updateSvrRecordContents:(NSArray <RecContentItem *> *)videoIDs;

/**
 设置云端录制内容
 @param videoIDs 云端录制内容列表 老接口
 */
- (void)setSvrRecVideos:(NSArray <RecContentItem *> *)videoIDs;


/**
 停止云端录制
 */
- (void)stopSvrRecording;

/**
 获取云端录制状态
 @return 云端录制状态
 */
- (MIXER_STATE)getSvrRecordState;


#pragma mark ----------------------------------------------- 影音接口

/**
 获取影音文件信息
 @return 影音文件信息
 */
- (MediaInfo *)getMediaInfo;


/**
 获取影音图像信息
 @param userId 用户ID
 @return 影音图像信息
 */
- (MediaDataFrame *)getMediaImg:(NSString *)userId;


// added by king 20170818

/**
 影音共享配置
 @param cfg 配置
 @return 配置是否成功
 */
- (BOOL)setMediaCfg:(VideoCfg *)cfg;
- (VideoCfg *)getMediaCfg;


/**
 开始播放影音(有的音乐文件没有图像,可显示配置的图像)
 @param filename 文件路径
 @param bLocPlay 是否本地播放
 @param bPauseWhenFinished 完成时是否暂停
 */
- (void)startPlayMedia:(NSString *)filename bLocPlay:(int)bLocPlay bPauseWhenFinished:(int)bPauseWhenFinished;


/**
 停止播放影音
 */
- (void)stopPlayMedia;


/**
 暂停播放影音
 @param bPause 是否暂停
 */
- (void)pausePlayMedia:(BOOL)bPause;


/**
 设置播放位置
 @param pts 位置
 */
- (void)setPlayPos:(int)pts;


/**
 获取应用的媒体路径下所有文件
 @return 媒体路径下所有文件
 */
- (NSArray <NSString *> *)getAllFilesInMediaPath;


/**
 配置影音共享的声音大小
 @param level 声音大小
 */
- (void)setMediaVolume:(int)level;
- (int)getMediaVolume;


#pragma mark ----------------------------------------------- UI主调同步
// added by king 20170803

/**
 设置视频墙分屏模式
 @param videoWallMode 分屏模式(0:互看 1:1分屏 2:2分屏 3:4分屏 4:5分屏 5:6分屏 6:9分屏 7:13分屏 8:16分屏)
 */
- (void)setVideoWallMode:(int)videoWallMode;


/**
 获取视频墙分屏模式
 @return 分屏模式(0:互看 1:1分屏 2:2分屏 3:4分屏 4:5分屏 5:6分屏 6:9分屏 7:13分屏 8:16分屏)
 */
- (int)getVideoWallMode;


// added by king 20170810

/**
 设置主视频
 @param userID 用户ID
 */
- (void)setMainVideo:(NSString *)userID;


/**
 获取主视频
 @return 用户ID
 */
- (NSString *)getMainVideo;

/**
 功能切换
 
 @param main 功能类型
 @param sub sub 子页面标识（如创建白板时返回的boardID）
 */
-(void)switchToPage:(MainPageType)main subPage:(SubPage*)sub;

/**
 获取当前主功能区
 
 @return 当前主功能区
 */

-(MainPageType)getCurrentMainPage;
/**
 获取当前子页面
 
 @return 当前子页面
 */
-(SubPage*)getCurrentSubPage;

#pragma mark ----------------------------------------------- 标注
/**
 屏幕共享是否允许其他人标注
 @return YES/NO
 */
- (BOOL)isEnableOtherMark;

/**
 允许他人标注屏幕
 */
-(void)enableOtherMark:(BOOL)enable;

/**
 屏幕共享是否开启标注
 @return YES/NO
 */
- (BOOL)isMarkedState;

/**
 发送屏幕共享标注
 @param markData 屏幕共享标注
 */
- (void)sendMarkData:(MarkData *)markData;

/**
 删除所有屏幕共享标注
 */
- (void)clearAllMarks;

//扩展接口（带V4是一套接口。跟不带V4不互通）
- (void)delMarkData:(NSArray<NSString *> *)data;

/**
 下载网盘文件
 */
-(void)downloadNetDiskFile:(NSString *)fileID localFilePath:(NSString *)localFilePath;

/* 白板 (king 20180716) */
/**
 创建白板
 @param title  标题
 @param width 宽度
 @param height 高度
 @param pageCount 页数
 @return 白板所在的功能子页
 */
- (SubPage *)createBoard:(NSString *)title width:(int)width height:(int)height pageCount:(int)pageCount;

/**
 关闭白板
 @param boardID 白板所在的功能子页
 */
- (void)closeBoard:(SubPage *)boardID;
/**
 初始化白板指定页数据
 @param boardID 白板所在的功能子页
 @param boardPageNo 页码（0:代表第一页）
 @param imgID 白板的背景图片标识（空代表无背影图）
 @param elements 白板的初始图元（空代表无图元，一般在导入历史文件才用到）
 */
- (void)initBoardPageDat:(SubPage *)boardID boardPageNo:(int)boardPageNo imgID:(NSString *)imgID elemets:(NSString *)elements;

/**
 创建图元ID
 @return 图元ID
 */
- (NSString *)createElementID;

/**
 添加白板图元
 @param boardID 白板所在的功能子页
 @param boardPageNo 页码
 @param element 图元信息
 */
- (void)addBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementData:(NSString *)element;

/**
 修改白板图元
 @param boardID 白板所在的功能子页
 @param boardPageNo 页码
 @param element 图元信息
 */
- (void)modifyBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementData:(NSString *)element;

/**
 删除白板图元
 @param boardID 白板所在的功能子页
 @param boardPageNo 页码
 @param elementIDs 需要删除的图元ID列表
 */
- (void)delBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementIDs:(NSArray<NSString *> *)elementIDs;

/**
 设置鼠标热点消息
 @param boardID 白板所在的功能子页
 @param boardPageNo 页码
 @param x x坐标
 @param y y坐标
 */
- (void)setMouseHotSpot:(SubPage *)boardID boardPageNo:(int)boardPageNo x:(int)x y:(int)y;

#pragma mark ----------------------------------------------- 网盘文档
//查询文档列表
-(void)listNetDiskDocFile:(NSString*)dir;
//上传文档并转换
-(void)uploadDocFileToNetDisk:(NSString*)svrPathFileName locPathFileName:(NSString*)locPathFileName;
//下载源始文档
-(void)downloadNetDiskDocFile:(NSString*)svrPathFileName locPathFileName:(NSString*)locPathFileName;
//取消文档传输
-(void)cancelTransforNetDiskDocFile:(NSString*)svrPathFileName;
//删除文档
-(void)deleteNetDiskDocFile:(NSString*)svrPathFileName;
//获取文档的转换信息
-(void)getNetDiskDocFilePageInfo:(NSString*)svrPathFileName;
//下载文档转换后的页文件
-(void)downloadNetDiskDocFilePage:(NSString*)pagePathFileName locPathFileName:(NSString*)locPathFileName;

#pragma mark ----------------------------------------------- 指定视频设备参数控制disabled属性
-(void)setLocVideoAttributes:(int)videoID attributes:(CamAttribute*)attributes;
-(CamAttribute*)getLocVideoAttributes:(int)videoID;


#pragma mark ----------------------------------------------- 会议属性 用户属性
//会议属性
-(void)getMeetingAllAttrs:(NSString *)cookie;

-(void) getMeetingAttrs:(NSArray<NSString*> *) keys cookie:(NSString *)cookie;
//全部)重置
-(void) setMeetingAttrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//添加)或更新
-(void) addOrUpdateMeetingAttrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//删除
-(void) delMeetingAttrs:(NSArray<NSString*> *)keys options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//清空)
-(void) clearMeetingAttrs:(NSString *)options cookie:(NSString *)cookie;

//获取)指定用户的所有属性（一次最大只能获取50人的属性）
-(void) getUserAttrs:(NSArray<NSString*>*)uids keys:(NSArray<NSString*> *)keys  cookie:(NSString *)cookie;
//重置)指定用户的属性(用户之前的属性将被清空)
-(void) setUserAttrs:(MeetingAttrs*)uid attrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//添加)或更新指定用户的属性
-(void) addOrUpdateUserAttrs:(NSString*)uid attrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//删除)指定用户的属性
-(void) delUserAttrs:(NSString*)uid keys:(NSArray<NSString*>*)keys options:(NSMutableDictionary*)options cookie:(NSString*)cookie;
//清空)指定用户的属性
-(void) clearAllUserAttrs:(NSMutableDictionary*)options cookie:(NSString*)cookie;
-(void) clearUserAttrs:(NSString*)uID options:(NSString*)options cookie:(NSString*)cookie;


-(void)setVideoBlur:(BOOL)blur;
-(BOOL)getVideoBlur;
-(void)setVideoDressFrame:(UIImage*)image;
-(BOOL)hasStartDress;

@end

#endif  // __CLOUDROOMVIDEO_MEETING_H__

