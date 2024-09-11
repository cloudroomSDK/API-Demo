import { ExampleType } from '../common/Default';
import { CustomButton } from '../components/CustomButton';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import sdk_engine, {
  callBackHandle,
  CRVideoSDKCallBack,
  CRVideoSDKEx,
  CRVSDK_AUTHTYPE,
  CRVSDK_ERR_DEF,
  CRVSDK_WEBPROTOCOL,
  getErrDesc
} from '../common/CRSDK';
import loginConfig from '../common/LoginConfig';
import userConfig from '../common/UserConfig';
import { MD5, ToastUtil } from '@pura/harmony-utils';

@Builder
export function LoginBuilder() {
  Login()
}

interface PopResult {
  needResetLogin: boolean
}

@Entry
@Component
struct Login {
  pageStack: NavPathStack = new NavPathStack();
  @State isLogin: boolean = false;
  @State sdkVersion: string = ''
  loginTimer?: number;
  CallbackObj: CRVideoSDKCallBack = {
    loginRslt: (sdkErr) => {
      if (sdkErr !== CRVSDK_ERR_DEF.CRVSDKERR_NOERR) {
        ToastUtil.showToast(`登录失败，错误码：${sdkErr},${getErrDesc(sdkErr)}`, { duration: 3e3 })
        this.loginTimer = setTimeout(this.login, 10e3);
        return;
      }
      this.isLogin = true;
    },
  }

  login() {
    sdk_engine.login({
      _sdkAuthType: loginConfig.useToken ? CRVSDK_AUTHTYPE.CRVSDK_AUTHTP_TOKEN : CRVSDK_AUTHTYPE.CRVSDK_AUTHTP_SECRET,
      _appID: loginConfig.AppID,
      _md5_appSecret: MD5.digestSync(loginConfig.AppSecret),
      _token: loginConfig.Token,
      _serverAddr: loginConfig.addr,
      _userID: userConfig.userID,
      _nickName: userConfig.nickName,
      _webProtocol: loginConfig.useHTTPS ? CRVSDK_WEBPROTOCOL.CRVSDK_WEBPTC_HTTPS :
      CRVSDK_WEBPROTOCOL.CRVSDK_WEBPTC_HTTP,
      _userAuthCode: ''
    });
  }

  build() {
    NavDestination() {
      Column() {
        Text('基础功能')
          .width("100%")
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .backgroundColor($r("app.color.bg"))
          .padding({
            left: 24,
            top: 12,
            bottom: 12
          })
        Column({ space: 16 }) {
          CustomButton({
            text: '语音通话',
            w: "100%",
            h: 48,
            disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.AudioCall)
            }
          })
          CustomButton({
            text: '视频通话',
            w: "100%",
            h: 48,
            disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.VideoCall)
            }
          })
          CustomButton({
            text: '视频设置',
            w: "100%",
            h: 48,
            disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.VideoSetting)
            }
          })
          CustomButton({
            text: '屏幕共享',
            w: "100%",
            h: 48,
            disabled: true,
            // disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.ScreenShare)
            }
          })
        }
        .backgroundColor(Color.White)
        .width("100%")
        .layoutWeight(1)
        .padding({
          left: 50,
          right: 50,
          top: 30,
          bottom: 30
        })

        Text('高级功能')
          .width("100%")
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .backgroundColor($r("app.color.bg"))
          .padding({
            left: 24,
            top: 12,
            bottom: 12
          })
        Column({ space: 16 }) {
          CustomButton({
            text: '本地录制',
            w: "100%",
            h: 48,
            disabled: true,
            // disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.LocalRecord)
            }
          })
          CustomButton({
            text: '云端录制',
            w: "100%",
            h: 48,
            disabled: true,
            // disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.CloudRecord)
            }
          })
          CustomButton({
            text: '影音共享',
            w: "100%",
            h: 48,
            disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.MediaShare)
            }
          })
          CustomButton({
            text: '聊天',
            w: "100%",
            h: 48,
            disabled: !this.isLogin,
            click: () => {
              this.pageStack.pushPathByName('Join', ExampleType.Chat)
            }
          })
        }
        .backgroundColor(Color.White)
        .width("100%")
        .layoutWeight(1)
        .padding({
          left: 50,
          right: 50,
          top: 30,
          bottom: 30
        })

        Text(`SDK Version: ${this.sdkVersion}`)
          .fontSize(12)
          .fontColor($r('app.color.text'))
      }
      .height('100%')
    }
    .title('Api Demo', {
      backgroundColor: Color.White,
    })
    .menus([
      {
        value: "",
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
        action: () => {
          clearTimeout(this.loginTimer);
          this.pageStack.pushPathByName('Setting', {}, (popInfo: PopInfo) => {
            const popResult = popInfo.result as PopResult
            if (popResult.needResetLogin) {
              this.isLogin = false
            }
          })
        }
      }
    ])
    .onReady(async (context: NavDestinationContext) => {
      console.log("<onReady>");
      this.pageStack = context.pathStack;
      callBackHandle(this.CallbackObj);
      this.sdkVersion = CRVideoSDKEx.getSDKVersion();
    })
    .onAppear(() => {
      console.log("<Login onAppear>");
    })
    .onDisAppear(() => {
      console.log("<Login onDisAppear>");
    })
    .onShown(() => {
      console.log("<Login onShown>");
    })
    .onHidden(() => {
      console.log("<Login onHidden>");
    })
    .onWillAppear(() => {
      console.log("<Login onWillAppear>");
    })
    .onWillDisappear(() => {
      console.log("<Login onWillDisappear>");
      callBackHandle(this.CallbackObj, true);
    })
    .onWillShow(() => {
      console.log("<Login onWillShow>");
      console.log(userConfig.userID)
      if (!this.isLogin) {
        this.login();
      }
    })
    .onWillHide(() => {
      console.log("<Login onWillHide>");
    })
  }
}