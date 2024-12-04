import { CRMeetingMember, CRVSDK_ASTATUS, CRVSDK_VSTATUS } from './RTCSDK'

export enum ExampleType {
  AudioCall = '语音通话',
  VideoCall = '视频通话',
  VideoSetting = '视频设置',
  ScreenShare = '屏幕共享',
  LocalRecord = '本地录制',
  CloudRecord = '云端录制',
  MediaShare = '影音共享',
  Chat = '聊天'
}


@Observed
export class MemberInfo implements CRMeetingMember {
  userId: string
  nickName: string
  audioStatus: CRVSDK_ASTATUS
  videoStatus: CRVSDK_VSTATUS

  constructor(d: CRMeetingMember) {
    this.userId = d.userId
    this.nickName = d.nickName
    this.audioStatus = d.audioStatus
    this.videoStatus = d.videoStatus
  }
}