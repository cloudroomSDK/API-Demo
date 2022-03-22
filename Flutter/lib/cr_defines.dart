// 定义SDK的数据结构，且处理默认值
// 忽略名称带下划线的
// ignore_for_file: non_constant_identifier_names, unused_field, constant_identifier_names

class CrSdkInitDat {
  String sdkDatSavePath; // SDK内部使用文件位置
  bool noCall; // 是否使用呼叫业务（可减少登录环节、及通信需求）
  bool noQueue; // 是否使用sdk的排队功能的业务（可减少登录环节、及通信需求）
  bool? noMediaDatToSvr; // 是否与服务器实时流媒体数据（可减少复杂度，加快登录速度）
  int? timeOut; // 网络通信超时时间(10000-120000)，单位是毫秒，超出范围时就近取边界值
  String? datEncType; // 数据加密类型("0":敏感数据加密，"1":全面加密; 缺省:"1")

  CrSdkInitDat(
      {required this.sdkDatSavePath,
      required this.noCall,
      required this.noQueue,
      this.noMediaDatToSvr,
      this.timeOut,
      this.datEncType});

  Map<String, dynamic> toJson() => {
        "sdkDatSavePath": sdkDatSavePath,
        "noCall": noCall,
        "noQueue": noQueue,
        "noMediaDatToSvr": noMediaDatToSvr,
        "timeOut": timeOut != null
            ? timeOut! > 120000
                ? 120000
                : timeOut! < 0
                    ? 10000
                    : timeOut
            : 10000,
        "datEncType": datEncType ?? "1"
      };
}

class CrLoginDat {
  String nickName;
  String privAcnt;
  String appID;
  String appSecret;
  CrLoginDat(
      {required this.nickName,
      required this.privAcnt,
      required this.appID,
      required this.appSecret});

  Map<String, dynamic> toJson() => {
        "nickName": nickName,
        "privAcnt": privAcnt,
        "authAcnt": appID,
        "authPswd": appSecret
      };
}

class CrLoginResult {
  String userID;
  String? cookie;
  int sdkErr;

  CrLoginResult({required this.userID, required this.sdkErr, this.cookie});
}

class CrMeetInfo {
  int? confId; // 房间号，数值0代表房间信息无效
  String? pubMeetUrl; // 房间公共链接
  int sdkErr;
  CrMeetInfo({this.confId, this.pubMeetUrl, required this.sdkErr});
}

// 房间断线原因
enum CR_MEETING_DROPPED_REASON {
  CRVIDEOSDK_DROPPED_TIMEOUT, // 	网络通信超时
  CRVIDEOSDK_DROPPED_KICKOUT, // 被他人请出会议
  CRVIDEOSDK_DROPPED_BALANCELESS, // 余额不足
  CRVIDEOSDK_DROPPED_TOKENINVALID // Token鉴权方式下，token无效或过期
}

/*
VSIZE_SZ_128	0	224*128, 推荐码率：72kbps
VSIZE_SZ_160	1	288*160, 推荐码率：100kbps
VSIZE_SZ_192	2	336*192, 推荐码率：150kbps
VSIZE_SZ_256	3	448*256, 推荐码率：200kbps
VSIZE_SZ_288	4	512*288, 推荐码率：250kbps
VSIZE_SZ_320	5	576*320, 推荐码率：300kbps
VSIZE_SZ_360	6	640*360, 推荐码率：350kbps
VSIZE_SZ_400	7	720*400, 推荐码率：420kbps
VSIZE_SZ_480	8	848*480, 推荐码率：500kbps
VSIZE_SZ_576	9	1024*576, 推荐码率：650kbps
VSIZE_SZ_720	10	1280*720, 推荐码率：1mbps
VSIZE_SZ_1080	11	1920*1080, 推荐码率：2mbps

*/
// enum VIDEO_SIZE_TYPE {
//   VSIZE_SZ_128,
//   VSIZE_SZ_160,
//   VSIZE_SZ_192,
//   VSIZE_SZ_256,
//   VSIZE_SZ_288,
//   VSIZE_SZ_320,
//   VSIZE_SZ_360,
//   VSIZE_SZ_400,
//   VSIZE_SZ_576,
//   VSIZE_SZ_480,
//   VSIZE_SZ_720,
//   VSIZE_SZ_1080
// }

class CrSize {
  int width;
  int height;
  CrSize({required this.width, required this.height});

  Map<String, dynamic> toJson() => {"width": width, "height": height};
}

// 视频配置
class CrVideoCfg {
  CrSize size; // 视频尺寸(如:"640*360")
  int fps; // 帧率：视频帧率(5~30)
  int?
      maxbps; // 视频码率（1000~100000000, 例如1m:1000000);(未配置则使用内部默认值，请参见CRVideo_VIDEO_SHOW_SIZE)
  int? qp_min; // 最佳质量(18~51, 越小质量越好) (未配置则使用内部默认值22)
  int? qp_max; // 最差质量(18~51, 越大质量越差) (未配置则使用内部默认值32)

  CrVideoCfg({
    required this.size,
    required this.fps,
    this.maxbps,
    this.qp_min,
    this.qp_max,
  });

  Map<String, dynamic> toJson() => {
        "size": size.toJson(),
        "fps": fps,
        "maxbps": maxbps,
        "qp_min": qp_min,
        "qp_max": qp_max,
      };
}

enum CR_CAMERA_POSITION { FRONT, BACK }

class CrCameraInfo {
  String videoName;
  String userId;
  int videoID;
  CR_CAMERA_POSITION cameraPosition;

  CrCameraInfo(
      {required this.userId,
      required this.videoID,
      required this.videoName,
      required this.cameraPosition});
}

class CrOpenVideoResult {
  String deviceID;
  bool success;

  CrOpenVideoResult({required this.deviceID, required this.success});
}

// 用户摄像头
class CrUsrVideoId {
  String userId; // 用户id
  int videoID; // 设备id // 设置成-1就可以不监听摄像头的切换, 适用于一个手机只开一个摄像头

  CrUsrVideoId({required this.userId, required this.videoID});

  Map<String, dynamic> toJson() => {"userId": userId, "videoID": videoID};
}

// 摄像头状态变化
class CrVideoStatusChanged {
  String userId; // 用户id
  CR_VSTATUS oldStatus;
  CR_VSTATUS newStatus;

  CrVideoStatusChanged(
      {required this.userId, required this.oldStatus, required this.newStatus});
}

// 麦克风状态变化
class CrAudioStatusChanged {
  String userId; // 用户id
  CR_ASTATUS oldStatus;
  CR_ASTATUS newStatus;

  CrAudioStatusChanged(
      {required this.userId, required this.oldStatus, required this.newStatus});
}

// 麦克风配置
class CrAudioCfg {
  String? micName; // 麦克风设备名称(空代表系统默认设备)
  String? speakerName; // 扬声器名称(空代表系统默认设备)
  bool? agc; // 是否开启声音增益，默认开启
  bool? ans; // 是否开启降噪，默认开启
  bool? aec; // 是否开启回声消除，默认开启

  CrAudioCfg({this.micName, this.speakerName, this.agc, this.ans, this.aec});

  Map<String, dynamic> toJson() => {
        "_micName": micName,
        "_speakerName": speakerName,
        "agc": agc,
        "ans": ans,
        "aec": aec
      };
}

// 麦克风强度（用户的说话声音）
class CrMicEnergy {
  String userId;
  int newLevel;
  int oldLevel;

  CrMicEnergy(
      {required this.userId, required this.newLevel, required this.oldLevel});
}

/*
VUNKNOWN	0	摄像头状态未知
VNULL	1	没有摄像头设备
VCLOSE	2	摄像头处于关闭状态（软开关）
VOPEN	3	摄像头处于打开状态（软开关）
VOPENING	4	向服务器发送打开消息中
*/
enum CR_VSTATUS { VUNKNOWN, VNULL, VCLOSE, VOPEN, VOPENING }

/*
AUNKNOWN	0	麦克风状态未知
ANULL	1	没有麦克风设备
ACLOSE	2	麦克风处于关闭状态（软开关）
AOPEN	3	麦克风处于打开状态（软开关）
AOPENING	4	向服务器发送打开消息中
AACCEPTING	5	向服务器发送帮助他人开麦中
*/
enum CR_ASTATUS { AUNKNOWN, ANULL, ACLOSE, AOPEN, AOPENING, AACCEPTING }

class CrMemberInfo {
  String nickName;
  String userId;
  CR_VSTATUS videoStatus;
  CR_ASTATUS audioStatus;
  CrMemberInfo(
      {required this.nickName,
      required this.userId,
      required this.videoStatus,
      required this.audioStatus});
}

// 屏幕共享配置
class CrScreenShareCfg {
  int maxBps;
  int maxFps;
  // int qp;

  CrScreenShareCfg(
      {required this.maxBps, required this.maxFps}); // , required this.qp
  Map<String, dynamic> toJson() =>
      {"maxBps": maxBps, "maxFps": maxFps}; // , "qp": qp
}

// 混图器

// 混图器规格配置
class CrMixerCfg {
  int width;
  int height;
  int frameRate; // 图像帧率，取值范围:1-30(值越大,cpu要求更高，录像推荐15帧，直播推存25帧)
  int bitRate; // 录制视频文件的最高码率，当图像变化小时，实际码率会低于此值
  int? defaultQP; // 录制视频文件的缺省质量，缺省值：26
  int?
      gop; // I帧周期(I帧越少码率越小，但直播延时会越大）； 文件录制建议15秒一个I帧取值：fpsx15； 直播建议4秒一个I帧取值: fpsx4;

  CrMixerCfg(
      {required this.width,
      required this.height,
      required this.frameRate,
      required this.bitRate,
      this.defaultQP,
      this.gop});

  Map<String, dynamic> toLocalMixJson() => {
        "dstResolution": {"width": width, "height": height},
        "frameRate": frameRate,
        "bitRate": bitRate,
        "defaultQP": defaultQP ?? 26,
        "gop": gop,
      };

  Map<String, dynamic> toRemoteMixJson() => {
        "width": width,
        "height": height,
        "frameRate": frameRate,
        "bitRate": bitRate,
        "defaultQP": defaultQP ?? 26
      };
}

// 混图器的布局
class CrMixerCotentRect {
  String? userId;
  int? camId;
  String? resId;
  String? text;
  CR_MIXER_VCONTENT_TYPE type;
  int width;
  int height;
  int top;
  int left;

  CrMixerCotentRect({
    this.userId,
    this.camId,
    this.resId,
    this.text,
    required this.type,
    required this.width,
    required this.height,
    required this.top,
    required this.left,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "camId": camId,
        "resId": resId,
        "text": text,
        "width": width,
        "height": height,
        "top": top,
        "left": left,
        "type": type.index
      };
}

// 混图器状态
// MIXER_NULL	0	没有创建
// MIXER_STARTING	1	正在开启
// MIXER_RUNNING	2	正在运行
// MIXER_ENDING	4	正在结束
enum CR_MIXER_STATE { MIXER_NULL, MIXER_STARTING, MIXER_RUNNING, MIXER_ENDING }

// 混图内容类型
enum CR_MIXER_VCONTENT_TYPE {
  MIXVTP_VIDEO, // 摄像头画面
  MIXVTP_PIC, // 图片
  MIXVTP_SCREEN, // 本地屏幕画面
  MIXVTP_MEDIA, // 影音共享
  MIXVTP_TIMESTAMP, // 时间戳
  MIXVTP_REMOTE_SCREEN, // 远端共享的屏幕
  MIXVTP_WBOARD, // 白板
  MIXVTP_TEXT, // 文本(支持简单html)
  MIXVTP_SCREEN_LOCSHARED // 本地屏幕共享的内容，没有开启共享时内容为全黑图像
}

// 混图输出类型
enum CR_MIXER_OUTPUT_TYPE { MIXOT_FILE, MIXOT_LIVE } // 录像文件, 直播流

// 混图器输出配置
class CrMixerOutPutCfg {
  CR_MIXER_OUTPUT_TYPE type;
  String?
      fileName; // 录像路径文件名（本地录像名格式如：/sdcard/1.mp4，服务器录像名格式如：/2018-11-21/1.mp4），支持的文件格式为mp4/ts/flv/avi，其中flv和ts两种格式在程序异常结束时产生的录制文件仍可用。
  int? encryptType; // 录像文件是否加密，0:不加密，1:加密；
  bool? isUploadOnRecording; // 	录像文件是否边录边传，false:不上传，true:边录边传; (此参数仅本地录像有效）
  String? serverPathFileName; // 边录边传时，上传到服务器的路径文件名； (此参数仅本地录像有效）
  String? liveUrl; // 直播推流地址，支持rtmp/rtsp
  int? errRetryTimes; // 直播推流异常时，重试次数

  CrMixerOutPutCfg({
    required this.type,
    this.fileName,
    this.encryptType,
    this.isUploadOnRecording,
    this.serverPathFileName,
    this.liveUrl,
    this.errRetryTimes,
  }) {
    encryptType = encryptType ?? 0;
    isUploadOnRecording = isUploadOnRecording ?? false;
    serverPathFileName = serverPathFileName ?? "";
    liveUrl = liveUrl ?? "";
    errRetryTimes = errRetryTimes ?? 1;
  }

  Map<String, dynamic> toJson() => {
        "type": type == CR_MIXER_OUTPUT_TYPE.MIXOT_FILE
            ? "MIXOT_FILE"
            : "MIXOT_LIVE",
        "fileName": fileName,
        "encryptType": encryptType,
        "isUploadOnRecording": isUploadOnRecording,
        "serverPathFileName": serverPathFileName,
        "liveUrl": liveUrl,
        "errRetryTimes": errRetryTimes
      };
}

// 单声道 双声道
enum CR_CHANNEL_TYPE { SINGLE_TRACK, DUAL_TRACK }
// 音频文件格式
enum CR_AUDIO_FORMAT { AAC, MP3, PCM }

// 混图器单音频配置
class CrMixerAudioCfg {
  CR_CHANNEL_TYPE channelType;
  CR_AUDIO_FORMAT audioFormat;

  CrMixerAudioCfg({required this.channelType, required this.audioFormat});

  toJson() =>
      {"channelType": channelType.index, "audioFormat": audioFormat.index};
}

// 录像类型，1：单音频录制（对应aCfg参数）  2：单视频录制（暂不支持）  3：音视频录制（对应cfg参数）
enum CR_STREAM_TYPES { AUDIO, VIDEO, AUDIOANDVIDEO }

// 混图器配置对象
class CrMutiMixerCfg {
  int id; // 混图器ID，每个混图器的配置、内容、和输出要根据ID对应
  CR_STREAM_TYPES streamTypes; // 录像类型
  CrMixerCfg? mixerCfg; // 音视频混图器配置对象
  CrMixerAudioCfg? mixerAudioCfg; // 单音频混图器配置对象

  CrMutiMixerCfg(
      {required this.id,
      required this.streamTypes,
      this.mixerCfg,
      this.mixerAudioCfg});

  toJson() {
    Map<String, dynamic> data = {"id": id};
    if (streamTypes == CR_STREAM_TYPES.AUDIO) {
      data.addAll({"streamTypes": 1, "acfg": mixerAudioCfg!.toJson()});
    } else if (streamTypes == CR_STREAM_TYPES.AUDIOANDVIDEO) {
      data.addAll({"streamTypes": 3, "cfg": mixerCfg!.toRemoteMixJson()});
    }
    return data;
  }
}

// 内容是否保持原始比例
enum CR_KEEP_ASPECT_RATIO { No_KEEP, KEEP }

// 参数配置
class CrMutiMixerContentParams {
  String? camid;
  String? text;

  CrMutiMixerContentParams({this.camid, this.text});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (camid != null) {
      data["camid"] = camid;
    }
    if (text != null) {
      data["text"] = text;
    }
    return data;
  }
}

// 混图器内容
class CrMutiMixerContent {
  CR_MIXER_VCONTENT_TYPE type; // 混图内容类型
  int left; // 该内容在混图画面中水平方向相对于最左边的位置
  int top; // 该内容在混图画面中垂直方向相对于最顶部的位置
  int width; // 该内容在混图画面中的宽度
  int height; // 该内容在混图画面中的高度
  CR_KEEP_ASPECT_RATIO? keepAspectRatio; // 内容是否保持原始比例，0：不保持  1：保持
  CrMutiMixerContentParams? mutiMixerContentParams; // 参数配置

  CrMutiMixerContent(
      {required this.type,
      required this.left,
      required this.top,
      required this.width,
      required this.height,
      this.keepAspectRatio,
      this.mutiMixerContentParams});

  toJson() {
    Map<String, dynamic> data = {
      "type": type.index,
      "left": left,
      "top": top,
      "width": width,
      "height": height
    };
    // if (width != null && height != null) {
    //   data["width"] = width;
    //   data["height"] = height;
    // }
    if (keepAspectRatio != null) {
      data["keepAspectRatio"] = keepAspectRatio?.index;
    }
    final Map<String, dynamic>? param = mutiMixerContentParams?.toJson();
    if (param != null && param.isNotEmpty) {
      data["param"] = param;
    }
    return data;
  }
}

class CrMutiMixerContents {
  int id;
  List<CrMutiMixerContent> content;

  CrMutiMixerContents({required this.id, required this.content});

  toJson() =>
      {"id": id, "content": content.map((item) => item.toJson()).toList()};
}

// 混图器输出配置对象
class CrMutiMixerOutputCfg {
  CR_MIXER_OUTPUT_TYPE type;
  String? filename;
  String? liveUrl;

  CrMutiMixerOutputCfg({required this.type, this.filename, this.liveUrl});

  toJson() {
    Map<String, dynamic> data = {"type": type.index};
    if (type == CR_MIXER_OUTPUT_TYPE.MIXOT_FILE) {
      data["filename"] = filename;
    } else {
      data["liveUrl"] = liveUrl;
    }
    return data;
  }
}

// 服务器混图输出对象
class CrMutiMixerOutput {
  int id; // 混图器ID，每个混图器的配置、内容、和输出要根据ID对应
  List<CrMutiMixerOutputCfg> mutiMixerOutputCfgs;

  CrMutiMixerOutput({required this.id, required this.mutiMixerOutputCfgs});

  toJson() => {
        "id": id,
        "output": mutiMixerOutputCfgs.map((item) => item.toJson()).toList()
      };
}

// 云端录制混图器，新接口 end

// 混图器输出状态
enum CR_MIXER_OUTPUT_STATE {
  OUTPUT_NONE, // 没有创建
  OUTPUT_CREATED, // 输出对象已创建
  OUTPUT_WRITING, // 输出目标信息更新
  OUTPUT_CLOSED, // 输出对象已关闭
  OUTPUT_ERR // 输出对象异常
}

// 录制文件、直播信息通知
class CrMixerOutputInfo {
  CR_MIXER_OUTPUT_STATE state = CR_MIXER_OUTPUT_STATE.OUTPUT_NONE;
  int duration = 0; // 录像文件时长，单位：毫秒;
  int fileSize = 0; // 录像文件大小；
  int errCode = 0; // 错误码
}

// 本地混图器状态变化通知
class CrLocMixerState {
  String mixerID;
  CR_MIXER_OUTPUT_STATE state;
  CrLocMixerState({required this.mixerID, required this.state});
}

// 云端混图器状态变化通知
class CrSvrMixerState {
  String operatorID;
  CR_MIXER_OUTPUT_STATE state;
  int sdkErr;
  CrSvrMixerState(
      {required this.operatorID, required this.sdkErr, required this.state});
}

// 录制文件上传状态
enum CR_RECORD_FILE_STATE {
  RFS_NoUpload, // 未上传
  RFS_Uploading, // 上传中
  RFS_Uploaded, // 已上传
  RFS_UploadFail // 上传失败
}

class CrRecordFileShow {
  String? fileName;
  int fileSize = 0; // 文件大小；
  CR_RECORD_FILE_STATE state = CR_RECORD_FILE_STATE.RFS_NoUpload; // 文件状态
  int uploadPercent = 0; // 录制结果中视频尺寸高度上传进度
}

// 影音播放状态
enum CR_MEDIA_STATE { MEDIA_START, MEDIA_PAUSE, MEDIA_STOP } // 开始 暂停 停止

// 影音结束原因
enum CR_MEDIA_STOP_REASON {
  MEDIA_CLOSE, // 文件关闭
  MEDIA_FINI, // 播放到文件尾部
  MEDIAMEDIA_FILEOPEN_ERR_STOP, // 打开文件失败
  MEDIA_FORMAT_ERR, // 文件格式错误
  MEDIA_UNSUPPORT, // 影音格式不支持
  MEDIA_EXCEPTION // 其他异常
}

class CrMediaFileInfo {
  int totalTime;
  int width;
  int height;

  CrMediaFileInfo(
      {required this.totalTime, required this.width, required this.height});
}

class CrMediaInfo {
  String userID;
  CR_MEDIA_STATE state;
  String mediaName;

  CrMediaInfo(
      {required this.userID, required this.state, required this.mediaName});
}

class CrMediaNotify {
  String userID;
  CR_MEDIA_STOP_REASON? reason;
  bool? pause;

  CrMediaNotify({required this.userID, this.pause, this.reason});
}

class CrChatMsg {
  String fromUserID;
  String text;

  CrChatMsg(this.fromUserID, this.text);
}
