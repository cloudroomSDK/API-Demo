@Component
export struct InputItem {
  text?: string;
  type: InputType = InputType.Normal
  @Link value: string;

  build() {
    Column() {
      Text(this.text)
        .margin({ bottom: 10 })
        .fontColor($r('app.color.text'))
      TextInput({
        text: $$this.value
      })
        .type(this.type)
        .backgroundColor(Color.White)
        .border({
          width: 1,
          color: $r("app.color.border")
        })
        .borderRadius(4)
    }
    .alignItems(HorizontalAlign.Start)
  }
}