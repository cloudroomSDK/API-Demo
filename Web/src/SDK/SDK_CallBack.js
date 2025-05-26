import Vue from 'vue'
import store from '@/store'
import RTCSDK from '@/SDK'

const vm = new Vue()
const Arr = [
  'CreateMeetingSuccess',
  'CreateMeetingFail',
  'EnterMeetingRslt',
  'MeetingDropped',
  'MicEnergyUpdate',
  'OpenVideoFailed',
  'VideoDevChanged'
]

const noDebugArr = ['MicEnergyUpdate']

Arr.forEach((item) => {
  RTCSDK[item].callback = function(...arg) {
    if (noDebugArr.indexOf(item) === -1) {
      console.log(item, arg)
    }
    vm.$emit(item, ...arg)
  }
})
// 有用户进入房间，更新store
RTCSDK.UserEnterMeeting.callback = function(UID) {
  store.commit('state/ADD_MEMBER', UID)
}
// 有用户离开房间，更新store
RTCSDK.UserLeftMeeting.callback = function(UID) {
  store.commit('state/DEL_MEMBER', UID)
  vm.$emit('UserLeftMeeting', UID)
}
// 有用户改名，更新store
RTCSDK.NotifyNickNameChanged.callback = function(UID, oldName, newName) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'nickname',
    val: newName
  })
}
// 用户摄像头状态更新，更新vuex
RTCSDK.VideoStatusChanged.callback = function(UID, oldStatus, newStatus) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'videoStatus',
    val: newStatus
  })
  vm.$emit('VideoStatusChanged', UID, oldStatus, newStatus)
}
// 用户麦克风状态更新，更新vuex
RTCSDK.AudioStatusChanged.callback = function(UID, oldStatus, newStatus) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'audioStatus',
    val: newStatus
  })
}
// 扬声器风状态更新，更新vuex
RTCSDK.SpkStatusChanged.callback = function(UID, oldStatus, newStatus) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'spkStatus',
    val: newStatus
  })
}
Vue.prototype.$SDKCallBack = vm
