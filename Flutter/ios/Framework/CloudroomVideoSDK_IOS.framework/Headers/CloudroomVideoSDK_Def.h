#ifndef __CLOUDROOMVIDEO_SDK_ERRDEF_H__
#define __CLOUDROOMVIDEO_SDK_ERRDEF_H__

#ifdef __cplusplus
#define CRVSDK_EXPORT       extern "C" __attribute__((visibility ("default")))
#else
#define CRVSDK_EXPORT       extern __attribute__((visibility ("default")))
#endif
typedef enum
{
	//虚拟摄像头相关
	CRVIDEOSDK_VCAM_URLERR = -1,			//ipcam url不正确
	CRVIDEOSDK_VCAM_ALREADYEXIST=-2,		//已存在
	CRVIDEOSDK_VCAM_TOOMANY=-3,				//添加太多
	CRVIDEOSDK_VCAM_INVALIDFMT=-4,			//不支持的格式
	CRVIDEOSDK_VCAM_INVALIDMONITOR=-5,		//无效的屏幕id


    CRVIDEOSDK_NOERR = 0,

    //基础错误
    CRVIDEOSDK_UNKNOWERR,                 //未知错误
    CRVIDEOSDK_OUTOF_MEM,                 //内存不足
    CRVIDEOSDK_INNER_ERR,                 //sdk内部错误
    CRVIDEOSDK_MISMATCHCLIENTVER,         //不支持的sdk版本
    CRVIDEOSDK_PARAM_ERR,				  //参数错误
    CRVIDEOSDK_ERR_DATA,                  //无效数据
    CRVIDEOSDK_ANCTPSWD_ERR,              //帐号密码不正确
    CRVIDEOSDK_SERVER_EXCEPTION,          //服务异常
    CRVIDEOSDK_LOGINSTATE_ERROR,          //登录状态错误
    CRVIDEOSDK_KICKOUT_BY_RELOGIN,        //帐号在别处被使用
    CRVIDEOSDK_NOT_INIT,                  //sdk未初始化
    CRVIDEOSDK_NOT_LOGIN,                 //还没有登录
    CRVIDEOSDK_BASE64_COV_ERR,            //base64转换失败

	CRVIDEOSDK_CUSTOMAUTH_NOINFO,		//启用了第三方鉴权，但没有携带鉴权信息
	CRVIDEOSDK_CUSTOMAUTH_NOTSUPPORT,	//没有启用第三方鉴权，但携带了鉴权信息
	CRVIDEOSDK_CUSTOMAUTH_EXCEPTION,	//访问第三方鉴权服务异常
	CRVIDEOSDK_CUSTOMAUTH_FAILED,		//第三方鉴权不通过

	//Token鉴权失败
	CRVIDEOSDK_TOKEN_TIMEOUT,			//token已过期
	CRVIDEOSDK_TOKEN_AUTHINFOERR,		//鉴权信息错误
	CRVIDEOSDK_TOKEN_APPIDNOTEXIST,		//appid不存在
	CRVIDEOSDK_TOKEN_AUTH_FAILED,		//鉴权失败
	CRVIDEOSDK_TOKEN_NOTTOKENTYPE,		//非token鉴权方式

	CRVIDEOSDK_API_NO_PERMISSION,		//没有api访问权限
	CRVIDEOSDK_ACCOUNT_EXPIRED,			//账号已过期

    //网络
    CRVIDEOSDK_NETWORK_INITFAILED=200,    //网络初始化失败
    CRVIDEOSDK_NO_SERVERINFO,             //没有服务器信息
    CRVIDEOSDK_NOSERVER_RSP,              //服务器没有响应
    CRVIDEOSDK_CREATE_CONN_FAILED,        //创建连接失败
    CRVIDEOSDK_SOCKETEXCEPTION,           //socket异常
    CRVIDEOSDK_SOCKETTIMEOUT,             //网络超时
    CRVIDEOSDK_FORCEDCLOSECONNECTION,     //连接被关闭
    CRVIDEOSDK_CONNECTIONLOST,            //连接丢失
	CRVIDEOSDK_VOICEENG_INITFAILED,		  //语音引擎初始化失败
	CRVIDEOSDK_SSL_ERR,					  //ssl通信错误
	CRVIDEOSDK_RSPDAT_ERR,				  //响应数据不正确
	CRVIDEOSDK_DATAENCRYPT_ERR,			  //数据加密失败
	CRVIDEOSDK_DATADECRYPT_ERR,			  //数据加密失败

    //队列相关错误定义
    CRVIDEOSDK_QUE_ID_INVALID=400,        //队列ID错误
    CRVIDEOSDK_QUE_NOUSER,                //没有用户在排队
    CRVIDEOSDK_QUE_USER_CANCELLED,        //排队用户已取消
    CRVIDEOSDK_QUE_SERVICE_NOT_START,
    CRVIDEOSDK_ALREADY_OTHERQUE,          //已在其它队列排队(客户只能在一个队列排队)

    //呼叫
    CRVIDEOSDK_INVALID_CALLID=600,        //无效的呼叫ID
    CRVIDEOSDK_ERR_CALL_EXIST,            //已在呼叫中
    CRVIDEOSDK_ERR_BUSY,                  //对方忙
    CRVIDEOSDK_ERR_OFFLINE,               //对方不在线
    CRVIDEOSDK_ERR_NOANSWER,              //对方无应答
    CRVIDEOSDK_ERR_USER_NOT_FOUND,        //用户不存在
    CRVIDEOSDK_ERR_REFUSE,                //对方拒接

    //会话业务错误
    CRVIDEOSDK_MEETNOTEXIST=800,          //会议不存在或已结束
    CRVIDEOSDK_AUTHERROR,                 //会议密码不正确
    CRVIDEOSDK_MEMBEROVERFLOWERROR,       //会议终端数量已满（购买的license不够)
    CRVIDEOSDK_RESOURCEALLOCATEERROR,     //分配会议资源失败
    CRVIDEOSDK_MEETROOMLOCKED,            //会议已加锁
    CRVIDEOSDK_BALANCELESSERROR,          //余额不足
    CRVIDEOSDK_SEVICE_NOTENABLED,         //业务权限未开启
	CRVIDEOSDK_ALREADYLOGIN,			  //不能再次登录
	CRVIDEOSDK_MIC_NORIGHT,               //没有mic权限
	CRVIDEOSDK_MIC_BEING_USED,            //mic已被使用
	CRVIDEOSDK_MIC_UNKNOWERR,             //mic未知错误
	CRVIDEOSDK_SPK_NORIGHT,               //没有扬声器权限
	CRVIDEOSDK_SPK_BEING_USED,            //扬声器已被使用
	CRVIDEOSDK_SPK_UNKNOWERR,             //扬声器未知错误
	CRVIDEOSDK_PIC_ISNULL,				  //图像为空
	CRVIDEOSDK_DEV_NOTEXIST,			  //设备不存在
	CRVIDEOSDK_MIC_OPENTOOMUCH,			  //开麦达到上限
	CRVIDEOSDK_NOT_INMEETING,			  //还没有入会


    //录制错误
    CRVIDEOSDK_CATCH_SCREEN_ERR = 900,		//抓屏失败
    CRVIDEOSDK_RECORD_MAX,					//单次录制达到最大时长(8h)
    CRVIDEOSDK_RECORD_NO_DISK,				//磁盘空间不够
	CRVIDEOSDK_RECORD_SIZE_ERR,				//录制尺寸超出了允许值
	CRVIDEOSDK_CFG_RESTRICTED,				//录制超出限制
	CRVIDEOSDK_FILE_ERR,					//录制文件操作出错
	CRVIDEOSDK_RECORDSTARTED,				//录制已开启
	CRVIDEOSDK_NOMORE_MCU,					//录制服务器资源不足
	CRVIDEOSDK_SVRRECORD_SPACE_FULL,		//云端录像空间已满

	//IM
	CRVIDEOSDK_SENDFAIL = 1000,				//发送失败
	CRVIDEOSDK_CONTAIN_SENSITIVEWORDS,		//有敏感词语

	//透明通道
	CRVIDEOSDK_SENDCMD_LARGE = 1100,		//发送信令数据过大
	CRVIDEOSDK_SENDBUFFER_LARGE ,			//发送数据过大
	CRVIDEOSDK_SENDDATA_TARGETINVALID,		//目标用户不存在
	CRVIDEOSDK_SENDFILE_FILEINERROR,		//文件错误s
	CRVIDEOSDK_TRANSID_INVALID,				//无效的发送id

	//录制文件管理
	CRVIDEOSDK_RECORDFILE_STATE_ERR = 1200,	//状态错误不可上传/取消上传
	CRVIDEOSDK_RECORDFILE_NOT_EXIST,		//录制文件不存在
	CRVIDEOSDK_RECORDFILE_UPLOAD_FAILED,	//上传失败，失败原因参考日志
	CRVIDEOSDK_RECORDFILE_DEL_FAILED,		//移除本地文件失败

	//文件相关错误
	CRVIDEOSDK_FILE_NOT_EXIST = 1400,		//文件不存在
	CRVIDEOSDK_FILE_READ_ERR,				//文件读失败
	CRVIDEOSDK_FILE_WRITE_ERR,				//文件写失败
	CRVIDEOSDK_FILE_ALREADY_EXIST,			//目标文件已存在
	CRVIDEOSDK_FILE_OPERATOR_ERR,			//文件操作失败
	CRVIDEOSDK_FILE_SIZE_UNSUPPORT,			//不支持的文件尺寸

	//网盘错误
	CRVIDEOSDK_NETDISK_NOT_EXIST = 1500,	//网盘不存在
	CRVIDEOSDK_NETDISK_PERMISSIONDENIED,	//没有网盘权限
	CRVIDEOSDK_NETDISK_INVALIDFILENAME,		//不合法文件名
	CRVIDEOSDK_NETDISK_FILEALREADYEXISTS,	//文件已存在s
	CRVIDEOSDK_NETDISK_FILEORDIRECTORYNOTEXISTS, //文件或目录不存在
	CRVIDEOSDK_NETDISK_FILENOTTRANSFORM,	//文件没有转换
	CRVIDEOSDK_NETDISK_TRANSFORMFAILED,		//文件转换失败
	CRVIDEOSDK_NETDISK_NOSPACE,				//空间不足

    
    //web js定义， 2000~3000

} CRVIDEOSDK_ERR_DEF;


/*
sdk日志等级
*/
typedef enum
{
    CRVIDEOSDK_LOG_DEBUG = 0,
    CRVIDEOSDK_LOG_INFO,
    CRVIDEOSDK_LOG_WARN,
    CRVIDEOSDK_LOG_ERR
}CRVIDEOSDK_LOG_LEVEL;

/*
用户登录状态
*/
typedef enum
{
    CRVIDEOSDK_USER_OFFLINE = 0,    //sdk用户未登录
    CRVIDEOSDK_USER_ONLINE,            //sdk用户已登录
    CRVIDEOSDK_USER_BUSY            //sdk用户已登录，且呼叫中
}CRVIDEOSDK_USER_STATUS;

/*
会议与会议断开原因
*/
typedef enum
{
    CRVIDEOSDK_DROPPED_TIMEOUT = 0,        //网络通信超时
    CRVIDEOSDK_DROPPED_KICKOUT,            //被他人请出会议
    CRVIDEOSDK_DROPPED_BALANCELESS,        //余额不足
    CRVIDEOSDK_DROPPED_TOKENINVALID        //Token鉴权方式下，token无效或过期
}CRVIDEOSDK_MEETING_DROPPED_REASON;

/*
排队客户离开队列原因
*/
typedef enum  {
    CRVIDEOSDK_LQR_STOPQUEUE = 0,    //用户停止排队
    CRVIDEOSDK_LQR_INSERVICE        //用户分配给了某座席
}CRVIDEOSDK_LEFT_QUEUE_REASON;


/*
文件传输状态
*/
typedef enum
{
    CRVIDEOSDK_FILEST_NULL = 0,        //未开始
    CRVIDEOSDK_FILEST_QUEUE,        //排队中
    CRVIDEOSDK_FILEST_TRANSFERING,    //传输(上传 / 下载)中
    CRVIDEOSDK_FILEST_FINISHED        //传输完成
}CRVIDEOSDK_FILETRANSFER_STATE;

/*
文件传输结果
*/
typedef enum
{
    CRVIDEOSDK_FILERST_SUCCESS = 0,            //成功
    CRVIDEOSDK_FILERST_UNKNOWERR,            //内部错误
    CRVIDEOSDK_FILERST_PARAMERR,            //参数错误
    CRVIDEOSDK_FILERST_NETWORKFAIL,            //网络不通 / 地址不对
    CRVIDEOSDK_FILERST_NETWORKTIMEOUT,        //超时失败
    CRVIDEOSDK_FILERST_FILEOPERATIONFAIL,    //文件操作失败
    CRVIDEOSDK_FILERST_PATHNOTSUPPROT,        //不支持的路径
    CRVIDEOSDK_FILERST_FILETRANSFERING,        //文件正在传输
    CRVIDEOSDK_FILERST_HTTPERR_BEGIN = 1000,    //HTTP错误码启始(10404: 代表HTTP 404)
    CRVIDEOSDK_FILERST_HTTPERR_END = 1999        //HTTP错误码结束
}CRVIDEOSDK_FILETRANSFER_RESULT;

/*
视频设备类型
*/
typedef enum
{
    CRVIDEOSDK_VDEV_UNKNOW = 0,    //
    CRVIDEOSDK_VDEV_SYSDV,        //系统物理设备
    CRVIDEOSDK_VDEV_IP,            //网络摄像头
    CRVIDEOSDK_VDEV_CUSTOM,        //自定义摄像头
    CRVIDEOSDK_VDEV_SCREEN        //屏幕摄像头
}CRVIDEOSDK_VDEV_TYPE;

/*
麦状态
*/
typedef enum
{
    CRVIDEOSDK_AUNKNOWN = 0,    //未知，正在从系统获取
    CRVIDEOSDK_ANULL,            //没有麦克风设备
    CRVIDEOSDK_ACLOSE,            //麦克风关闭
    CRVIDEOSDK_AOPEN,            //麦克风打开
    CRVIDEOSDK_AOPENING,        //开麦申请中
    CRVIDEOSDK_AOPENING2        //帮助他人开麦中
}CRVIDEOSDK_ASTATUS;

/*
视频状态
*/
typedef enum
{
    CRVIDEOSDK_VUNKNOWN = 0,    //未知，正在从系统获取
    CRVIDEOSDK_VNULL,            //无摄像头
    CRVIDEOSDK_VCLOSE,            //摄像头关闭
    CRVIDEOSDK_VOPEN,            //摄像头打开
    CRVIDEOSDK_VOPENING            //打开摄像头申请中
}CRVIDEOSDK_VSTATUS;

/*
音频格式
*/
typedef enum
{
    CRVIDEOSDK_AFMT_INVALID = -1,        //无效格式
    CRVIDEOSDK_AFMT_PCM16BIT = 0        //pcm 16bit
}CRVIDEOSDK_AUDIO_FORMAT;

/*
视频大小流
*/
typedef enum
{
    CRVIDEOSDK_VSQT_LV0 = 0,        //视频标准流
    CRVIDEOSDK_VSQT_LV1,            //视频第二档流
}CRVIDEOSDK_VSTEAMLV_YTYPE;

/*
视频格式
*/
typedef enum
{
    CRVIDEOSDK_VFMT_INVALID = -1,    //无效格式
    CRVIDEOSDK_VFMT_YUV420P = 0,    //yuv420p, 3个平面数据
    CRVIDEOSDK_VFMT_ARGB32,            //rgb32, 1个平面数据，0xAA,0xRR,0xGG,0xBB
    CRVIDEOSDK_VFMT_RGBA32,            //rgb32, 1个平面数据，0xRR,0xGG,0xBB,0xAA
    CRVIDEOSDK_VFMT_H264            //h264裸数据，1个平面数据
}CRVIDEOSDK_VIDEO_FORMAT;

/*
视频虚拟背景类型
*/
typedef enum
{
    CRVIDEOSDK_VBK_NULL = 0,        //不启用虚拟背景功能
    CRVIDEOSDK_VBK_COLORKEY,        //绿幕模式
    CRVIDEOSDK_VBK_HUMANONLY        //人像模式
}CRVIDEOSDK_VIRTUALBK_TYPE;

/*
远程控制鼠标消息类型
*/
typedef enum
{
    CRVIDEOSDK_MOUSE_MOVE = 0,        //鼠标移动
    CRVIDEOSDK_MOUSE_DOWN,            //鼠标按下
    CRVIDEOSDK_MOUSE_UP,            //鼠标松开
    CRVIDEOSDK_MOUSE_DBCLICK        //鼠标双击
}CRVIDEOSDK_MOUSEMSG_TYPE;

/*
远程控制鼠标键类型
*/
typedef enum
{
    CRVIDEOSDK_MOUSEKEY_NULL = 0,
    CRVIDEOSDK_MOUSEKEY_L,
    CRVIDEOSDK_MOUSEKEY_M,
    CRVIDEOSDK_MOUSEKEY_R,
    CRVIDEOSDK_MOUSEKEY_WHEEL,
    CRVIDEOSDK_MOUSEKEY_X
}CRVIDEOSDK_MOUSEKEY_TYPE;

/*
远程控制键盘消息类型
*/
typedef enum
{
    CRVIDEOSDK_KEY_DWON = 0,
    CRVIDEOSDK_KEY_UP,
}CRVIDEOSDK_KEYMSG_TYPE;

/*
屏幕共享状态
*/
typedef enum
{
    CRVIDEOSDK_SCREENST_SHARING = 1,        //屏幕共享中
    CRVIDEOSDK_SCREENST_MARKING = 1<<1,        //标注中
    CRVIDEOSDK_SCREENST_PAUSECTRL = 1<<2,    //暂停控制（共享者自已移动了鼠标，或共享暂停了）
}CRVIDEOSDK_SCREESHARE_STATE;

/*
影音共享状态
*/
typedef enum
{
    CRVIDEOSDK_MEDIA_PLAYING = 0,        //播放中
    CRVIDEOSDK_MEDIA_PAUSED,            //暂停中
    CRVIDEOSDK_MEDIA_STOPPED            //未播放
}CRVIDEOSDK_MEDIA_STATE;


typedef enum
{
    CRVIDEOSDK_VIEWTP_VIDEO = 0,    //摄像头显示View
    CRVIDEOSDK_VIEWTP_SCREEN,        //屏幕共享显示View
    CRVIDEOSDK_VIEWTP_MEDIA,        //影音共享显示View
}CRVIDEOSDK_RENDER_VIEWTYPE;

/*
图像显示模式
*/
typedef enum
{
    CRVIDEOSDK_RENDERMD_FIT = 0,    //等比缩放到在窗口大小并完整显示，空区域填黑
    CRVIDEOSDK_RENDERMD_HIDDEN,        //等比缩放到完整覆盖窗口，超出区域图像被裁剪掉
    CRVIDEOSDK_RENDERMD_FILL        //缩放图像充满窗口（图像可能变形）
}CRVIDEOSDK_RENDER_MODE;

/* mouse events */
#define NX_LMOUSEDOWN        1    /* left mouse-down event */
#define NX_LMOUSEUP        2    /* left mouse-up event */
#define NX_RMOUSEDOWN        3    /* right mouse-down event */
#define NX_RMOUSEUP        4    /* right mouse-up event */
#define NX_MOUSEMOVED        5    /* mouse-moved event */
#define NX_LMOUSEDRAGGED    6    /* left mouse-dragged event */
#define NX_RMOUSEDRAGGED    7    /* right mouse-dragged event */
#define NX_MOUSEENTERED        8    /* mouse-entered event */
#define NX_MOUSEEXITED        9    /* mouse-exited event */
/* other mouse events
 *
 * event.data.mouse.buttonNumber should contain the
 * button number (2-31) changing state.
 */
#define NX_OMOUSEDOWN        25    /* other mouse-down event */
#define NX_OMOUSEUP        26    /* other mouse-up event */
#define NX_OMOUSEDRAGGED    27    /* other mouse-dragged event */
/* Scroll wheel events */
#define NX_SCROLLWHEELMOVED    22

#define MOUSEEVENTF_LEFTUP         NX_LMOUSEUP
#define MOUSEEVENTF_LEFTDOWN       NX_LMOUSEDOWN
#define MOUSEEVENTF_MIDDLEUP       NX_OMOUSEUP
#define MOUSEEVENTF_MIDDLEDOWN     NX_OMOUSEDOWN
#define MOUSEEVENTF_RIGHTUP        NX_RMOUSEUP
#define MOUSEEVENTF_RIGHTDOWN      NX_RMOUSEDOWN
#define MOUSEEVENTF_XUP            NX_OMOUSEUP
#define MOUSEEVENTF_XDOWN          NX_OMOUSEDOWN
#define MOUSEEVENTF_WHEEL          NX_SCROLLWHEELMOVED
#define MOUSEEVENTF_MOVE           NX_MOUSEMOVED



#endif
