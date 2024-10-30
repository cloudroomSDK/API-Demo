import sdk_engine, {
  callBackHandle,
  CRVideoSDKCallBack,
  CRVSDK_SCALE_MODE,
  CRVSDK_STREAM_VIEWTYPE,
  VideoComponent
} from '../common/RTCSDK';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import userConfig from '../common/UserConfig';
import { MemberInfo } from '../common/Default';
import { PermissionUtil } from '@pura/harmony-utils';
import { util } from '@kit.ArkTS';

enum RateType {
  P360,
  P480,
  P720,
  P1080,
}

@Builder
export function VideoSettingBuilder() {
  VideoSetting()
}

@Entry
@Component
struct VideoSetting {
  pageStack: NavPathStack = new NavPathStack();
  @State roomID: string = '';
  @State btnModifier: CustomButtonModifier = new CustomButtonModifier('normal', true);
  @State selectBtnModifier: CustomButtonModifier = new CustomButtonModifier('primary', true);
  @State exitBtnModifier: CustomButtonModifier = new CustomButtonModifier('danger');
  @State selIndex: RateType = RateType.P360;
  @State rateCode: number = 0;
  @State fps: number = 25;
  @State maxRateCode: number = 0;
  @State memberList: MemberInfo[] = [];
  CallbackObj: CRVideoSDKCallBack = {
    notifyUserLeftMeeting: (userID) => {
      console.log(`left ${userID}`)
      const idx = this.memberList.findIndex(item => item.userId === userID);
      if (idx > -1) {
        this.memberList.splice(idx, 1)
      }
    },
    notifyUserEnterMeeting: (userID) => {
      console.log(`enter ${userID}`)
      const userInfo = sdk_engine.getMemberInfo(userID)

      this.memberList.push(new MemberInfo(userInfo))
    },
    notifyVideoStatusChanged: (userID, oldStatus, newStatus, oprUserID) => {
      const idx = this.memberList.findIndex(item => item.userId === userID)
      if (idx > -1) {
        this.memberList[idx].videoStatus = newStatus
      }
    },
  }
  rateCodeToStr = (rateCode: number): string => {
    if (rateCode < 1000) {
      return rateCode.toFixed() + 'kbps';
    } else {
      return (rateCode / 1000).toFixed(1) + 'mbps';
    }
  }
  updateRateCodeOption = (rateType: RateType) => {
    const cfg = sdk_engine.getVideoCfg()
    if (rateType === RateType.P360) {
      this.rateCode = 350
      this.maxRateCode = 700
      cfg.size = "640*360"
    } else if (rateType === RateType.P480) {
      this.rateCode = 500
      this.maxRateCode = 1000
      cfg.size = "848*480"
    } else if (rateType === RateType.P720) {
      this.rateCode = 1000
      this.maxRateCode = 2000
      cfg.size = "1280*720"
    } else { // 1080P
      this.rateCode = 2000
      this.maxRateCode = 4000
      cfg.size = "1920*1080"
    }
    cfg.maxbps = this.rateCode * 1000
    sdk_engine.setVideoCfg(cfg)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        VideoComponent({
          canvas: {
            canvasId: util.generateRandomUUID(), //视图id
            type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO, //视图类型
            videoId: { userID: userConfig.userID, videoID: -1 },
            showMode: CRVSDK_SCALE_MODE.CRVSDK_RENDERMD_FILL
          }
        })
          .width('100%')
          .height('100%')

        Stack({ alignContent: Alignment.TopEnd }) {
          Grid() {
            ForEach(this.memberList.filter(item => item.userId !== userConfig.userID), (member: MemberInfo) => {
              GridItem() {
                VideoComponent({
                  member: member,
                  canvas: {
                    canvasId: util.generateRandomUUID(), //视图id
                    type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO, //视图类型
                    videoId: { userID: member.userId, videoID: -1 }
                  }
                })
                  .width('33.3333%')
                  .aspectRatio(1)
                  .borderRadius(8)
                  .clip(true)
              }
            }, (item: MemberInfo) => item.userId)
          }
          .layoutDirection(GridDirection.Column)
          .columnsGap(10)
          .rowsGap(10)
          .maxCount(3)
          .padding(10)
        }
        .height('100%')
        .width('100%')


        Column({ space: 10 }) {
          Text('分辨率')
            .fontColor(Color.White)
            .width('100%')
            .margin({ bottom: 4 })

          Row() {
            ForEach(Object.values(RateType).filter(item => isNaN(item as number)), (item: string, index: RateType) => {
              CustomButton({
                text: item,
                w: index >= 3 ? 80 : 70,
                h: 34,
                modifier: this.selIndex === index ? this.selectBtnModifier : this.btnModifier,
                click: () => {
                  this.selIndex = index;
                  this.updateRateCodeOption(index);
                }
              })
            })
          }
          .width("100%")
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('码率')
              .fontColor(Color.White)
              .margin({ right: 10 })
            Slider({
              value: this.rateCode,
              min: 100,
              max: this.maxRateCode,
              step: 100
            })
              .blockColor($r('app.color.main'))
              .trackColor(Color.White)
              .selectedColor(Color.White)
              .layoutWeight(1)
              .onChange((value: number, mode: SliderChangeMode) => {
                const cfg = sdk_engine.getVideoCfg()
                this.rateCode = value
                cfg.maxbps = value * 1000
                sdk_engine.setVideoCfg(cfg)
              })
            Text(this.rateCodeToStr(this.rateCode))
              .width(70)
              .fontColor(Color.White)
              .textAlign(TextAlign.End)
          }

          Row() {
            Text('帧率')
              .fontColor(Color.White)
              .margin({ right: 10 })
            Slider({
              value: this.fps,
              min: 1,
              max: 30,
              step: 1
            })
              .blockColor($r('app.color.main'))
              .trackColor(Color.White)
              .selectedColor(Color.White)
              .layoutWeight(1)
              .onChange((value: number, mode: SliderChangeMode) => {
                const cfg = sdk_engine.getVideoCfg()
                cfg.fps = value
                this.fps = value
                sdk_engine.setVideoCfg(cfg)
              })
            Text(this.fps.toFixed() + 'fps')
              .width(70)
              .fontColor(Color.White)
              .textAlign(TextAlign.End)
          }

          CustomButton({
            text: '退出',
            w: 100,
            h: 40,
            modifier: this.exitBtnModifier,
            click: () => {
              this.pageStack.pop();
            }
          })

        }
        .width('100%')
        .backgroundColor("#55000000")
        .padding({ top: 25, left: 25, right: 25 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .onReady(async (context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.roomID = context.pathInfo.param as string;
      this.updateRateCodeOption(RateType.P360)
      callBackHandle(this.CallbackObj); //销毁回调函数

      sdk_engine.setSpeakerOut(true) //设置外放

      const memberList = sdk_engine.getAllMembers();
      this.memberList = memberList.map(member => new MemberInfo(member));

      const bool = await PermissionUtil.requestPermissionsEasy('ohos.permission.CAMERA')
      if (bool) {
        sdk_engine.openVideo(userConfig.userID)
      }
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}