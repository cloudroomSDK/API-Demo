import { CustomButton } from '../components/CustomButton';
import { AppUtil, DateUtil, JSONUtil } from '@pura/harmony-utils';
import sdk_engine, { callBackHandle, CRVideoSDKCallBack } from '../common/RTCSDK';
import UserConfig from '../common/UserConfig';
import { JSON } from '@kit.ArkTS';
import { KeyboardAvoidMode } from '@kit.ArkUI';

interface chatItem {
  userID: string,
  context: string,
  time: Date,
}

@Builder
export function ChatBuilder() {
  Chat()
}

class IMMessage {
  "CmdType": string;
  "IMMsg": string
}

@Entry
@Component
struct Chat {
  pageStack: NavPathStack = new NavPathStack;
  @State roomID: string = '';
  @State list: chatItem[] = [];
  @State inputValue: string = '';
  scroller: Scroller = new Scroller()
  @State isFocusable: boolean = false; //这个变量是为了控制输入框的焦点
  private ID_TARGET_TEXT_INPUT: string = "ID_TARGET_TEXT_INPUT";
  CallbackObj: CRVideoSDKCallBack = {
    notifyMeetingCustomMsg: (fromUserID: string, msg: string) => {
      const msgO = JSONUtil.jsonToBean(IMMessage, msg) as IMMessage
      if (msgO?.CmdType === 'IM') {
        this.list.push({
          userID: fromUserID,
          context: msgO.IMMsg,
          time: new Date(),
        })

        this.scroller.scrollEdge(Edge.Bottom);
      }
    },
  }

  @Builder
  chat(chat: chatItem, isMe: boolean = false) {
    Column() {
      Row({ space: 10 }) {
        Text(DateUtil.getFormatDateStr(chat.time, 'HH:mm'))
          .fontColor('#999')
          .fontSize(18)
        if (!isMe) {
          Text(chat.userID)
            .fontColor($r('app.color.text'))
            .fontSize(18)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
        }
      }

      Text(chat.context)
        .fontColor($r('app.color.text'))
        .fontSize(18)
        .lineHeight(28)
        .textAlign(TextAlign.JUSTIFY)
    }
    .width("100%")
    .alignItems(isMe ? HorizontalAlign.End : HorizontalAlign.Start)
    .padding({
      left: isMe ? 40 : 0,
      right: isMe ? 0 : 40
    })
  }

  build() {
    NavDestination() {
      Column() {
        Divider()
        if (this.list.length <= 0) {
          Column({ space: 10 }) {
            SymbolGlyph($r('sys.symbol.square_slash'))
              .fontSize(70)
              .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
            Text('暂无聊天').fontColor($r('app.color.text'))
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ scroller: this.scroller }) {
            ForEach(this.list, (item: chatItem) => {
              ListItem() {
                this.chat(item, item.userID === UserConfig.userID);
              }
              .width("100%")
              .padding({
                top: 10,
                bottom: 10,
                left: 16,
                right: 16
              })
            })
          }
          .layoutWeight(1)
          .id('list')
        }

        Row({ space: 10 }) {
          TextInput({
            text: $$this.inputValue
          })
            .id(this.ID_TARGET_TEXT_INPUT)
            .focusable(this.isFocusable)
            .backgroundColor(Color.White)
            .layoutWeight(1)
            .borderRadius(4)
            .onClick(() => {
              if (this.isFocusable) {
                return;
              }
              if (this.list.length > 5) {
                // 当列表达到一定高度，键盘弹出后，采用上抬页面的方式，效果更佳
                AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
              }

              this.isFocusable = true;
              focusControl.requestFocus(this.ID_TARGET_TEXT_INPUT);
            })

          CustomButton({
            text: "发送",
            disabled: this.inputValue.trim().length === 0,
            click: () => {
              const message: IMMessage = {
                CmdType: 'IM',
                IMMsg: this.inputValue
              }
              sdk_engine.sendMeetingCustomMsg(JSON.stringify(message));
              this.inputValue = '';
              this.scroller.scrollEdge(Edge.Bottom)
            }
          })
        }
        .backgroundColor($r("app.color.bg"))
        .padding({
          top: 20,
          left: 20,
          right: 20,
          bottom: 2
        }).onClick(() => {
        })
      }
      .backgroundColor(Color.White)
      .height("100%")
      .onClick(() => {
        this.isFocusable = false; // 触摸键盘之外，释放焦点，从而让键盘收起
      })
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .backgroundColor($r("app.color.bg"))
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;
      callBackHandle(this.CallbackObj); //销毁回调函数

      sdk_engine.setSpeakerOut(true) //使用扬声器

      // 当消息列表长度较小时，键盘弹出时，采用压缩页面的方式效果更佳
      AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}