import { CRMeetingMember, CRVSDK_ASTATUS, CRVSDK_VSTATUS } from './CRSDK'

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
  _userId: string
  _nickName: string
  _audioStatus: CRVSDK_ASTATUS
  _videoStatus: CRVSDK_VSTATUS

  constructor(d: CRMeetingMember) {
    this._userId = d._userId
    this._nickName = d._nickName
    this._audioStatus = d._audioStatus
    this._videoStatus = d._videoStatus
  }
}