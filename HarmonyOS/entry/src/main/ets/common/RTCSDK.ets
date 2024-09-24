import { RandomUtil } from '@pura/harmony-utils';
import {
  CR_LIB_NAME,
  CRUserVideoID,
  CRVideoSDKCallBack,
  CRVideoSDKEx,
  CRVSDK_SCALE_MODE,
  CRVSDK_STREAM_VIEWTYPE,
  CRVSDK_VSTATUS,
  CRVSDK_VSTEAMLV_TYPE
} from '@cloudroom/hormony_rtcsdk';
import { MemberInfo } from './Default';

const cacheDir = getContext().getApplicationContext().cacheDir;

let sdk_engine = CRVideoSDKEx.create(cacheDir, JSON.stringify({
  Timeout: 120000, //网络通信超时时间，单位是毫秒，取值范围：10000-120000, 缺省值:60000(60秒)
}));

export default sdk_engine;

export * from '@cloudroom/hormony_rtcsdk'

// 注册和销毁SDK回调函数
export const callBackHandle = (CallbackObj: CRVideoSDKCallBack, isDestory: boolean = false) => {
  Object.keys(CallbackObj).forEach((item: string) => {
    const key = item as keyof CRVideoSDKCallBack;
    if (isDestory) {
      sdk_engine.off(key, CallbackObj[key]);
    } else {
      sdk_engine.on(key, CallbackObj[key]);
    }
  })
}

export const getErrDesc = (err: number): string => {
  const map = new Map<number, string>([
    [0, "没有错误"],
    [-1, "ipcam url不正确"],
    [-2, "已存在"],
    [-3, "添加太多"],
    [-4, "不支持的格式"],
    [-5, "无效的屏幕id"],
    [1, "未知错误"],
    [2, "内存不足"],
    [3, "sdk内部错误"],
    [4, "不支持的sdk版本"],
    [5, "参数错误"],
    [6, "无效数据"],
    [7, "帐号密码不正确"],
    [8, "服务异常"],
    [9, "登录状态错误"],
    [10, "帐号在别处被使用"],
    [11, "sdk未初始化"],
    [12, "还没有登录"],
    [13, "base64转换失败"],
    [14, "启用了第三方鉴权，但没有携带鉴权信息"],
    [15, "没有启用第三方鉴权，但携带了鉴权信息"],
    [16, "访问第三方鉴权服务异常"],
    [17, "第三方鉴权不通过"],
    [18, "token已过期"],
    [19, "鉴权信息错误"],
    [20, "appid不存在"],
    [21, "鉴权失败"],
    [22, "非token鉴权方式"],
    [23, "没有api访问权限"],
    [24, "账号已过期"],
    [25, "所有终端未授权"],
    [26, "sip/h323终端未授权"],
    [27, "IPC终端未授权"],
    [28, "当前使用的终端平台未授权"],
    [29, "不支持当前使用的终端平台"],
    [200, "网络初始化失败"],
    [201, "没有服务器信息"],
    [202, "服务器没有响应"],
    [203, "创建连接失败"],
    [204, "socket异常"],
    [205, "网络超时"],
    [206, "连接被关闭"],
    [207, "连接丢失"],
    [208, "语音引擎初始化失败"],
    [209, "ssl通信错误"],
    [210, "响应数据不正确"],
    [211, "数据加密失败"],
    [212, "数据加密失败"],
    [400, "队列ID错误"],
    [401, "没有用户在排队"],
    [402, "排队用户已取消"],
    [403, "队列服务还未开启"],
    [404, "已在其它队列排队(客户只能在一个队列排队)"],
    [600, "无效的呼叫ID"],
    [601, "已在呼叫中"],
    [602, "对方忙"],
    [603, "对方不在线"],
    [604, "对方无应答"],
    [605, "用户不存在"],
    [606, "对方拒接"],
    [800, "房间不存在或已结束"],
    [801, "房间密码不正确"],
    [802, "房间终端数量已满（购买的license不够)"],
    [803, "分配房间资源失败"],
    [804, "房间已加锁"],
    [805, "余额不足"],
    [806, "业务权限未开启"],
    [807, "不能再次进入房间"],
    [808, "没有mic权限"],
    [809, "mic已被使用"],
    [810, "mic未知错误"],
    [811, "没有扬声器权限"],
    [812, "扬声器已被使用"],
    [813, "扬声器未知错误"],
    [814, "图像为空"],
    [815, "设备不存在"],
    [816, "开麦达到上限"],
    [817, "还没有进入房间"],
    [818, "数据重复 或 功能重复开启失败"],
    [819, "直播观众用户数量已满（购买的直播观众用户不够)"],
    [820, "sip用户数量已满（购买的sip用户数不够)"],
    [821, "ipc用户数量已满（购买的ipc用户数不够)"],
    [900, "抓屏失败"],
    [901, "单次录制达到最大时长(8h)"],
    [902, "磁盘空间不够"],
    [903, "录制尺寸超出了允许值"],
    [904, "录制超出限制"],
    [905, "录制文件操作出错"],
    [906, "录制已开启"],
    [907, "录制服务器资源不足"],
    [908, "云端录像空间已满"],
    [1000, "发送失败"],
    [1001, "有敏感词语"],
    [1100, "发送信令数据过大"],
    [1101, "发送数据过大"],
    [1102, "目标用户不存在"],
    [1103, "文件错误"],
    [1104, "无效的发送id"],
    [1200, "状态错误不可上传/取消上传"],
    [1201, "录制文件不存在"],
    [1202, "上传失败，失败原因参考日志"],
    [1203, "移除本地文件失败"],
    [1400, "文件不存在"],
    [1401, "文件读失败"],
    [1402, "文件写失败"],
    [1403, "目标文件已存在"],
    [1404, "文件操作失败"],
    [1405, "不支持的文件尺寸"],
    [1500, "网盘不存在"],
    [1501, "没有网盘权限"],
    [1502, "不合法文件名"],
    [1503, "文件已存在"],
    [1504, "文件或目录不存在"],
    [1505, "文件没有转换"],
    [1506, "文件转换失败"],
    [1507, "空间不足"],
  ]);
  return map.get(err) || '未知错误';
}

@Component
export struct VideoComponent {
  viewId: string = RandomUtil.generateUUID32(); //视图id
  @Prop member?: MemberInfo; //成员信息
  @Prop type: CRVSDK_STREAM_VIEWTYPE; //视图类型
  @Prop videoId?: CRUserVideoID; //用户视频id
  @Prop videoLv?: CRVSDK_VSTEAMLV_TYPE; //视频流等级
  @Prop showName?: boolean = true; //显示呢称

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      XComponent({ id: this.viewId, type: XComponentType.SURFACE, libraryname: CR_LIB_NAME })
        .onLoad((xComponentContext) => {
          sdk_engine.addCanvas({
            viewId: this.viewId,
            type: this.type,
            videoId: this.videoId,
            videoLv: this.videoLv,
            showMode: CRVSDK_SCALE_MODE.CRVSDK_RENDERMD_FIT
          });
        })
        .onDestroy(() => {
          sdk_engine.rmCanvas(this.viewId)
        })

      if (this.member) {
        if (this.member.videoStatus !== CRVSDK_VSTATUS.CRVSDK_VST_OPEN) {
          Text('摄像头未开启')
            .width("100%")
            .height('100%')
            .backgroundColor('#99000000')
            .fontSize(12)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        if (this.showName) {
          Text(this.member.nickName)
            .fontSize(8)
            .fontColor(Color.White)
            .margin({ top: 2, left: 2, right: 2 })
            .padding(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .borderRadius(3)
            .backgroundColor('#55000000')
        }
      }
    }
  }
}