import { ExampleType } from '../common/Default';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import { InputItem } from '../components/InputItem';
import { PermissionUtil, PreferencesUtil, ToastUtil } from '@pura/harmony-utils';
import sdk_engine, { callBackHandle, CRVideoSDKCallBack, CRVSDK_ERR_DEF, getErrDesc } from '../common/RTCSDK';
import Loading from '../components/Loading';

@Builder
export function JoinBuilder() {
  Join()
}

@Entry
@Component
struct Join {
  pageStack: NavPathStack = new NavPathStack();
  @State title: ExampleType = ExampleType.AudioCall
  @State roomID: string = '';
  @State createBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary', true);

  async enterMeeting(roomID: string) {
    await PermissionUtil.requestPermissionsEasy(['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
    Loading.show()
    PreferencesUtil.put('roomID', roomID)
    sdk_engine.enterMeeting(Number(roomID))
  }

  CallbackObj: CRVideoSDKCallBack = {
    createMeetingSuccess: (roomID) => {
      this.roomID = String(roomID)
      this.enterMeeting(this.roomID)
    },
    createMeetingFail: (sdkErr) => {
      Loading.hide()
      ToastUtil.showToast(`创建房间失败，错误码：${sdkErr},${getErrDesc(sdkErr)}`, { duration: 3e3 })
    },
    enterMeetingRslt: (sdkErr) => {
      Loading.hide()
      if (sdkErr !== CRVSDK_ERR_DEF.CRVSDKERR_NOERR) {
        ToastUtil.showToast(`进入房间失败，错误码：${sdkErr},${getErrDesc(sdkErr)}`, { duration: 3e3 })
        return;
      }
      if (this.title === ExampleType.AudioCall) {
        this.pageStack.pushPathByName('AudioCall', this.roomID)
      } else if (this.title === ExampleType.VideoCall) {
        this.pageStack.pushPathByName('VideoCall', this.roomID)
      } else if (this.title === ExampleType.VideoSetting) {
        this.pageStack.pushPathByName('VideoSetting', this.roomID)
      } else if (this.title === ExampleType.ScreenShare) {
        this.pageStack.pushPathByName('ScreenShare', this.roomID)
      } else if (this.title === ExampleType.LocalRecord) {
        this.pageStack.pushPathByName('LocalRecord', this.roomID)
      } else if (this.title === ExampleType.CloudRecord) {
        this.pageStack.pushPathByName('CloudRecord', this.roomID)
      } else if (this.title === ExampleType.MediaShare) {
        this.pageStack.pushPathByName('MediaShare', this.roomID)
      } else if (this.title === ExampleType.Chat) {
        this.pageStack.pushPathByName('Chat', this.roomID)
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        InputItem({
          type: InputType.Number,
          text: '请输入房间号：',
          value: this.roomID,
        }).margin({ bottom: 40 })

        CustomButton({
          text: '进入房间',
          w: "100%",
          h: 48,
          click: () => {
            if (!/^[1-9]\d{7}$/.test(this.roomID)) {
              AlertDialog.show({
                message: '房间号不正确，请输入正确的房间号'
              })
              return;
            }
            this.enterMeeting(this.roomID);
          }
        })
        Row() {
          Divider().strokeWidth(1).color('#D0D0D0')
            .layoutWeight(1)
            .margin({ right: 30 })

          Text('或者').fontColor('#888').fontSize(14)
          Divider().strokeWidth(1).color('#D0D0D0')
            .layoutWeight(1)
            .margin({ left: 30 })
        }.margin({ top: 30, bottom: 30 })

        CustomButton({
          text: '创建房间',
          w: "100%",
          h: 48,
          modifier: this.createBtnModifier,
          click: () => {
            sdk_engine.createMeeting()
          }
        })
      }
      .backgroundColor(Color.White)
      .margin({ top: 10 })
      .padding({
        left: 40,
        right: 40,
        top: 30,
        bottom: 30
      })
    }
    .title(this.title, {
      backgroundColor: Color.White,
    })
    .backgroundColor($r("app.color.bg"))
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.title = context.pathInfo.param as ExampleType;
      this.roomID = PreferencesUtil.getSync('roomID', '') as string;

      callBackHandle(this.CallbackObj); //注册回调函数
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
    })
  }
}