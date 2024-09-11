import { CustomButton } from '../components/CustomButton';
import { InputItem } from '../components/InputItem';
import { ToggleItem } from '../components/ToggleItem';
import loginConfig from '../common/LoginConfig';
import sdk_engine from '../common/CRSDK';

@Builder
export function SettingBuilder() {
  Setting()
}

@Component
struct Setting {
  pageStack: NavPathStack = new NavPathStack();
  @State addr: string = loginConfig.addr;
  @State AppID: string = loginConfig.AppID || '';
  @State AppSecret: string = loginConfig.AppSecret || '';
  @State Token: string = loginConfig.Token || '';
  @State useToken: boolean = loginConfig.useToken;
  @State useHTTPS: boolean = loginConfig.useHTTPS;

  @Builder
  savaBuilder() {
    Text('重置')
      .height('100%')
      .fontColor($r("app.color.danger"))
      .margin({ right: 10 })
      .fontSize(18)
      .onClick(() => {
        const defaultConfig = loginConfig.getDefaultConfig();

        this.addr = defaultConfig.addr;
        this.AppID = defaultConfig.AppID || '';
        this.AppSecret = defaultConfig.AppSecret || '';
        this.Token = defaultConfig.Token || '';
        this.useToken = defaultConfig.useToken;
        this.useHTTPS = defaultConfig.useHTTPS;
      })
  }

  @Builder
  inputItem(type: InputType = InputType.Normal, text: string, value: string, onChange: EditableTextOnChangeCallback) {
    Column() {
      Text(text)
        .margin({ bottom: 10 })
        .fontColor($r('app.color.text'))
      TextInput({
        text: value
      })
        .type(type)
        .backgroundColor(Color.White)
        .border({
          width: 1,
          color: $r("app.color.border")
        })
        .borderRadius(4)
        .onChange(onChange)
    }
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 20 }) {
          Row() {
            ToggleItem({
              text: '使用Https',
              bool: this.useHTTPS
            })

            ToggleItem({
              text: 'Token鉴权',
              bool: this.useToken
            })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width("100%")

          InputItem({
            text: '服务器地址:',
            value: this.addr
          })

          if (this.useToken) {
            InputItem({
              text: 'Token:',
              value: this.Token
            })
          } else {

            InputItem({
              text: 'APP ID:',
              value: this.AppID
            })

            InputItem({
              text: 'APP AppSecret:',
              value: this.AppSecret,
              type: InputType.Password
            })
          }
        }
        .width("100%")
        .backgroundColor(Color.White)
        .margin({ top: 10 })
        .padding({
          left: 40,
          right: 40,
          top: 30,
          bottom: 30
        })

        CustomButton({
          text: '保存',
          w: "100%",
          h: 50,
          click: () => {
            if (this.addr !== loginConfig.addr ||
              this.AppID !== loginConfig.AppID ||
              this.AppSecret !== loginConfig.AppSecret ||
              this.Token !== loginConfig.Token ||
              this.useToken !== loginConfig.useToken ||
              this.useHTTPS !== loginConfig.useHTTPS
            ) {
              sdk_engine.logout();
              this.pageStack.pop({ needResetLogin: true })
              loginConfig.sava({
                addr: this.addr,
                AppID: this.AppID,
                AppSecret: this.AppSecret,
                Token: this.Token,
                useToken: this.useToken,
                useHTTPS: this.useHTTPS,
              })
            } else {
              this.pageStack.pop({ needResetLogin: false })
            }
          }
        })
          .padding(40)
      }
      .height("100%")
    }
    .title('设置', {
      backgroundColor: Color.White,
    })
    .backgroundColor($r("app.color.bg"))
    .menus(this.savaBuilder)
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
  }
}