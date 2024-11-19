import { PermissionUtil, ToastUtil } from '@pura/harmony-utils';
import sdk_engine, {
  callBackHandle,
  CRVideoSDKCallBack,
  CRVSDK_ASTATUS,
  CRVSDK_ERR_DEF,
  CRVSDK_STREAM_VIEWTYPE,
  getErrDesc,
  VideoComponent
} from '../common/RTCSDK';
import userConfig from '../common/UserConfig';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import { util } from '@kit.ArkTS';

@Builder
export function ScreenShareBuilder() {
  ScreenShare()
}

@Entry
@Component
struct ScreenShare {
  pageStack: NavPathStack = new NavPathStack;
  @State roomID: string = '';
  @State btnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State micStatus: boolean = false;
  @State startShareUserID: string | null = null;
  CallbackObj: CRVideoSDKCallBack = {
    notifyMicStatusChanged: (userID, oldStatus, newStatus, oprUserID) => {
      if (userID === userConfig.userID) {
        this.micStatus = newStatus === CRVSDK_ASTATUS.CRVSDK_AST_OPEN;
      }
    },
    notifyScreenShareStarted: (userID) => {
      console.log('notifyScreenShareStarted', userID)
      this.startShareUserID = userID
    },
    notifyScreenShareStopped: (oprUserID) => {
      console.log('notifyScreenShareStopped', oprUserID)
      this.startShareUserID = null;
    },
    // 开启屏幕共享的结果
    startScreenShareRslt: (sdkErr) => {
      console.log('startScreenShareRslt', sdkErr)
      if (sdkErr !== CRVSDK_ERR_DEF.CRVSDKERR_NOERR) {
        ToastUtil.showToast(`开启失败，错误码：${sdkErr},${getErrDesc(sdkErr)}`, { duration: 3e3 })
        this.startShareUserID = null;
        return;
      }
      this.startShareUserID = userConfig.userID
    },
    //点击系统的结束共享按钮，会进入此回调
    stopScreenShareRslt: (sdkErr) => {
      console.log('stopScreenShareRslt', sdkErr)
      this.startShareUserID = null;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.startShareUserID && this.startShareUserID !== userConfig.userID) {
          VideoComponent({
            canvas: {
              canvasId: util.generateRandomUUID(), //视图id
              type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_SCREEN //视图类型
            }
          }).height('100%')
        } else {
          Stack({ alignContent: Alignment.Center }) {
            Column({ space: 8 }) {
              Text(`房间号：${this.roomID}`)
                .fontColor(Color.White)
              Text(`用户名：${userConfig.nickName}`)
                .fontColor(Color.White)
              Text(`分辨率：720P`)
                .fontColor(Color.White)
              Text(`等待其他成员发起屏幕共享`)
                .fontColor(Color.White)
            }
            .alignItems(HorizontalAlign.Start)
            .width('80%')
            .height('100%')
            .padding({ top: 60 })

            CustomButton({
              text: this.startShareUserID === userConfig.userID ? '停止屏幕共享' : '开始屏幕共享',
              w: 200,
              h: 80,
              modifier: this.btnModifier,
              click: () => {
                if (this.startShareUserID === userConfig.userID) {
                  this.startShareUserID = null;
                  sdk_engine.stopScreenShare();
                } else {
                  this.startShareUserID = userConfig.userID;
                  sdk_engine.startScreenShare();
                }
              }
            })
          }
          .height('100%')
        }

        CustomButton({
          text: `${this.micStatus ? '关闭' : '开启'}麦克风`,
          w: 130,
          h: 40,
          modifier: this.btnModifier,
          click: () => {
            if (this.micStatus) {
              sdk_engine.closeMic(userConfig.userID);
            } else {
              sdk_engine.openMic(userConfig.userID);
            }
            this.micStatus = !this.micStatus
          }
        })
          .margin({ bottom: 10 })
      }
      .height('100%')
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .backgroundColor('#333')
    .onReady(async (context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;
      callBackHandle(this.CallbackObj) //销毁回调函数

      sdk_engine.setSpeakerOut(true) //设置外放
      const shareInfo = sdk_engine.getScreenShareInfo() //获取当前屏幕共享状态
      if (shareInfo.state === 1) {
        this.startShareUserID = shareInfo.sharerUserID
      }

      const bool = await PermissionUtil.requestPermissionsEasy(['ohos.permission.MICROPHONE'])
      if (bool) {
        sdk_engine.openMic(userConfig.userID) //打开我的麦克风
        this.micStatus = true;
      }
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}