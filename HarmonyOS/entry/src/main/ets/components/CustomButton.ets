type ButtonType = 'primary' | 'danger' | 'normal' | 'info'

export class CustomButtonModifier implements AttributeModifier<ButtonAttribute> {
  type: ButtonType = 'primary'
  plain: boolean = false

  constructor(type: ButtonType = 'primary', plain: boolean = false) {
    this.type = type;
    this.plain = plain;
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.plain) {
      if (this.type === 'danger') {
        instance
          .backgroundColor(Color.Transparent)
          .fontColor($r("app.color.danger"))
          .border({
            width: 1,
            color: $r("app.color.danger")
          })
      } else if (this.type === 'normal') {
        instance
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .border({
            width: 1,
            color: Color.White
          })
      } else {
        instance
          .backgroundColor(Color.Transparent)
          .fontColor($r("app.color.main"))
          .border({
            width: 1,
            color: $r("app.color.main")
          })
      }
    } else if (this.type === 'danger') {
      instance.backgroundColor($r("app.color.danger"))
    } else if (this.type === 'info') {
      instance.backgroundColor($r("app.color.info"))
        .fontColor($r('app.color.text'))
    } else {
      instance.backgroundColor($r("app.color.main"))
    }
  }
}

@Component
export struct CustomButton {
  @Prop text: String = ''
  @Prop disabled?: boolean = false
  @Prop modifier?: CustomButtonModifier = new CustomButtonModifier('primary')
  @Prop h?: Length = 'auto'
  @Prop w?: Length = 'auto'
  click?: (event: ClickEvent) => void;

  build() {
    Button(this.text.toString(), {
      type: ButtonType.Normal,
    })
      .attributeModifier(this.modifier)
      .width(this.w)
      .height(this.h)
      .borderRadius(4)
      .enabled(!this.disabled)
      .onClick(this.click)
  }
}
