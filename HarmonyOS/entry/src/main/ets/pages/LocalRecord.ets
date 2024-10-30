import {
  DateUtil,
  DialogUtil,
  FileUtil,
  PermissionUtil,
  PhotoHelper,
  ToastUtil
} from '@pura/harmony-utils';
import sdk_engine, {
  callBackHandle,
  CRLocMixerCfgObj,
  CRLocMixerOutputObj,
  CRMixerContentObj,
  CRVideoSDKCallBack,
  CRVSDK_ERR_DEF,
  CRVSDK_LOCMIXER_OUTPUT_STATE,
  CRVSDK_MIXER_CONTENT_TYPE,
  CRVSDK_MIXER_OUTPUT_TYPE,
  CRVSDK_SCALE_MODE,
  CRVSDK_STREAM_VIEWTYPE,
  CRVSDK_VSTATUS,
  getErrDesc,
  VideoComponent
} from '../common/RTCSDK';
import { MemberInfo } from '../common/Default';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import userConfig from '../common/UserConfig';
import { util } from '@kit.ArkTS';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function LocalRecordBuilder() {
  LocalRecord()
}

@Entry
@Component
struct LocalRecord {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State recordBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State writeBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State filename: string = '';
  fileDir: string = getContext().getApplicationContext().tempDir;
  @State lastFilePath: string = '';
  @State memberList: MemberInfo[] = []
  mixerID: string = util.generateRandomUUID();
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
    notifyLocMixerOutputInfo: (mixerID, nameOrUrl, outputInfo) => {
      if (outputInfo.state === CRVSDK_LOCMIXER_OUTPUT_STATE.CRVSDK_LOCMO_STOPPED) {
        this.lastFilePath = nameOrUrl;
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
        text: `%timestamp%`
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
    const cfgObj: CRLocMixerCfgObj = {
      width: 720,
      height: 1280,
      frameRate: 15,
      bitRate: 2000000,
      defaultQP: 25,
      gop: 225
    }
    const mixerContentList = this.createMixerContentList();
    const sdkErr = sdk_engine.createLocMixer(this.mixerID, cfgObj, mixerContentList)
    if (sdkErr !== CRVSDK_ERR_DEF.CRVSDKERR_NOERR) {
      DialogUtil.showConfirmDialog({
        title: "启动失败",
        message: `错误码: ${sdkErr},${getErrDesc(sdkErr)}`,
        confirm: {
          value: "确定",
          action: () => {
          }
        }
      })
      return;
    }


    const time = DateUtil.getFormatDateStr(new Date(), 'yyyy-MM-dd_HH-mm-ss')
    this.filename = `${time}_HarmonyOS_${this.roomID}.mp4`;
    const filePath = `${this.fileDir}/${this.filename}`;
    this.lastFilePath = '';
    const mixerOutput: CRLocMixerOutputObj[] = [{
      type: CRVSDK_MIXER_OUTPUT_TYPE.CRVSDK_MIXER_OUTPUT_FILE,
      filename: filePath
    }]
    const sdkErr2 = sdk_engine.addLocMixerOutput(this.mixerID, mixerOutput)
    if (sdkErr2 !== CRVSDK_ERR_DEF.CRVSDKERR_NOERR) {
      DialogUtil.showConfirmDialog({
        title: "启动失败",
        message: `错误码: ${sdkErr2},${getErrDesc(sdkErr2)}`,
        confirm: {
          value: "确定",
          action: () => {
          }
        }
      })
      return;
    }

    this.recordBtnModifier.type = 'danger'
  }

  updateMixer() {
    if (this.recordBtnModifier.type === 'danger') {
      const mixerContentList = this.createMixerContentList();
      sdk_engine.updateLocMixerContent(this.mixerID, mixerContentList)
    }
  }

  stopMixer() {
    sdk_engine.rmLocMixerOutput(this.mixerID, `${this.fileDir}/${this.filename}`);
    sdk_engine.destroyLocMixer(this.mixerID)
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
          }

          Row({ space: 10 }) {
            CustomButton({
              text: this.recordBtnModifier.type === 'primary' ? '开始录制' : '结束录制',
              w: "100%",
              h: 40,
              modifier: this.recordBtnModifier,
              click: () => {
                if (this.recordBtnModifier.type === 'primary') {
                  this.createMixer();
                } else {
                  this.stopMixer();
                  this.recordBtnModifier.type = 'primary';
                }
              }
            })
              .layoutWeight(1)
            CustomButton({
              text: '保存到相册',
              w: "100%",
              h: 40,
              modifier: this.writeBtnModifier,
              disabled: !this.lastFilePath,
              click: async () => {
                if (await PermissionUtil.requestPermissionsEasy(['ohos.permission.WRITE_IMAGEVIDEO'])) {
                  PhotoHelper.save(photoAccessHelper.PhotoType.VIDEO, 'mp4',
                    { title: this.filename.replace('.mp4', '') })
                    .then(async (uri) => {
                      if (uri) {
                        let file = FileUtil.openSync(uri);
                        FileUtil.copyFile(this.lastFilePath, file.fd).then(() => {
                          FileUtil.close(file.fd);
                          ToastUtil.showToast("保存成功");
                        })
                      }
                    })
                    .catch((err: BusinessError) => {
                      ToastUtil.showLong("保存异常")
                    })
                }
              }
            })
              .layoutWeight(1)
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