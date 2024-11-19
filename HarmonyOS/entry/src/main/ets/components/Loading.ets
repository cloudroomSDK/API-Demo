import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { AppUtil } from '@pura/harmony-utils';

class LoadingManager {
  contentNode: ComponentContent<Object> | undefined = undefined;
  promptAction: PromptAction | undefined = undefined;

  show() {
    const uiContext = AppUtil.getUIContext()
    this.contentNode = new ComponentContent(uiContext, wrapBuilder(Loading));
    this.promptAction = uiContext.getPromptAction();
    this.promptAction.openCustomDialog(this.contentNode, {
      alignment: DialogAlignment.Center,
      // 拦截物理返回按钮、手势滑动关闭弹窗
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        console.info('reason' + JSON.stringify(dismissDialogAction.reason));
      }
    })
  }

  hide() {
    if (this.promptAction) {
      this.promptAction.closeCustomDialog(this.contentNode)
    }
  }
}

let loadingManager = new LoadingManager()

export default loadingManager;


@Builder
function Loading() {
  Column() {
    LoadingProgress()
      .width(50).height(50)
      .color(Color.White)
  }
  .width('100%')
  .height('100%')
  .backgroundColor('rgba(0,0,0,0.5)')
  .justifyContent(FlexAlign.Center)
}