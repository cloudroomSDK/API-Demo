import { DateUtil, DialogUtil, PermissionUtil, ToastUtil } from '@pura/harmony-utils';
import sdk_engine, {
  callBackHandle,
  CRCloudMixerCfgObj_MixMode,
  CRMixerContentObj,
  CRVideoSDKCallBack,
  CRVSDK_CLOUDMIXER_OUTPUT_STATE,
  CRVSDK_ERR_DEF,
  CRVSDK_MIXER_CONTENT_TYPE,
  CRVSDK_MIXER_STATE,
  CRVSDK_SCALE_MODE,
  CRVSDK_STREAM_VIEWTYPE,
  CRVSDK_VSTATUS,
  getErrDesc,
  VideoComponent
} from '../common/RTCSDK';
import { MemberInfo } from '../common/Default';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import userConfig from '../common/UserConfig';
import { JSON, util } from '@kit.ArkTS';

@Builder
export function CloudRecordBuilder() {
  CloudRecord()
}

interface Err {
  err: CRVSDK_ERR_DEF
  errDesc: string
}

@Entry
@Component
struct CloudRecord {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State recordBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State filename: string = '';
  @State memberList: MemberInfo[] = []
  @State state: CRVSDK_MIXER_STATE = CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL
  mixerID: string | null = null;
  lastMixerID: string = '';
  mixerCfgObj?: CRCloudMixerCfgObj_MixMode;
  CallbackObj: CRVideoSDKCallBack = {
    notifyUserLeftMeeting: (userID) => {
      console.log(`left ${userID}`)
      const idx = this.memberList.findIndex(item => item.userId === userID);
      if (idx > -1) {
        this.memberList.splice(idx, 1)
      }
      this.updateMixer();
    },
    notifyUserEnterMeeting: (userID) => {
      console.log(`enter ${userID}`)
      const userInfo = sdk_engine.getMemberInfo(userID)

      this.memberList.push(new MemberInfo(userInfo))
      this.updateMixer();
    },
    notifyVideoStatusChanged: (userID, oldStatus, newStatus, oprUserID) => {
      const idx = this.memberList.findIndex(item => item.userId === userID)
      if (idx > -1) {
        this.memberList[idx].videoStatus = newStatus
      }
      this.updateMixer();
    },
    createCloudMixerFailed: (mixerID: string, sdkErr: CRVSDK_ERR_DEF) => {
      DialogUtil.showConfirmDialog({
        title: "启动失败",
        message: `错误码: ${sdkErr},${getErrDesc(sdkErr)}`,
        confirm: {
          value: "确定",
          action: () => {
          }
        }
      })
    },
    // 通知云端录制/推流状态变化
    notifyCloudMixerStateChanged: (mixerID, state, exParam, operUserId) => {
      if (this.mixerID === mixerID) {
        this.state = state;

        if (state === CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL) {
          this.recordBtnModifier.type = 'primary'
          this.mixerID = null;
          if (exParam) {
            const errObj = JSON.parse(exParam) as Err;
            DialogUtil.showConfirmDialog({
              title: "启动失败",
              message: `错误码: ${errObj.err},${errObj.errDesc}`,
              confirm: {
                value: "确定",
                action: () => {
                }
              }
            })
          }
        } else if (state === CRVSDK_MIXER_STATE.CRVSDK_MIXER_RUNNING) {
          this.recordBtnModifier.type = 'danger'
        }
      }
    },
    // 通知云端录制/推流输出信息变化
    notifyCloudMixerOutputInfoChanged: (mixerID, outputInfo) => {
      if (mixerID === this.lastMixerID) {
        if (
          outputInfo.state === CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_FAIL ||
            outputInfo.state === CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADFAIL
        ) {
          DialogUtil.showConfirmDialog({
            title: "云端任务输出错误",
            message: `状态码: ${outputInfo.state},错误码: ${outputInfo.errCode},${outputInfo.errDesc}`,
            confirm: {
              value: "确定",
              action: () => {
              }
            }
          })
        } else if (outputInfo.state === CRVSDK_CLOUDMIXER_OUTPUT_STATE.CRVSDK_CLOUDMO_UPLOADED) {
          ToastUtil.showToast('录制完成，前往SDK后台可查看录像', {
            duration: 5e3
          })
        }
      }
    }
  }

  createMixerContentList(): CRMixerContentObj[] {
    // 过滤掉没开摄像头的成员，同时过滤自己，自己的摄像头单独处理
    const memberList = Array.from(this.memberList)
      .filter(member => member.userId !== userConfig.userID && member.videoStatus === CRVSDK_VSTATUS.CRVSDK_VST_OPEN)

    // 小宫格最多录制9人
    if (memberList.length > 9) {
      memberList.length = 9
    }

    const list: CRMixerContentObj[] = [];
    list.push({
      left: 0, //	在混图画面中的区域（水平位置）
      top: 0, //	在混图画面中的区域（垂直位置）
      width: 720, //	在混图画面中的区域宽
      height: 1280, //	在混图画面中的区域高
      type: CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_VIDEO, //	CRVSDK_MIXER_CONTENT_TYPE,请见后面type描述;
      keepAspectRatio: 1, //	内容保持原始比例，0不保持，1保持
      param: {
        camid: `${userConfig.userID}.-1`
      }
    })

    memberList.forEach((item, idx) => {
      const w = 225, h = 400;
      const x = parseInt((idx / 3).toString())
      const y = idx % 3;
      list.push({
        left: 720 - ((w + 10) * (x + 1)), //	在混图画面中的区域（水平位置）
        top: h * y + 10 * (y + 1), //	在混图画面中的区域（垂直位置）
        width: 225, //	在混图画面中的区域宽
        height: h, //	在混图画面中的区域高
        type: CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_VIDEO, //	CRVSDK_MIXER_CONTENT_TYPE,请见后面type描述;
        keepAspectRatio: 1, //	内容保持原始比例，0不保持，1保持
        param: {
          camid: `${item.userId}.-1`
        }
      })
    })

    list.push({
      left: 400, //	在混图画面中的区域（水平位置）
      top: 1200, //	在混图画面中的区域（垂直位置）
      width: 100, //	在混图画面中的区域宽
      height: 100, //	在混图画面中的区域高
      type: CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_TEXT,
      keepAspectRatio: 1, //	内容保持原始比例，0不保持，1保持
      param: {
        text: `%timestamp%`,
        color: "#000000", //文本颜色，格式：#RRGGBB[AA]， 默认#FFFFFF
        background: "#ffffff", //背景色，格式：#RRGGBB[AA]， 默认#0000007D
      }
    })
    list.push({
      left: 100, //	在混图画面中的区域（水平位置）
      top: 100, //	在混图画面中的区域（垂直位置）
      width: 100, //	在混图画面中的区域宽
      height: 100, //	在混图画面中的区域高
      type: CRVSDK_MIXER_CONTENT_TYPE.CRVSDK_MIXCONT_TEXT,
      keepAspectRatio: 1, //	内容保持原始比例，0不保持，1保持
      param: {
        text: `测试`,
        color: "#000000", //文本颜色，格式：#RRGGBB[AA]， 默认#FFFFFF
        background: "#ffffff", //背景色，格式：#RRGGBB[AA]， 默认#0000007D
        "font-size": 18, //字体大小，默认18
        "text-margin": 5 //边距，默认5
      }
    })
    return list;
  }

  createMixer() {
    const curTime = new Date();
    const dir = DateUtil.getFormatDateStr(curTime, 'yyyy-MM-dd')
    const firstName = DateUtil.getFormatDateStr(curTime, 'yyyy-MM-dd_HH-mm-ss')
    this.filename = `${firstName}_HarmonyOS_${this.roomID}.mp4`;

    let mixerCfgObj: CRCloudMixerCfgObj_MixMode = {
      mode: 0, //合流模式
      videoFileCfg: {
        svrPathName: `/${dir}/${this.filename}`, //带路径的文件名，文件格式支持：mp4、flv、ts、avi、rtmp://、rtsp://，可选一个或多个，以“;”分隔；示例：”/xxx/xxx.mp4;rtmp://xxx1;rtmp://xxx2;”
        vWidth: 720, //视频宽度
        vHeight: 1280, //视频高度
        // vFps?: number //视频帧率，取值0-30, 默认值12
        // vBps?: number //视频码率，取值参见视频流默认码率定义 默认会根据视频尺寸生成码率
        // vQP?: number //视频质量，取值0~51(0表示完全无损, 51表示质量非常差)，推荐高质量取值18，中质量25，低质量34， 默认值19
        // aChannelType?: number //音频通道类型，取值：0-单声道，1-左右双声道，默认为0
        // aChannelContent?: string[] //音频通道内容。
        layoutConfig: this.createMixerContentList() //布局内容列表
      }
    }

    this.mixerID = sdk_engine.createCloudMixer(mixerCfgObj)
    this.mixerCfgObj = mixerCfgObj;
    this.lastMixerID = this.mixerID
    this.state = CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING;
  }

  updateMixer() {
    if (this.recordBtnModifier.type === 'danger') {
      const mixerContentList = this.createMixerContentList();
      if (this.mixerCfgObj?.videoFileCfg?.layoutConfig) {
        this.mixerCfgObj.videoFileCfg.layoutConfig = mixerContentList;
        sdk_engine.updateCloudMixerContent(this.mixerID, this.mixerCfgObj)
      }
    }
  }

  stopMixer() {
    sdk_engine.destroyCloudMixer(this.mixerID)
    this.state = CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING;
    this.mixerCfgObj = undefined;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.TopEnd }) {
          VideoComponent({
            member: this.memberList.find(item => item.userId === userConfig.userID),
            showName: false,
            canvas: {
              canvasId: util.generateRandomUUID(), //视图id
              type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO, //视图类型
              videoId: { userID: userConfig.userID, videoID: -1 },
              showMode: CRVSDK_SCALE_MODE.CRVSDK_RENDERMD_FILL
            }
          })
            .width('100%')
            .height('100%')

          Grid() {
            ForEach(this.memberList.filter(item => item.userId !== userConfig.userID), (member: MemberInfo) => {
              GridItem() {
                VideoComponent({
                  member: member,
                  canvas: {
                    canvasId: util.generateRandomUUID(), //视图id
                    type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO, //视图类型
                    videoId: { userID: member.userId, videoID: -1 },
                  }
                })
                  .width('33.3333%')
                  .aspectRatio(1)
                  .borderRadius(8)
                  .clip(true)
              }
            }, (item: MemberInfo) => item.userId)
          }
          .layoutDirection(GridDirection.Column)
          .columnsGap(10)
          .rowsGap(10)
          .maxCount(3)
          .padding(10)
        }
        .width('100%')
        .height('100%')

        Column({ space: 10 }) {
          Text('文件名')
            .fontColor(Color.White)
            .width('100%')
          Row({ space: 10 }) {
            TextInput({
              text: this.filename
            })
              .enabled(false)
              .backgroundColor('#ccc')
              .borderRadius(5)
              .layoutWeight(1)
            CustomButton({
              text: ['开始录制', '启动中...', '结束录制', undefined, '停止中'][this.state],
              disabled: this.state === CRVSDK_MIXER_STATE.CRVSDK_MIXER_STARTING ||
                this.state === CRVSDK_MIXER_STATE.CRVSDK_MIXER_STOPPING,
              h: 40,
              modifier: this.recordBtnModifier,
              click: () => {
                if (this.state === CRVSDK_MIXER_STATE.CRVSDK_MIXER_NULL) {
                  this.createMixer();
                } else {
                  this.stopMixer();
                }
              }
            })
          }
        }
        .width('100%')
        .backgroundColor("#55000000")
        .padding({
          top: 25,
          left: 25,
          right: 25,
          bottom: 10
        })
      }
      .backgroundColor($r('app.color.videoBg'))
      .width('100%')
      .height('100%')

    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .onReady(async (context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;
      callBackHandle(this.CallbackObj) //销毁回调函数

      sdk_engine.setSpeakerOut(true) //设置外放

      const memberList = sdk_engine.getAllMembers()
      this.memberList = memberList.map(member => new MemberInfo(member))


      const bool = await PermissionUtil.requestPermissionsEasy(['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
      if (bool) {
        const cfg = sdk_engine.getVideoCfg()
        cfg.size = "1280*720"
        cfg.maxbps = 1000 * 1000
        sdk_engine.setVideoCfg(cfg)
        sdk_engine.openVideo(userConfig.userID) //打开我的摄像头
        sdk_engine.openMic(userConfig.userID) //打开我的麦克风
      }
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}