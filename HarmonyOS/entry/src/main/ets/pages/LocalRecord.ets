import { CustomButton, CustomButtonModifier } from '../components/CustomButton';

@Builder
export function LocalRecordBuilder() {
  LocalRecord()
}

@Entry
@Component
struct LocalRecord {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State btnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State filename: string = '';

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 40 }) {

        }
        .height('100%')
        .justifyContent(FlexAlign.Center)

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
              text: this.btnModifier.type === 'primary' ? '开始录制' : '结束录制',
              w: 100,
              h: 40,
              modifier: this.btnModifier,
              click: () => {
                if (this.btnModifier.type === 'primary') {
                  this.btnModifier.type = 'danger'
                } else {
                  this.btnModifier.type = 'primary';
                }
              }
            })
          }
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
    })
  }
}