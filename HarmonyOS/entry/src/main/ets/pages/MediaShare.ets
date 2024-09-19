import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { JSON } from '@kit.ArkTS';
import sdk_engine, {
  callBackHandle,
  CRVideoSDKCallBack,
  CRVSDK_MEDIA_STATE,
  CRVSDK_STREAM_VIEWTYPE,
  VideoComponent
} from '../common/RTCSDK';
import UserConfig from '../common/UserConfig';
import { fileIo as fs } from '@kit.CoreFileKit';

@Builder
export function MediaShareBuilder() {
  MediaShare()
}

@Entry
@Component
struct MediaShare {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State selBtnModifier: CustomButtonModifier = new CustomButtonModifier('info')
  @State playBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary')
  @State selectFilePath: string | null = null;
  @State isShowIcon: boolean = false;
  @State isPlaying: boolean = false;
  @State isPause: boolean = false;
  @State isMyShare: boolean = false;
  iconTimer: number = 0;
  ToggleIcon = (curPause: boolean) => {
    this.isPause = !curPause
    clearTimeout(this.iconTimer)
    this.isShowIcon = true
    if (!this.isPause) {
      this.iconTimer = setTimeout(() => this.isShowIcon = false, 800)
    }
    sdk_engine.pausePlayMedia(this.isPause)
  }
  CallbackObj: CRVideoSDKCallBack = {
    notifyMediaStart: (userID) => {
      this.isShowIcon = false
      this.isPause = false;
      this.isPlaying = true
      this.isMyShare = userID === UserConfig.userID
    },
    notifyMediaStop: (userID) => {
      this.isPlaying = false
      this.isMyShare = false
      this.isPause = false
      this.isShowIcon = false
      this.playBtnModifier.type = 'primary';
    },
    notifyMediaPause: (userID, bPause) => {
      this.isPause = bPause
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if (!this.isPlaying) {
          Column() {
            Column({ space: 10 }) {
              Text('请选择文件')
                .width('100%')
                .fontColor($r('app.color.text'))
              Row({ space: 10 }) {
                CustomButton({
                  text: "浏览...",
                  modifier: this.selBtnModifier,
                  h: 32,
                  click: async () => {
                    try {
                      let photoPicker = new photoAccessHelper.PhotoViewPicker();
                      const arr = await photoPicker.select({
                        isEditSupported: true,
                        isOriginalSupported: true,
                        maxSelectNumber: 1,
                        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
                      })

                      if (arr.photoUris.length) {
                        // picker获取的文件是file协议的，SDK不支持这种协议，需要重新写进沙盒路径
                        let file = fs.openSync(arr.photoUris[0], fs.OpenMode.READ_ONLY)
                        let stat = fs.statSync(file.fd)
                        let buffer = new ArrayBuffer(stat.size)
                        fs.readSync(file.fd, buffer)
                        let newPath: string = getContext().tempDir + "/" + file.name
                        let newFile = fs.openSync(newPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
                        fs.writeSync(newFile.fd, buffer)
                        fs.closeSync(file)
                        this.selectFilePath = newPath
                      }
                    } catch (error) {
                      let err: BusinessError = error as BusinessError;
                      console.error('PhotoViewPicker failed with err: ' + JSON.stringify(err));
                    }
                  }
                })
                Text(this.selectFilePath ? this.selectFilePath : '未选择文件')
                  .fontColor($r('app.color.text'))
                  .layoutWeight(1)
              }
            }
            .backgroundColor(Color.White)
            .borderRadius(5)
            .width('80%')
            .padding(25)
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#1d232f')
          .justifyContent(FlexAlign.Center)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        } else {
          Stack() {
            Column() {
              VideoComponent({
                type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_MEDIA, //视图类型
              })
            }
            .width("100%")
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

            if (this.isMyShare && this.isShowIcon) {
              Text() {
                SymbolSpan(this.isPause ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause'))
                  .fontSize(50)
                  .fontColor([$r('app.color.videoBg')])
              }
              .textAlign(TextAlign.Center)
              .width(80)
              .height(80)
              .borderRadius(40)
              .backgroundColor('#61656e')
              .opacity(.5)
            }

          }.width("100%")
          .height("100%")
          .onClick(() => {
            if (this.isMyShare) {
              this.ToggleIcon(this.isPause)
            }
          })
        }
        if ((!this.isPlaying) || (this.isPlaying && this.isMyShare)) {
          Column({ space: 10 }) {
            CustomButton({
              text: this.isPlaying ? '停止播放' : '开始播放',
              w: 100,
              h: 40,
              disabled: !this.selectFilePath,
              modifier: this.playBtnModifier,
              click: async () => {
                if (this.isPlaying) {
                  // 停止播放
                  this.playBtnModifier.type = 'primary';
                  this.isShowIcon = false
                  this.isMyShare = false
                  this.isPlaying = false
                  sdk_engine.stopPlayMedia()
                } else if (this.selectFilePath) {
                  // 开始播放
                  this.playBtnModifier.type = 'danger';
                  this.isShowIcon = false
                  this.isMyShare = true
                  this.isPlaying = true
                  sdk_engine.startPlayMedia(this.selectFilePath)
                }
              }
            })
          }
          .width('100%')
          .backgroundColor("#55000000")
          .padding({ top: 25, left: 25, right: 25 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }
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
      const mediaInfo = sdk_engine.getMediaInfo();
      if (mediaInfo.state !== CRVSDK_MEDIA_STATE.CRVSDK_MEDIAST_STOPPED) {
        this.isPlaying = true
      }
      callBackHandle(this.CallbackObj) //销毁回调函数
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true) //销毁回调函数
      sdk_engine.exitMeeting()
    })
  }
}