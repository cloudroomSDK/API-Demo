﻿#include "stdafx.h"
#include "ErrDesc.h"

QString getErrDesc(CRVSDK_ERR_DEF err)
{
	static QMap<int, QString> errs = {
		{ CRVSDKERR_VCAM_URLERR, "ipcam url不正确" },
		{ CRVSDKERR_VCAM_ALREADYEXIST, "已存在" },
		{ CRVSDKERR_VCAM_TOOMANY, "添加太多" },
		{ CRVSDKERR_VCAM_INVALIDFMT, "不支持的格式" },
		{ CRVSDKERR_VCAM_INVALIDMONITOR, "无效的屏幕id" },

		{ CRVSDKERR_NOERR, "没有错误" },
		{ CRVSDKERR_UNKNOWERR, "未知错误" },
		{ CRVSDKERR_OUTOF_MEM, "内存不足" },
		{ CRVSDKERR_INNER_ERR, "sdk内部错误" },
		{ CRVSDKERR_MISMATCHCLIENTVER, "不支持的sdk版本" },
		{ CRVSDKERR_PARAM_ERR, "参数错误" },
		{ CRVSDKERR_ERR_DATA, "无效数据" },
		{ CRVSDKERR_ANCTPSWD_ERR, "AppID或AppSecret不正确" },
		{ CRVSDKERR_SERVER_EXCEPTION, "服务异常" },
		{ CRVSDKERR_LOGINSTATE_ERROR, "登录状态错误" },
		{ CRVSDKERR_KICKOUT_BY_RELOGIN, "帐号在别处被使用" },
		{ CRVSDKERR_NOT_INIT, "sdk未初始化" },
		{ CRVSDKERR_NOT_LOGIN, "还没有登录" },
		{ CRVSDKERR_BASE64_COV_ERR, "base64转换失败" },
		{ CRVSDKERR_CUSTOMAUTH_NOINFO, "启用了第三方鉴权，但没有携带鉴权信息" },
		{ CRVSDKERR_CUSTOMAUTH_NOTSUPPORT, "没有启用第三方鉴权，但携带了鉴权信息" },
		{ CRVSDKERR_CUSTOMAUTH_EXCEPTION, "访问第三方鉴权服务异常" },
		{ CRVSDKERR_CUSTOMAUTH_FAILED, "第三方鉴权不通过" },
		{ CRVSDKERR_TOKEN_TIMEOUT, "token已过期" },
		{ CRVSDKERR_TOKEN_AUTHINFOERR, "鉴权信息错误" },
		{ CRVSDKERR_TOKEN_APPIDNOTEXIST, "appid不存在" },
		{ CRVSDKERR_TOKEN_AUTH_FAILED, "鉴权失败" },
		{ CRVSDKERR_TOKEN_NOTTOKENTYPE, "非token鉴权方式" },
		{ CRVSDKERR_API_NO_PERMISSION, "没有api访问权限" },

		{ CRVSDKERR_ACCOUNT_EXPIRED, "账号已过期" },
		{ CRVSDKERR_CLIENT_NO_PERMISSION, "所有终端未授权" },
		{ CRVSDKERR_CLIENT_SIP_NO_PERMISSION, "sip/h323终端未授权" },
		{ CRVSDKERR_CLIENT_IPC_NO_PERMISSION, "IPC终端未授权" },
		{ CRVSDKERR_CLIENT_PLATFORM_NO_PERMISSION, "当前使用的终端平台未授权" },
		{ CRVSDKERR_CLIENT_PLATFORM_UNSPPORT, "不支持当前使用的终端平台" },
		{ CRVSDKERR_FUNC_UNSPPORT, "不支持的功能或操作" },

		{ CRVSDKERR_NETWORK_INITFAILED, "网络初始化失败" },
		{ CRVSDKERR_NO_SERVERINFO, "没有服务器信息" },
		{ CRVSDKERR_NOSERVER_RSP, "服务器没有响应" },
		{ CRVSDKERR_CREATE_CONN_FAILED, "创建连接失败" },
		{ CRVSDKERR_SOCKETEXCEPTION, "socket异常" },
		{ CRVSDKERR_SOCKETTIMEOUT, "网络超时" },
		{ CRVSDKERR_FORCEDCLOSECONNECTION, "连接被关闭" },
		{ CRVSDKERR_CONNECTIONLOST, "连接丢失" },
		{ CRVSDKERR_VOICEENG_INITFAILED, "语音引擎初始化失败" },
		{ CRVSDKERR_SSL_ERR, "ssl通信错误" },
		{ CRVSDKERR_RSPDAT_ERR, "响应数据不正确" },
		{ CRVSDKERR_DATAENCRYPT_ERR, "数据加密失败" },
		{ CRVSDKERR_DATADECRYPT_ERR, "数据加密失败" },

		{ CRVSDKERR_QUE_ID_INVALID, "队列ID错误" },
		{ CRVSDKERR_QUE_NOUSER, "没有用户在排队" },
		{ CRVSDKERR_QUE_USER_CANCELLED, "排队用户已取消" },
		{ CRVSDKERR_QUE_SERVICE_NOT_START, "没有开启队列服务" },
		{ CRVSDKERR_ALREADY_OTHERQUE, "已在其它队列排队" },

		{ CRVSDKERR_INVALID_CALLID, "无效的呼叫ID" },
		{ CRVSDKERR_CALL_EXIST, "已在呼叫中" },
		{ CRVSDKERR_PEER_BUSY, "对方忙" },
		{ CRVSDKERR_PEER_OFFLINE, "对方不在线" },
		{ CRVSDKERR_PEER_NOANSWER, "对方无应答" },
		{ CRVSDKERR_PEER_NOT_FOUND, "用户不存在" },
		{ CRVSDKERR_PEER_REFUSE, "对方拒接" },

		{ CRVSDKERR_MEETNOTEXIST, "会议不存在或已结束" },
		{ CRVSDKERR_AUTHERROR, "会议密码不正确" },
		{ CRVSDKERR_MEMBEROVERFLOW, "会议终端数量已满" },
		{ CRVSDKERR_RESOURCEALLOCATEERROR, "分配会议资源失败" },
		{ CRVSDKERR_MEETROOMLOCKED, "会议已加锁" },
		{ CRVSDKERR_BALANCELESS, "余额不足" },
		{ CRVSDKERR_SEVICE_NOTENABLED, "业务权限未开启" },
		{ CRVSDKERR_ALREADYINMEETING, "不能再次入会" },
		{ CRVSDKERR_MIC_NORIGHT, "没有mic权限" },
		{ CRVSDKERR_MIC_BEING_USED, "mic已被使用" },
		{ CRVSDKERR_MIC_UNKNOWERR, "mic未知错误" },
		{ CRVSDKERR_SPK_NORIGHT, "没有扬声器权限" },
		{ CRVSDKERR_SPK_BEING_USED, "扬声器已被使用" },
		{ CRVSDKERR_SPK_UNKNOWERR, "扬声器未知错误" },
		{ CRVSDKERR_PIC_ISNULL, "图像为空" },
		{ CRVSDKERR_DEV_NOTEXIST, "设备不存在" },
		{ CRVSDKERR_MIC_OPENTOOMUCH, "开麦达到上限" },
		{ CRVSDKERR_NOT_INMEETING, "还没有入会" },
		{ CRVSDKERR_REPEAT_FAIL, "数据重复或功能重复开启" },

		{ CRVSDKERR_CATCH_SCREEN_ERR, "抓屏失败" },
		{ CRVSDKERR_RECORD_MAX, "单次录制达到最大时长" },
		{ CRVSDKERR_RECORD_NO_DISK, "磁盘空间不够" },
		{ CRVSDKERR_RECORD_SIZE_ERR, "录制尺寸超出了允许值" },
		{ CRVSDKERR_CFG_RESTRICTED, "录制超出限制" },
		{ CRVSDKERR_FILE_ERR, "录制写文件或推流失败" },
		{ CRVSDKERR_RECORDSTARTED, "录制已开启" },
		{ CRVSDKERR_NOMORE_MCU, "录制服务器资源不足" },
		{ CRVSDKERR_SVRRECORD_SPACE_FULL, "云端录像空间已满" },

		{ CRVSDKERR_SENDFAIL, "发送失败" },
		{ CRVSDKERR_CONTAIN_SENSITIVEWORDS, "有敏感词语" },

		{ CRVSDKERR_SENDCMD_LARGE, "发送信令数据过大" },
		{ CRVSDKERR_SENDBUFFER_LARGE, "发送数据过大" },
		{ CRVSDKERR_SENDDATA_TARGETINVALID, "目标用户不存在" },
		{ CRVSDKERR_SENDFILE_FILEINERROR, "文件错误" },
		{ CRVSDKERR_TRANSID_INVALID, "无效的发送id" },

		{ CRVSDKERR_RECORDFILE_STATE_ERR, "状态错误不可上传/取消上传" },
		{ CRVSDKERR_RECORDFILE_NOT_EXIST, "录制文件不存在" },
		{ CRVSDKERR_RECORDFILE_UPLOAD_FAILED, "上传失败，失败原因参考日志" },
		{ CRVSDKERR_RECORDFILE_DEL_FAILED, "移除本地文件失败" },

		{ CRVSDKERR_FILE_NOT_EXIST, "文件不存在" },
		{ CRVSDKERR_FILE_READ_ERR, "文件读失败" },
		{ CRVSDKERR_FILE_WRITE_ERR, "文件写失败" },
		{ CRVSDKERR_FILE_ALREADY_EXIST, "目标文件已存在" },
		{ CRVSDKERR_FILE_OPERATOR_ERR, "文件操作失败" },
		{ CRVSDKERR_FILE_SIZE_UNSUPPORT, "不支持的文件尺寸" },

		{ CRVSDKERR_NETDISK_NOT_EXIST, "网盘不存在" },
		{ CRVSDKERR_NETDISK_PERMISSIONDENIED, "没有网盘权限" },
		{ CRVSDKERR_NETDISK_INVALIDFILENAME, "不合法文件名" },
		{ CRVSDKERR_NETDISK_FILEALREADYEXISTS, "文件已存在" },
		{ CRVSDKERR_NETDISK_FILEORDIRECTORYNOTEXISTS, "文件或目录不存在" },
		{ CRVSDKERR_NETDISK_FILENOTTRANSFORM, "文件没有转换" },
		{ CRVSDKERR_NETDISK_TRANSFORMFAILED, "文件转换失败" },
		{ CRVSDKERR_NETDISK_NOSPACE, "空间不足" },

		{ CRVSDKERR_PLUGIN_INITFAILED, "插件加载失败" },
		{ CRVSDKERR_PLUGIN_NOTINIT, "插件还未初始化" },
		{ CRVSDKERR_PLUGIN_CREATEFAILED, "创建插件实例失败" }
	};

	auto pos = errs.find(err);
	if (pos == errs.end())
	{
		return QString("未知错误(%1)").arg(err);
	}
	return pos.value();
}
