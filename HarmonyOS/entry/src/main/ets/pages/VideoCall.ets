import sdk_engine, {
  callBackHandle,
  CRVideoDevInfo,
  CRVideoSDKCallBack,
  CRVSDK_STREAM_VIEWTYPE,
  CRVSDK_VSTEAMLV_TYPE,
  VideoComponent
} from '../common/RTCSDK';
import { CustomButton, CustomButtonModifier } from '../components/CustomButton';
import userConfig from '../common/UserConfig';
import { MemberInfo } from '../common/Default';
import { PermissionUtil, ToastUtil } from '@pura/harmony-utils';

enum CamListNum {
  Back = "CAMERA_FACING_BACK",
  Front = "CAMERA_FACING_FRONT"
}

@Builder
export function VideoCallBuilder() {
  VideoCall()
}

@Entry
@Component
struct VideoCall {
  pageStack: NavPathStack = new NavPathStack()
  @State roomID: string = ''
  @State btnModifier: CustomButtonModifier = new CustomButtonModifier()
  @State memberList: MemberInfo[] = []
  @State curCamDev: CamListNum = CamListNum.Back //默认值是后置摄像头
  @State isOpenCamStatus: boolean = false
  @State isOpenMicStatus: boolean = false
  @State useSpeakerOut: boolean = true
  camList: CRVideoDevInfo[] = []
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
  toogleCamDev = () => {
    let cam = CamListNum.Front;
    if (this.curCamDev === CamListNum.Front) {
      cam = CamListNum.Back;
    }

    let devInfo: CRVideoDevInfo | undefined =
      this.camList.find((item: CRVideoDevInfo) => item.devName == cam)
    if (devInfo) {
      console.log('devInfo._videoID', devInfo.videoID)
      sdk_engine.setDefaultVideo(devInfo.videoID);
      this.curCamDev = cam;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        VideoComponent({
          member: this.memberList.find(item => item.userId === userConfig.userID),
          type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO,
          videoId: { userID: userConfig.userID, videoID: -1 },
          videoLv: CRVSDK_VSTEAMLV_TYPE.CRVSDK_VSTP_LV0,
          showName: false
        })
          .width('100%')
          .height('100%')

        Stack({ alignContent: Alignment.TopEnd }) {
          Grid() {
            ForEach(this.memberList.filter(item => item.userId !== userConfig.userID), (member: MemberInfo) => {
              GridItem() {
                VideoComponent({
                  member: member,
                  type: CRVSDK_STREAM_VIEWTYPE.CRVSDK_VIEWTP_VIDEO,
                  videoId: { userID: member.userId, videoID: -1 },
                  videoLv: CRVSDK_VSTEAMLV_TYPE.CRVSDK_VSTP_LV0,
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

        Grid() {
          GridItem() {
            CustomButton({
              text: `切换${this.curCamDev === CamListNum.Front ? '后置' : '前置'}摄像头`,
              w: '100%',
              h: 42,
              modifier: this.btnModifier,
              click: () => {
                this.toogleCamDev();
              }
            })
          }

          GridItem() {
            CustomButton({
              text: `${this.isOpenCamStatus ? '关闭' : '打开'}摄像头`,
              w: '100%',
              h: 42,
              modifier: this.btnModifier,
              click: async () => {
                if (this.isOpenCamStatus) {
                  this.isOpenCamStatus = false;
                  sdk_engine.closeVideo(userConfig.userID)
                } else if (await PermissionUtil.requestPermissionsEasy(['ohos.permission.CAMERA'])) {
                  this.isOpenCamStatus = true;
                  sdk_engine.openVideo(userConfig.userID)
                } else {
                  ToastUtil.showToast('没有权限')
                }
              }
            })
          }

          GridItem() {
            CustomButton({
              text: `${this.isOpenMicStatus ? '关闭' : '打开'}麦克风`,
              w: '100%',
              h: 42,
              modifier: this.btnModifier,
              click: async () => {
                if (this.isOpenMicStatus) {
                  this.isOpenMicStatus = false;
                  sdk_engine.closeMic(userConfig.userID)
                } else if (await PermissionUtil.requestPermissionsEasy(['ohos.permission.MICROPHONE'])) {
                  this.isOpenMicStatus = true;
                  sdk_engine.openMic(userConfig.userID)
                } else {
                  ToastUtil.showToast('没有权限')
                }
              }
            })
          }

          GridItem() {
            CustomButton({
              text: `切换为${this.useSpeakerOut ? '听筒' : '扬声器'}`,
              w: '100%',
              h: 42,
              modifier: this.btnModifier,
              click: () => {
                this.useSpeakerOut = !this.useSpeakerOut
                sdk_engine.setSpeakerOut(this.useSpeakerOut)
              }
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(20)
        .height(120)
        .backgroundColor("#55000000")
        .padding({ left: 25, right: 25 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .title(`房间号: ${this.roomID}`, {
      backgroundColor: Color.White
    })
    .onReady(async (context: NavDestinationContext) => {
      this.pageStack = context.pathStack
      this.roomID = context.pathInfo.param as string
      callBackHandle(this.CallbackObj) //销毁回调函数

      sdk_engine.setSpeakerOut(true) //设置外放

      const memberList = sdk_engine.getAllMembers()
      this.memberList = memberList.map(member => new MemberInfo(member))


      this.camList = sdk_engine.getAllVideoInfo(userConfig.userID)
      console.log(JSON.stringify(this.camList))

      const bool = await PermissionUtil.requestPermissionsEasy(['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
      if (bool) {
        this.toogleCamDev() //SDK默认使用后置摄像头，这里是切换到前置摄像头
        this.isOpenCamStatus = true;
        sdk_engine.openVideo(userConfig.userID)
        this.isOpenMicStatus = true;
        sdk_engine.openMic(userConfig.userID)
      }
    })
    .onWillDisappear(() => {
      callBackHandle(this.CallbackObj, true); //销毁回调函数
      sdk_engine.exitMeeting();
    })
  }
}