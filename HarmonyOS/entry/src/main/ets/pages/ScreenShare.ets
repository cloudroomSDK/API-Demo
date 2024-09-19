import { PermissionUtil, ToastUtil } from '@pura/harmony-utils';
import sdk_engine, {
  callBackHandle,
  CRVideoSDKCallBack,
  CRVSDK_ASTATUS,
  CRVSDK_STREAM_VIEWTYPE,
  VideoComponent
} from '../common/RTCSDK';
import userConfig from '../common/UserConfig';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';

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
    notifyScreenShareStarted: (userID: string) => {
      this.startShareUserID = userID
    },
    notifyScreenShareStopped: (oprUserID: string) => {
      this.startShareUserID = null;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.startShareUserID) {
          VideoComponent({
            type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_SCREEN
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
              text: '开始屏幕共享',
              w: 200,
              h: 80,
              modifier: this.btnModifier,
              click: () => {
                ToastUtil.showToast('当前版本仅支持屏幕共享观看')
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