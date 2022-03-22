#ifndef __CLOUDROOM_HTTPFILEMGR_H__
#define __CLOUDROOM_HTTPFILEMGR_H__

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>


typedef NS_ENUM (NSInteger, HTTP_TRANSFER_STATE)
{
    HTS_NULL = 0, // 未开始
    HTS_QUEUE, // 排队中
    HTS_TRANSFERING, // 传输中
    HTS_FINISHED, // 传输完成
    HTS_BUUT
};


typedef NS_ENUM (NSInteger, HTTP_TRANSFER_RESULT)
{
    HTR_Success = 0, // 成功
    HTR_InnerErr, // 内部错误
    HTR_ParamErr, // 参数错误
    HTR_NetworkFail, // 网络不通/地址不对
    HTR_NetworkTimeout, // 超时失败
    HTR_FileOperationFail, // 文件操作失败
    HTR_PathNotSupprot, // 不支持的路径
    HTR_FileTransfering, // 文件正在传输
    HTR_NoOpenSSLLIb, // 程序不能加载openssl库
    HTR_HTTPERR_BEGIN = 1000,	// http错误开始
    HTR_HTTPERR_END	= 1999,
};

/* 文件传输信息 */
CRVSDK_EXPORT
@interface FileTransInfo : NSObject

@property (nonatomic, assign) HTTP_TRANSFER_STATE state; /**< 状态 */
@property (nonatomic, assign) int fileSize; /**< 文件大小 */
@property (nonatomic, assign) int finishedSize; /**< 已传输大小 */

@end

/* 请求信息 */
CRVSDK_EXPORT
@interface HTTPReqInfo : NSObject

@property (nonatomic, copy) NSString *filePathName; /**< 本地路径文件名 */
@property (nonatomic, copy) NSString *httpUrl; /**< URL地址 */
@property (nonatomic, copy) NSString *fileVersion; /**< 建议使用文件MD5值 */
@property (nonatomic, assign) BOOL bUploadType; /**< 传输类型 */
@property (nonatomic, copy) NSString *params; /**< 特殊参数(如边录边传,云屋加密类型) */

@end



/* 协议 */

@protocol CloudroomHttpFileMgrCallBack <NSObject>
@optional

- (void)fileStateChanged:(NSString *)fileName state:(HTTP_TRANSFER_STATE)state;
- (void)fileHttpRspHeader:(NSString *)fileName rspHeader:(NSString *)rspHeader;
- (void)fileProgress:(NSString *)fileName finishedSize:(int)finishedSize totalSize:(int)totalSize;
- (void)fileFinished:(NSString *)fileName rslt:(HTTP_TRANSFER_STATE)rslt;
- (void)fileHttpRspContent:(NSString *)fileName content:(NSString *)content;
- (void)fileRename:(NSString *)fileName newName:(NSString *)newName;

@end

CRVSDK_EXPORT
@interface CloudroomHttpFileMgr : NSObject

// 获取单例对象
+ (CloudroomHttpFileMgr *)shareInstance;

- (BOOL)startMgr;
- (void)stopMgr;
//- (BOOL)isStarted;

// 设置回调
- (void)setHttpFileMgrCallback:(id <CloudroomHttpFileMgrCallBack>)callBack;
- (void)registerHttpFileMgrCallback:(id <CloudroomHttpFileMgrCallBack>)callBack;

- (void)removeHttpFileMgrCallback:(id <CloudroomHttpFileMgrCallBack>)callBack;


// 获取所有从服务端下载的风险提示文件(包括以前下载的)
- (NSArray <FileTransInfo *> *)getAllHttpFiles;

// 获取指定文件传输信息
- (FileTransInfo *)getTransferInfo:(NSString *)fileName;

// 开始传输文件
- (void)startTransferFile:(HTTPReqInfo *)file;

// 取消文件传输
- (void)cancelFileTransfer:(NSString *)fileName;

// 移除传输信息
- (void)rmTransferInfo:(NSString *)fileName rmLocFile:(BOOL)rmLocFile;

@end

#endif  // __CLOUDROOM_HTTPFILEMGR_H__

