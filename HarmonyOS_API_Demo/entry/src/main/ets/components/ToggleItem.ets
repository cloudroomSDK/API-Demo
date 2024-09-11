@Component
export struct ToggleItem {
  text?: string;
  @Link bool: boolean;

  build() {
    Row() {
      Text(this.text).fontColor($r("app.color.text")).margin({ right: 6 })
      Toggle({ type: ToggleType.Switch, isOn: $$this.bool })
        .selectedColor($r('app.color.main'))
        .width(42)
        .height(24)
    }
  }
}