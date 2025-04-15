#ifndef __RTC_MEETING_H__
#define __RTC_MEETING_H__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import <RTCSDK_IOS/RTCQueue.h>
#import <RTCSDK_IOS/RTCSDK_Def.h>
#import <RTCSDK_IOS/RTCCommonType.h>

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

@property (nonatomic, copy) NSString *micDevID; // 麦克风设备(空代表默认设备)
@property (nonatomic, copy) NSString *spkDevID; // 喇叭设备(空代表默认设备)
@property (nonatomic, assign) int agc; // 是否开启声音增益，0：不开启；1：开启(默认值)
@property (nonatomic, assign) int ans; // 是否开启降噪，0：不开启；1：开启（默认值）
@property (nonatomic, assign) int aec; // 是否开启回声消除，0：不开启；1：开启（默认值）
@property (nonatomic, assign) BOOL echoSuppression;
@property (nonatomic, assign) BOOL echoCancelDelay; 

@end

/*
音频订阅模式
*/
typedef enum {
    ASM_MIXED,            //整个会议的混音流
    ASM_SEPARATE,        //每个人的独立流
} ASUBSCRIB_MODE;

/*
音频订阅名单类型
*/
typedef enum {
    ASLT_INCLUDE,        //白名单
    ASLT_EXCLUDE,        //黑名单
} ASUBSCRIB_LISTTYPE;

/*
音频格式
*/
typedef enum {
    AFMT_INVALID = -1,    //无效格式
    AFMT_PCM16BIT = 0,    //pcm 16bit
    AFMT_PCM8BIT          //pcm 8bit
} AUDIO_FORMAT;

/*
声道布局
*/
typedef enum {
    ACHL_MONO = 1,        //单声道
    ACHL_STEREO = 3       //左右双声道
} AUDIO_CHLAYOUT;

/* 音频数据信息 */
CRVSDK_EXPORT
@interface AudioFrame : NSObject
{
    @public uint8_t* data; //音频数据
}
@property (nonatomic, assign) AUDIO_FORMAT format; //音频格式
@property (nonatomic, assign) int sampleRate;  //采样率
@property (nonatomic, assign) AUDIO_CHLAYOUT chLayout; //声道布局
@property (nonatomic, assign) NSTimeInterval timestamp; //时间戳（ms)
@property (nonatomic, assign) int datLen; //音频数据长度
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

@property (nonatomic, copy) NSString *devID; // 设备id
@property (nonatomic, copy) NSString *videoName; // 设备名称
@property (nonatomic, assign) BOOL isDisabled;        //是否被禁用
@property (nonatomic, assign) BOOL isIPCamera;        //是否为网络摄像头
@property (nonatomic, assign) BOOL isCustomCamera;    //是否为自定义摄像头
@property (nonatomic, assign) BOOL isScreenCamera;    //是否为桌面摄像头
@property (nonatomic, assign) BOOL isFrontCam;        //是否为前置摄像头
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
    VFMT_UNKNOW  = -1,   // 未知格式
    VFMT_YUV420P = 0,    // yuv420p, 3个平面数据(ColorSapce:BT601, ColorRang:limited range)
    VFMT_ARGB32,         // rgb32, 1个平面数据，0xAARRGGBB
    VFMT_RGBA32,         // rgb32, 1个平面数据，0xRRGGBBAA
    VFMT_H264,           // h264裸数据，1个平面数据
    VFMT_OESTEXTURE,     // oes纹理
    VFMT_NV21    = 5,    // nv21, 2个平面数据(ColorSapce:BT601, ColorRang:limited range)
    VFMT_NV12    = 6,    // nv12, 2个平面数据(ColorSapce:BT601, ColorRang:limited range)
    VFMT_0RGB    = 7,    // rgb32, 1个平面数据，0xXXRRGGBB(忽略alpha通道)
    VFMT_RGB0,           // rgb32, 1个平面数据，0xRRGGBBXX(忽略alpha通道)
    VFMT_BGR0,           // rgb32, 1个平面数据，0xBBGGRRXX(忽略alpha通道)
    VFMT_0BGR    = 10,   // rgb32, 1个平面数据，0xxxBBGGRR(忽略alpha通道)
    VFMT_BGRA,           // rgb32, 1个平面数据，0xBBGGRRAA
    VFMT_ABGR,           // rgb32, 1个平面数据，0xAABBGGRR
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

@property (nonatomic, copy) NSString* userid; // ID
@property (nonatomic, copy) NSString* markid; // SN
@property (nonatomic, assign) int type; // 画笔颜色
@property (nonatomic, copy) NSArray<NSNumber *> *mousePosSeq;

@end

//WhiteBoardV2Interface.h
typedef enum
{
    WBV2_WHITE,
    WBV2_DOC
} WBTYPE_V2;

typedef enum
{
    WBIT_IMG,
    WBIT_PPTANIM,
    WBIT_PPT
} WBIMGTYPE_V2;

typedef  enum {
    CLPageModeFullPage, // 单页模式，存在多页时翻页时整页翻
    CLPageModeMutilPage,  // 连页模式，存在多页时翻页时滑动翻
}CLPageMode;

CRVSDK_EXPORT
@interface BoardInfo : NSObject
@property (nonatomic, copy) NSString *              boardID;         // 唯一序号
@property (nonatomic, copy) NSString *              owner;           // 白板创建者
@property (nonatomic, assign) WBTYPE_V2             wType;           // 白板类型（WBTYPE_V2）
@property (nonatomic, assign) WBIMGTYPE_V2          imgType;         // 文档背景类型（WBIMGTYPE_V2）
@property (nonatomic, assign) int                   width;           // 白板宽度
@property (nonatomic, assign) int                   height;          // 白板高度
@property (nonatomic, assign) int                   pageCount;       // 总页数
@property (nonatomic, assign) float                 xPos;            // 视图左上角x位置（0~1.0）
@property (nonatomic, assign) float                 yPos;            // 视图左上角y位置（0~1.0）
@property (nonatomic, assign) int                   scale;           // 白板缩放,取值1-200
@property (nonatomic, copy) NSString *              extInfo;         // 白板自定义扩展信息
@property (nonatomic, strong) NSMutableDictionary * extProperty;     // 白板结构体扩展预留
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
    RECVTP_VIDEO = 0, // 摄像头,_itemDat中应有:camid=MeetingCore::CamID
    RECVTP_PIC, // 图片,_itemDat中应有:resourceid=xxx
    RECVTP_SCREEN, // 整个屏幕,_itemDat中可以有:screenid=-1;pid=x;area=QRect
    RECVTP_MEDIA, // 影音共享
    RECVTP_TIMESTAMP, // 时间戳水印,_itemDat中应有:resourceid=xxx
    RECVTP_REMOTE_SCREEN,    //远端屏幕
    RECVTP_AUDIO = 9, //纯声音录制，_itemDat中应有: termId=123;
    
    //文字水印，该类型不会应用width、height参数，_itemDat中应有:
    //资源id：resourceid:"xxx"，如果存在该参数，则需要按照图片方式处理
    //文本内容：text:"xxx"，支持%timestamp%特殊参数，代表时间戳
    //文本颜色：color:，#FFFFFF，格式：#RRGGBB[AA]
    //背景色：background:#0000007D，格式：#RRGGBB[AA]
    //字体大小：font-size:18
    //边距：text-margin:5
    RECVTP_TEXT = 10,
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

//编码类型
typedef NS_ENUM(NSUInteger, CRCODEC_ID) {
    CRVSDK_CODECID_NONE = 0,
    CRVSDK_CODECID_H264 = 27,
    CRVSDK_CODECID_VP8 = 139,
    CRVSDK_CODECID_H265 = 173,
};

CRVSDK_EXPORT
@interface StreamInfo : NSObject

@property (nonatomic, assign) short w;
@property (nonatomic, assign) short h;
@property (nonatomic, assign) float fps;
@property (nonatomic, assign) int bps; //单位：bit/秒
@property (nonatomic, assign) CRCODEC_ID codecID;

@end

/* 媒体数据信息 */
CRVSDK_EXPORT
@interface MediaDataFrame : NSObject
{
@public void *buf; // 图像数据
}

@property (nonatomic, assign) int datLength; // 图像大小
@property (nonatomic, assign) VIDEO_FORMAT fmt; // 格式
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

/* 纯声音 */
CRVSDK_EXPORT
@interface RecAudioContentItem : RecContentItem
- (instancetype)initWithTermId:(int)termId;
@end

/* 文字水印 */
CRVSDK_EXPORT
@interface RecTextContentItem : RecContentItem

/// 录制文字水印
/// @param itemRt 位置，宽高将忽略
/// @param text 必须包含的文本内容
- (instancetype)initWithRect:(CGRect)itemRt text:(NSString *)text;

/// 录制文字水印
/// @param itemRt 位置，宽高将忽略
/// @param resID 具有唯一属性的字符串id，通过setPicResource将图片存储到sdk内供混图模块使用（可选）
/// @param text 必须包含的文本内容
/// @param textColor 文本颜色，格式：#RRGGBB[AA]， 默认#FFFFFF
/// @param backgroundColor 背景色，格式：#RRGGBB[AA]， 默认#0000007D
/// @param fontSize 字体大小，默认18
/// @param margin 边距，默认5
- (instancetype)initWithRect:(CGRect)itemRt resID:(NSString *)resID text:(NSString *)text textColor:(NSString *)textColor backgroundColor:(NSString *)backgroundColor fontSize:(int)fontSize margin:(int)margin;

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

typedef NS_ENUM(NSInteger, CLScaleType) {
    CLScaleTypeAspectFit = 0,  // 等比缩放留空居中显示
    CLScaleTypeAspectFill = 1,       // 等比缩放裁剪铺满显示
    CLScaleTypeScaleToFill = 2       // 不等比缩放铺满显示（可能导致图像拉伸）
};

typedef NS_ENUM(NSUInteger, MirrorType) {
    MIRROR_AUTO, // 本地前置摄像头自动镜像
    MIRROR_OFF,  // 不镜像
    MIRROR_ON,   // 镜像
};

/* added by king 20180312 */
CRVSDK_EXPORT
@interface CLBaseView : UIView

@property (nonatomic, assign) CLScaleType scaleType; // 显示模式
@property (nonatomic, assign) MirrorType mirrorType; // 镜像模式


- (UIImage *)getShowPic;
- (int)getPicWidth;
- (int)getPicHeight;

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

- (UIImage*)getVideoImage;
- (void)setUsrVideoId:(UsrVideoId *)usrVideoId;
- (void)setUsrVideoId:(UsrVideoId *)usrVideoId qualityLv:(int)qualityLv;

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
- (void)clearFrame;
- (void)setShareSrcSize:(CGSize)shareSrcSize;
- (void)updateScreenView;
- (void)setDelTime:(double)time;
- (void)setMarkColor:(UIColor*)color;
- (void)setMarkLineW:(int)lineW;
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
typedef NS_ENUM(NSInteger, CLShapeType)
{
    CLSHAPE_NULL,
    CLSHAPE_PEN,            //画笔
    CLSHAPE_LINE,           //直线
    CLSHAPE_RECT,           //矩形
    CLSHAPE_ELLIPSE,        //圆
    CLSHAPE_ARROW,          //箭头
    CLSHAPE_TEXT,           //文本
    CLSHAPE_IMAGE,          //图片
    CLSHAPE_CHOOSE = 1000,  //选择
    CLSHAPE_ERASER,         //橡皮擦
    CLSHAPE_SCROLL,         //翻页或移动画布
};
typedef NS_ENUM(NSInteger, CLBoardViewMarkExceptionType)
{
    CLMarkExceptionTypeUnknown,
    CLMarkExceptionTypeSinglePageLimit,   // 单页标注已达最大无法再标注通知
    CLMarkExceptionTypeSingleLineLimt,    // 单笔标注超长截断通知
};
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
@property (nonatomic, strong) NSMutableArray <CRFileInfo *>* files;
@property (nonatomic, strong) NSMutableArray <NetDiskDocDir *>* dirs;
@end

/*获取文档页信息结果 */
CRVSDK_EXPORT
@interface GetDocPageInfoRslt : NSObject
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) NSMutableArray <NSString *>* files;
@end
CRVSDK_EXPORT
@interface BoardViewToolProperty : NSObject
@property (nonatomic, assign) CGFloat lineWidth;  // 线宽
@property (nonatomic, copy) UIColor *strokeStyle;  // 画笔及文本颜色
@property (nonatomic, copy) UIFont *font;  // 文本属性
@property (nonatomic, assign) NSTextAlignment textAlign;  // 文本对齐
@end
@class CLBoardView;
#pragma mark - ----------------------------------------------- 白板View
@protocol CLBoardViewCallBack <NSObject>
@optional
#pragma mark - ----------------------------------------------- 白板View回调
- (void)notifyBoardCurPageChanged:(CLBoardView *)boardView curPage:(NSInteger)curPage operatorID:(NSString *)operatorID;
- (void)notifyRedoEnableChanged:(CLBoardView *)boardView bEnable:(BOOL)bEnable;
- (void)notifyUndoEnableChanged:(CLBoardView *)boardView bEnable:(BOOL)bEnable;
- (void)notifyViewScaleChanged:(NSString *)boardID boardView:(CLBoardView *)boardView scale:(int)scale;
- (void)notifyMarkException:(CLBoardView *)boardView exType:(CLBoardViewMarkExceptionType)exType;
@end

CRVSDK_EXPORT
@interface CLBoardViewAttr : NSObject
@property (nonatomic, assign) BOOL readOnly; // 不可标注
@property (nonatomic, assign) BOOL asyncPage; // 是否同步页面
@property (nonatomic, assign) BOOL followPage; // 是否跟随页面(滑动翻页)
@property (nonatomic, assign) BOOL asyncScale; // 是否同步缩放
@property (nonatomic, assign) BOOL followScale; // 是否跟随缩放
@end

CRVSDK_EXPORT
@interface CLBoardViewToolAttr : NSObject
@property (nonatomic, assign) int lineWidth; // 画笔粗细
@property (nonatomic, assign) int color; // 画笔颜色
@end

NS_ASSUME_NONNULL_BEGIN
CRVSDK_EXPORT
@interface CLBoardView : UIView
@property (nonatomic, readonly, strong) UITableView *tableView;

// 设置内容页背景色，默认白色
- (void)setPageBackgroundColor:(UIColor *)pageBackgroundColor;

// 注册内部事件的监听者
- (void)registerWhiteBoardCallback;
// 清理内部事件监听者
- (void)removeWhiteBoardCallBack;

- (void)setBoardViewCallback:(id<CLBoardViewCallBack>)callback;

// 配置白板View
- (void)setBoardID:(NSString *__nullable)boardID boardViewAttr:(CLBoardViewAttr *__nullable)boardViewAttr;

// 配置白板文本图元输入控件的父视图，建议使用当前控制器的View方便内部控制textView效果
- (void)configBoardTextViewContainer:(UIView *)textViewContainer;

// 取消内部输入控件的第一响应
- (void)resignTextViewFirstResponder;

/// 获取白板View属性
- (CLBoardViewAttr *)getBoardViewAttr;
/// 更新白板View属性
/// @param boardViewAttr 白板View属性
- (void)setBoardViewAttr:(CLBoardViewAttr *)boardViewAttr;
/// 设置View的当前页
/// @param pageNum 页数
- (void)setBoardViewCurPage:(NSInteger)pageNum;

/// 获取View的当前页
- (NSInteger)getBoardViewCurPage;

/// 设置View的工具类型
/// @param type 工具类型
- (void)setBoardViewToolType:(CLShapeType)type;

/// 获取View的工具类型
- (CLShapeType)getBoardViewToolType;

/// 设置View的工具属性
/// @param property 工具属性
- (void)setBoardViewToolAttr:(CLBoardViewToolAttr *)property;

/// 获取View的工具属性
- (CLBoardViewToolAttr *)getBoardViewToolAttr;

/// 清空当页标注
- (void)clearCurPage;

/// 清空整个View的标注
- (void)clearAllPage;

/// 获取是否可以redo
- (BOOL)getRedoEnableState;

/// 获取是否可以undo
- (BOOL)getUndoEnableState;

/// 撤销上一步操作
- (void)undo;

/// 恢复上一步操作
- (void)redo;

/// 设置View的缩放区间（0.2～5）
/// - Parameters:
///   - min: 最小缩放系数
///   - max: 最大缩放系数
- (void)setViewScaleRange:(CGFloat)min max:(CGFloat)max;

/// 获取View的最小缩放系数
- (CGFloat)getViewMinScale;

/// 获取View的最大缩放系数
- (CGFloat)getViewMaxScale;

/// 获取View的缩放系数
- (CGFloat)getViewScale;

@end
NS_ASSUME_NONNULL_END
#pragma mark ----------------------------------------------- 视频会议回调接口

NS_ASSUME_NONNULL_BEGIN

@protocol RTCMeetingCallBack <NSObject>

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

/**
 会议掉线（被踢出等非网络因素）
*/
- (void)meetingDropped:(CRVIDEOSDK_MEETING_DROPPED_REASON)reason;

- (void)kickoutRslt:(CRVIDEOSDK_ERR_DEF)sdkErr userID:(NSString*)userID;

/**
 会议状态改变
 */
- (void)notifyRoomStateChanged:(bool)lock;

/**
 会议锁门失败
 */
- (void)notifyLockRoomFail:(bool)lock;

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
 
 @param aSide 声道类型
 @param audioDat  PCM数据
 */
- (void)audioPCMData:(int)aSide audioDat:(NSData*)audioDat;

//通知被设置变声(type=0即不变声)
- (void)notifySetVoiceChange:(NSString *)userID type:(int)type oprUserID:(NSString *)oprUserID;

//通知环回测试状态变化
- (void)notifyEchoTestState:(bool)bTesting;

/**
 全体静音通知
 */
- (void)notifyAllAudioClose:(NSString *)userID;
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
- (void)startScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 主动停止了屏幕共享
 
 @param sdkErr sdkErr
 */
- (void)stopScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;
/**
 通知他人屏幕共享开始回调
 */
- (void)notifyScreenShareStarted:(NSString *)shareId;

/**
 请求屏幕共享通知
 */
- (void)notifyRequestShare:(NSString*)shareId requestId:(NSString*)requestId param:(NSString*)param;

/**
 取消屏幕共享通知
 */
- (void)notifyCancelShareRequestion:(NSString*)shareId requestId:(NSString*)requestId;

/**
 拒绝屏幕共享请求通知
 */
- (void)notifyRejectShareRequestion:(NSString*)shareId requestId:(NSString*)requestId param:(NSString*)param;


/**
 通知他人屏幕共享停止回调
 */
- (void)notifyScreenShareStopped:(NSString *)oprUserID;


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
- (void)notifyCatchScreen;

/**
 赋予控制权限通知
 */
- (void)notifyGiveCtrlRight:(NSString*)operId targetId:(NSString*)targetId;


/**
 收回控制权限通知
 */
- (void)notifyReleaseCtrlRight:(NSString*)operId targetId:(NSString*)targetId;


/**
 屏幕共享尺寸变化
 */
- (void)notifyShareRectChanged:(CGRect)rect;

- (void)notifyScreenShareCtrlMouseMsg:(int)eventType xPos:(int)xPos yPos:(int)yPos mouseData:(int)mouseData;

- (void)notifyScreenShareCtrlKeyMsg:(int)keyCode bExtendedKey:(BOOL)bExtendedKey bKeyDonw:(BOOL)bKeyDonw;
/**********IM**********/
// IM消息发送结果
- (void)sendIMmsgRlst:(NSString *)taskID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 通知收到文本消息
- (void)notifyIMmsg:(NSString *)romUserID text:(NSString *)text sendTime:(int)sendTime;

- (void)sendCustomMeetingMsgRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)notifyCustomMeetingMsg:(NSString *)fromUserID jsonDat:(NSString *)jsonDat;

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
- (void)locMixerOutputInfo:(NSString*)mixerID nameUrl:(NSString*)nameUrl outputInfo:(OutputInfo*)outputInfo;

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
- (void)svrMixerCfgChanged;

/**
 云端录制文件、云端直播信息变化通知
 @param outputInfo 录制文件、直播信息通知
 */
- (void)svrMixerOutPutInfo:(OutputInfo*)outputInfo;

- (void)svrMixerOutPutJsonInfo:(NSString*)outputInfo;

// 新云端录制/直播
- (void)createCloudMixerFailed:(NSString *)mixerID err:(CRVIDEOSDK_ERR_DEF)err;
- (void)cloudMixerStateChanged:(NSString *)operatorID mixerID:(NSString *)mixerID state:(MIXER_STATE)state exParam:(NSString *)exParam;
- (void)cloudMixerInfoChanged:(NSString *)mixerID;
- (void)cloudMixerOutputInfoChanged:(NSString *)mixerID jsonStr:(NSString *)jsonStr;


/**********影音**********/

/**
 影音开始播放回调
 @param userid 用户ID
 */
- (void)notifyMediaStart:(NSString *)userid;

/**
 开启影音共享功能失败
 @param err 错误码
 */
- (void)startPlayMediaFail:(CRVIDEOSDK_ERR_DEF)err;

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

// added by king 20170810

/**
 开始屏幕共享时, 标注操作结果
 @param sdkErr sdkErr
 */
- (void)startScreenMarkRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**
 结束屏幕共享时, 标注操作结果
 @param sdkErr sdkErr
 */
- (void)stopScreenMarkRslt:(CRVIDEOSDK_ERR_DEF)sdkErr;

/**********标注回调**********/
- (void)notifyScreenMarkStarted;
- (void)notifyScreenMarkStopped;
- (void)enableOtherMark:(BOOL)enable;
- (void)sendMarkData:(MarkData *)markData;
- (void)sendAllMarkData:(NSArray<MarkData *> *)markDatas;
- (void)clearAllMarks;
//v4接口
- (void)delMarkData:(NSArray<NSString *> *)data operatorID:(NSString*)operatorID;


- (void)getSharerSrcPicRsp:(NSData*)picDat picSZ:(CGSize)picSZ;

/* 网盘 */
- (void)getNetDiskFileListRslt:(NetDiskDocDir*)dirNode;

//通知会议网盘上传下载进度
- (void)notifyNetDiskTransforProgress:(NSString*)fileID percent:(int)percent isUpload:(bool)isUpload;


// V2白板通知

/**
 通知创建子功能页白板
 @param board 子功能页信息
 @param operatorID 操作者
 */
- (void)notifyCreateBoard:(BoardInfo *)board operatorID:(NSString *)operatorID;

/**
 通知关闭白板
 @param boardID 白板子功能页ID
 @param operatorID 操作者
 */
- (void)notifyCloseBoard:(BoardInfo *)board operatorID:(NSString *)operatorID;

/// 通知白板的扩展信息改变
/// @param boardID 白板ID
/// @param exInfo 扩展信息
/// @param operatorID 操作者
- (void)notifyBoardExInfoUpdated:(NSString *)boardID exInfo:(NSString *)exInfo operatorID:(NSString *)operatorID;

/// 通知当前白板改变
/// @param boardID 白板ID
/// @param operatorID 操作者
- (void)notifyCurrentBoard:(NSString *)boardID operatorID:(NSString *)operatorID;

/// 通知白板列表
/// @param boardIDList 白板ID列表
- (void)notifyInitBoardList:(NSArray<NSString *> *)boardIDList;

- (void)setNickNameRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userid:(NSString*)userid newName:(NSString*)newName;

- (void)notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName;

//会议属性  用户属性
- (void)getMeetingAllAttrsSuccess:(MeetingAttrs*)attrSeq cookie:(NSString *)cookie;

- (void)getMeetingAllAttrsFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)getMeetingAttrsSuccess:(MeetingAttrs *)attrSeq cookie:(NSString *)cookie;

- (void)getMeetingAttrsFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)resetMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)addOrUpdateMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)delMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)clearMeetingAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)getUserAttrsSuccess:(UsrMeetingAttrs*)attrMap cookie:(NSString *)cookie;

- (void)getUserAttrsFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)setUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)addOrUpdateUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)delUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)clearAllUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)clearUserAttrsRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

- (void)notifyMeetingAttrsChanged:(MeetingAttrs*)add updates:(MeetingAttrs*)updates delKeys:(NSMutableArray<NSString*>*)delKeys;

- (void)notifyUserAttrsChanged:(NSString*)uid adds:(MeetingAttrs*)adds updates:(MeetingAttrs*)updates delKeys:(NSMutableArray<NSString*>*)delKeys;

@end

NS_ASSUME_NONNULL_END

#pragma mark ----------------------------------------------- 音频数据回调
NS_ASSUME_NONNULL_BEGIN
@protocol CRAudioFrameCallBack <NSObject>
@optional
//采集的原始音频数据
- (void)onRecordAudioFrame:(AudioFrame *)frm;
//播放的原始音频数据
- (void)onPlaybackAudioFrame:(AudioFrame *)frm;
//用户的混音前原始音频数据
- (void)onPlaybackAudioFrameBeforeMixing:(NSString *)userId frm:(AudioFrame *)frm;
//采集+播放混音后数据
- (void)onMixedAudioFrame:(AudioFrame *)frm;
@end
NS_ASSUME_NONNULL_END

#pragma mark ----------------------------------------------- 视频会议类
NS_ASSUME_NONNULL_BEGIN

CRVSDK_EXPORT
@interface RTCMeeting : NSObject

/**
 单例方法
 @return 单例对象
 */
+ (RTCMeeting *)shareInstance;


/**
 设置回调
 @param callBack 代理对象
 */
- (void)setMeetingCallBack:(id <RTCMeetingCallBack>)callBack;

/**
 注册回调
 @param callBack 代理对象
 */
- (void)registerMeetingCallback:(id <RTCMeetingCallBack>)callBack;

/**
 移除回调
 @param callBack 多代理模式移除代理对象
 */
-(void) removeMeetingCallBack:(id<RTCMeetingCallBack>)callBack;
/**
 设置音频数据回调
 @param callBack 代理对象，传入nil移除回调
*/
- (void)setAudioFrameObserver:(id<CRAudioFrameCallBack>)callback;

#pragma mark ----------------------------------------------- 会议接口

/**
 进入会议
 (只有入会成功,才能进行后续操作)
 @param meetID 会议ID
 @param nickname 昵称
 */
- (void)enterMeeting:(int)meetID nickname:(NSString *)nickname;

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


- (short)getMyTermID;

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
- (MemberInfo *)getMemberInfo:(NSString *)userId;

/*
 请出会议
 @param userid 用户ID
*/
- (void)kickout:(NSString *)userid;

#pragma mark ----------------------------------------------- 音频接口
/**
 麦克风设置
 */
- (void)setAudioCfg:(AudioCfg*)cfg;

/**
 获取麦克风设置
 
 @return 麦克风设置
 */
- (AudioCfg*) getAudioCfg;

/**
 麦克风音量增益
 
 @param scale  麦克风音量增益（范围：1-20）
 @return 是否成功
 */
- (bool)setMicVolumeScaling:(int)scale;

/**
 获取本地麦音量(level:0~255)
 @return 本地麦音量
 */
- (int)getMicVolume;

/**
 设置本地麦音量(level:0~255)
 @param level 本地麦音量
 @return 设置是否成功
 */
- (bool)setMicVolume:(int)level;

/**
 获取本地喇叭音量(level:0~255)
 @return 本地喇叭音量
 */
- (int)getSpeakerVolume;

/**
 设置本地喇叭音量(level:0~255)
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
- (void)setAllAudioClose;

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

/**
 获取本地麦克风设备能量等级
 @return 能量等级0~9, (9为最大能量等级）
*/
- (int)getLocMicDevEnergy;

/**
 设置指定人变声
 @param userID 用户ID
 @param type 预定义变声类型
*/
- (void)setVoiceChange:(NSString *)userID type:(int)type;

/**
 获取目标用户变声类型
 @return 预定义变声类型
*/
- (int)getVoiceChangeType:(NSString *)userID;

/**
 自定义音频采集
 @param enable 是否启用自定义音频采集
 @param param 可选扩展参数，json格式，当前支持参数：
 "fromIPCam"：摄像头ID，配置后将不再需要pushCustomAudioDat，sdk自动从IPCam中获取音频数据
 @return 错误码，CRVIDEOSDK_NOERR 代表调用成功
*/
- (CRVIDEOSDK_ERR_DEF)setCustomAudioCapture:(bool)enable param:(NSString *)param;

/**
 向sdk送入自定义音频采集数据
 @param pcmDat 音频帧数据
 @return 错误码，CRVIDEOSDK_NOERR 代表调用成功
*/
- (CRVIDEOSDK_ERR_DEF)pushCustomAudioDat:(NSData *)pcmDat;

/**
 自定义音频渲染
 @param enable 是否开启自定义音频播放
 @param param 保留参数
 @return 错误码，CRVIDEOSDK_NOERR 代表调用成功
*/
- (CRVIDEOSDK_ERR_DEF)setCustomAudioPlayback:(bool)enable param:(NSString *)param;

/**
 从sdk获取音频数据用于自渲染
 @return pcmDat 音频帧数据
*/
- (NSData *)pullCustomAudioDat;


// added by king 201710131139

/**
 设置图片资源
 @param resID 资源ID
 @param frame 媒体数据
 */
- (void)setPicResource:(NSString *)resID mediaDataFrame:(MediaDataFrame *)frame;

- (void)rmPicResource:(NSString *)resID;

/**
 开始获取语音pcm数据
 @param aSide 声道类型 0:麦克风，1:扬声器
 @param getType 获取方式 0:回调方式，1:保存为文件
 @param param 当getType=0 表示回调方式，jsonParam可配置回调的数据大小(320-32000)，如: {"EachSize":320};当getType=1 表示保存为文件，jsonParam可配置文件名，如: { "FileName" ： "e:\test.pcm" }
 @return 是否开启成功
 */
- (BOOL)startGetAudioPCM:(int)aSide getType:(int)getType param:(NSString *)param;

/**
 停止获取语音pcm数据
 @param aSide 声道类型 0:麦克风，1:扬声器
 */
- (void)stopGetAudioPCM:(int)aSide;

//设置音频订阅模式（可以在入会之前调用）
- (void)setAudioSubscribeMode:(ASUBSCRIB_MODE)mode;

//设置独立音频订阅列表，只对ASM_SEPARATE模式生效（可以在入会之前调用）
- (void)setAudioSubscribeListForSeparateMode:(ASUBSCRIB_LISTTYPE)type userIds:(NSArray<NSString *> *)userIds;

/**
 开始本地语音环回测试
*/
- (void)startEchoTest;

/**
 停止本地语音环回测试
*/
- (void)stopEchoTest;

/**
 检测是否在本地语音环回测试
 @return 是否测试中
*/
- (bool)isEchoTesting;

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

- (BOOL)setVideoEffects:(VideoEffects*)effects;

- (VideoEffects*)getVideoEffects;

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
 获取自己或他人的图像数据
 @param userID 用户ID
 @param fmt 图像格式 -1时原用帧原始值
 @param width 图像宽度 -1时原用帧原始值
 @param height 图像高度 -1时原用帧原始值
 @return 图像数据
 */
- (VideoFrame*)getVideoImg2:(UsrVideoId*)userID fmt:(VIDEO_FORMAT)fmt width:(int)width height:(int)height;

/**
 设置/获取默认摄像头、多摄像头信息(自己videoIdList可以多个,远端只能一个)
 @param userId 用户ID
 @return 摄像头信息列表
 */
- (NSMutableArray <UsrVideoInfo *> *)getAllVideoInfo:(NSString *)userId;


/**
 设置默认摄像头
 @param userID 用户ID
 @param videoID 摄像头ID
 */
- (void)setDefaultVideo:(NSString *)userID videoID:(short)videoID;


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
- (int)createCustomVideoDev:(NSString*)camName pixFmt:(VIDEO_FORMAT)pixFmt width:(int)width height:(int)height extParams:(NSString*)extParams;

- (void)destroyCustomVideoDev:(int)devID;

- (void)inputCustomVideoDat:(int)devID data:(NSData*)data timeStamp:(int)timeStamp;

- (int)createScreenCamDev:(NSString*)camName  monitor:(NSString *)monitor;

- (bool)updateScreenCamDev:(int)devID tmonitor:(NSString *)monitor;

- (void)destroyScreenCamDev:(int)devID;

// 获取摄像头流信息
- (StreamInfo *)getVideoStreamInfo:(UsrVideoId *)cam;

#pragma mark - 美颜

//美颜(初始化插件及资源）
- (CRVIDEOSDK_ERR_DEF)startBeauty:(NSString *)initParams;
- (BOOL)isBeautyStarted;
//配置美颜效果
- (CRVIDEOSDK_ERR_DEF)updateBeautyParams:(NSString *)params;
- (NSString *)getBeautyParams;
//停止美颜功能、释放美颜插件及资源
- (void)stopBeauty;


#pragma mark - 虚拟背景

/**
 虚拟背景是否已开启
 @return 是否已开启
 */
- (BOOL)isVirtualBackgroundStarted;

/**
 开启虚拟背景
 @param params 虚拟背景配置，json，详情见文档CRVirtualBkCfg
 @return 错误码
*/
- (CRVIDEOSDK_ERR_DEF)startVirtualBackground:(NSString *)params;

/**
 更新虚拟背景参数
 @param params 虚拟背景配置，json，详情见文档CRVirtualBkCfg
 @return 错误码
*/
- (CRVIDEOSDK_ERR_DEF)updateVirtualBackgroundParams:(NSString *)params;

/**
 获取当前虚拟背景参数
 @return 虚拟背景配置，json，详情见文档CRVirtualBkCfg
*/
- (NSString *)getVirtualBackgroundParams;

/**
 停止虚拟背景
*/
- (void)stopVirtualBackground;

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

- (UIImage*)getSharerSrcPic;

//设置屏幕共享参数
- (void)setScreenShareCfg:(ScreenShareCfg *)cfg;

//获取屏幕共享的参数
- (ScreenShareCfg*)getScreenShareCfg;

- (CGRect)getShareRect;

//发起屏幕共享
- (void)startScreenShare;

//停止取消屏幕共享
- (void)stopScreenShare;

- (void)startScreenMark;

- (void)stopScreenMark;

//赋予控制权限
- (void)giveCtrlRight:(NSString*)userId;
//收回控制权限
- (void)releaseCtrlRight:(NSString*)userId;

- (CGPoint)parseToScreenPoint:(CGPoint)point;

- (void)setCustomizeCatchScreen:(BOOL)bCustomize;//设置是否自定义抓屏

- (BOOL)isCustomizeCatchScreen;

- (void)setCustomizeScreenImg:(NSData*)yuvDat datLenght:(int)datLenght width:(int)width height:(int)height orientation:(YWOrientation)orientation;

#pragma mark ----------------------------------------------- IM接口

- (void)sendMeetingCustomMsg:(NSString *)text cookie:(NSString *)cookie;

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


/**********录制新接口**********/
- (CRVIDEOSDK_ERR_DEF)createLocMixer:(NSString*)mixerID  cfg:(MixerCfg*)cfg content:(MixerContent*)content;
- (CRVIDEOSDK_ERR_DEF)updateLocMixerContent:(NSString*)mixerID content:(MixerContent*)content;
- (void)destroyLocMixer:(NSString*)mixerID;
- (MIXER_STATE)getLocMixerState:(NSString*)mixerID;
- (CRVIDEOSDK_ERR_DEF)addLocMixer:(NSString*)mixerID outputs:(MixerOutput*)outputs;
- (void)rmLocMixerOutput:(NSString*)mixerID  nameOrUrls:(NSArray<NSString*>*)nameOrUrls;

//云端录制
- (CRVIDEOSDK_ERR_DEF)startSvrMixer:(NSMutableDictionary<NSString*,MixerCfg*>*)cfgs contents:(NSMutableDictionary<NSString*,MixerContent*>*)contents outputs:(NSMutableDictionary<NSString*,MixerOutput*>*)outputs DEPRECATED_MSG_ATTRIBUTE("use createCloudMixer: instead");
- (CRVIDEOSDK_ERR_DEF)updateSvrMixerContent:(NSMutableDictionary<NSString*,MixerContent*>*)contents DEPRECATED_MSG_ATTRIBUTE("use updateCloudMixerContent:cfg instead");
- (void)stopSvrMixer DEPRECATED_MSG_ATTRIBUTE("use destroyCloudMixer: instead");
- (MIXER_STATE)getSvrMixerState DEPRECATED_MSG_ATTRIBUTE("use getCloudMixerInfo: instead");

- (CRVIDEOSDK_ERR_DEF)startSvrMixerJson:(NSString*)cfgs contents:(NSString*)contents outputs:(NSString*)outputs DEPRECATED_MSG_ATTRIBUTE("use createCloudMixer: instead");
- (CRVIDEOSDK_ERR_DEF)updateSvrMixerContentJson:(NSString*)contents DEPRECATED_MSG_ATTRIBUTE("use updateCloudMixerContent:cfg instead");

/************ 新云端录制接口 ************/

/// 创建云端录制
/// - Parameter cfg: 服务器混图内容配置
- (NSString *)createCloudMixer:(NSString *)cfg;

/// 更新云端录制内容
/// - Parameters:
///   - mixerID: 创建云端录制所得的ID
///   - cfg: 服务器混图内容配置
- (CRVIDEOSDK_ERR_DEF)updateCloudMixerContent:(NSString *)mixerID cfg:(NSString *)cfg;

/// 销毁指定云端录制
/// - Parameter mixerID: 创建云端录制所得的ID
- (void)destroyCloudMixer:(NSString *)mixerID;

/// 查询指定云端录制的信息
/// - Parameter mixerID: 创建云端录制所得的ID
- (NSString *)getCloudMixerInfo:(NSString *)mixerID;

/// 查询当前所有的云端录制信息
- (NSString *)getAllCloudMixerInfo;


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

#pragma mark ----------------------------------------------- 标注
/**
 屏幕共享是否允许其他人标注
 @return YES/NO
 */
- (BOOL)isEnableOtherMark;

/**
 允许他人标注屏幕
 */
- (void)enableOtherMark:(BOOL)enable;

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

#pragma mark - ----------------------------------------------- 白板
/**********新白板接口**********/

/**
 创建白板
 @param w 白板宽
 @param h 白板高
 @param pageCount 白板页数
 @param pageMode 连页（0） 单页（1）
 @param exInfo 白板的扩展信息<=4KB
 */
- (void)createWhiteBoard:(int)w h:(int)h pageCount:(int)pageCount pageMode:(CLPageMode)pageMode exInfo:(NSString *)exInfo;

/**
 关闭白板
 @param boardID 白板ID
 */
- (void)closeBoard:(NSString *)boardID;

/**
 获取房间中的所有白板
*/
- (NSArray<NSString *> *)getAllBoard;

/// 更新白板的扩展信息
/// @param boardID 白板ID
/// @param exInfo 白板扩展信息
- (void)updateBoardExInfo:(NSString *)boardID exInfo:(NSString *)exInfo;


/// 获取白板信息
/// @param boardID 白板ID
- (BoardInfo *)getBoardInfo:(NSString *)boardID;

/// 获取当前board
- (NSString *)getCurrentBoard;

/// 设置当前board
/// @param boardID 白板ID
- (void)setCurrentBoard:(NSString *)boardID;

#pragma mark ----------------------------------------------- 指定视频设备参数控制disabled属性
- (void)setLocVideoAttributes:(int)videoID attributes:(CamAttribute*)attributes;
- (CamAttribute*)getLocVideoAttributes:(int)videoID;


#pragma mark ----------------------------------------------- 会议属性 用户属性
//会议属性
- (void)getMeetingAllAttrs:(NSString *)cookie;

- (void)getMeetingAttrs:(NSArray<NSString *> *) keys cookie:(NSString *)cookie;
//全部)重置
- (void)setMeetingAttrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//添加)或更新
- (void)addOrUpdateMeetingAttrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//删除
- (void)delMeetingAttrs:(NSArray<NSString *> *)keys options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//清空)
- (void)clearMeetingAttrs:(NSMutableDictionary *)options cookie:(NSString *)cookie;

//获取)指定用户的所有属性（一次最大只能获取50人的属性）
- (void)getUserAttrs:(NSArray<NSString *> *)uids keys:(NSArray<NSString *> *)keys cookie:(NSString *)cookie;
//重置)指定用户的属性(用户之前的属性将被清空)
- (void)setUserAttrs:(NSString *)uid attrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//添加)或更新指定用户的属性
- (void)addOrUpdateUserAttrs:(NSString *)uid attrs:(NSMutableDictionary *)attrs options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//删除)指定用户的属性
- (void)delUserAttrs:(NSString *)uid keys:(NSArray<NSString *> *)keys options:(NSMutableDictionary *)options cookie:(NSString *)cookie;
//清空)指定用户的属性
- (void)clearAllUserAttrs:(NSMutableDictionary *)options cookie:(NSString *)cookie;
- (void)clearUserAttrs:(NSString *)uID options:(NSString *)options cookie:(NSString *)cookie;


- (void)setVideoBlur:(BOOL)blur;
- (BOOL)getVideoBlur;
- (void)setVideoDressFrame:(UIImage *)image;
- (BOOL)hasStartDress;

@end

NS_ASSUME_NONNULL_END
#endif  // __RTC_MEETING_H__

