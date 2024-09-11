import sdk_engine, { callBackHandle, CRVideoSDKCallBack } from '../common/CRSDK';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import UserConfig from '../common/UserConfig';
import { PermissionUtil, ToastUtil } from '@pura/harmony-utils';


@Builder
export function AudioCallBuilder() {
  AudioCall()
}


@Component
struct progressItem {
  @Prop text: string = '';
  @Prop value: number = 0;

  build() {

    Column({ space: 6 }) {
      Text(this.text)
        .fontColor(Color.White)
      Progress({ value: this.value, type: ProgressType.Linear, total: 10 })
        .color('#09db00')
        .backgroundColor('#373f50')
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
struct AudioCall {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State closeBtnModifier: CustomButtonModifier = new CustomButtonModifier('danger')
  @State btnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State remoteValue: number = 0
  @State localValue: number = 0
  @State isOpenMic: boolean = false //麦克风状态
  @State useLoudspeaker: boolean = true //使用扬声器状态
  CallbackObj: CRVideoSDKCallBack = {
    notifyMicEnergy: (userID, oldLevel, newLevel) => {
      if (UserConfig.userID === userID) {
        this.localValue = newLevel
      } else {
        this.remoteValue = newLevel
      }
    },
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 40 }) {
          Image($r('app.media.audioCallBg'))
            .width('100%')
          Column({ space: 14 }) {
            progressItem({
              text: '本地用户',
              value: this.localValue
            });
            progressItem({
              text: '远端用户',
              value: this.remoteValue
            });
          }
          .width('60%')
          .borderRadius(5)
          .backgroundColor(Color.Black)
          .padding(20)
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Column({ space: 10 }) {
          Row({ space: 10 }) {
            CustomButton({
              text: `${this.isOpenMic ? '关闭' : '打开'}麦克风`,
              w: 150,
              h: 40,
              modifier: this.btnModifier,
              click: async () => {
                if (this.isOpenMic) {
                  sdk_engine.closeMic(UserConfig.userID);
                  this.isOpenMic = false
                } else if (await PermissionUtil.requestPermissionsEasy('ohos.permission.MICROPHONE')) { //动态授权
                  sdk_engine.openMic(UserConfig.userID);
                  this.isOpenMic = true
                } else {
                  ToastUtil.showToast('没有权限')
                }
              }
            })
            CustomButton({
              text: `切换${this.useLoudspeaker ? '听筒' : '扬声器'}`,
              w: 150,
              h: 40,
              modifier: this.btnModifier,
              click: () => {
                this.useLoudspeaker = !this.useLoudspeaker;
                sdk_engine.setSpeakerOut(this.useLoudspeaker)
              }
            })
          }

          CustomButton({
            text: '挂断',
            w: 100,
            h: 40,
            modifier: this.closeBtnModifier,
            click: () => {
              this.pageStack.pop()
            }
          })
        }
        .width('100%')
        .backgroundColor("#55000000")
        .padding({ top: 25, left: 25, right: 25 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .backgroundColor($r('app.color.videoBg'))

      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;

      this.useLoudspeaker = sdk_engine.getSpeakerOut()
      callBackHandle(this.CallbackObj); //销毁回调函数
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}