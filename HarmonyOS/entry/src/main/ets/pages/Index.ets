@Entry
@Component
struct Index {
  pageStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageStack) {
    }
    .onAppear(() => {
      this.pageStack.pushPathByName("Login", null);
    })
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r("app.color.bg"))
  }
}