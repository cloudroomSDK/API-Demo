@Builder
export function CloudRecordBuilder() {
  CloudRecord()
}

@Entry
@Component
struct CloudRecord {
  pageStack: NavPathStack = new NavPathStack;
  @State roomID: string = '';

  build() {
    NavDestination() {
      Column() {
        Divider()
        Text('云端录制')
      }
      .backgroundColor(Color.White)
      .height("100%")
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .backgroundColor($r("app.color.bg"))
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;
    })
  }
}