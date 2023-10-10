import Vue from 'vue'
import store from '@/store'
const vm = new Vue()
const Arr = [
  'CRVideo_CreateMeetingSuccess',
  'CRVideo_CreateMeetingFail',
  'CRVideo_EnterMeetingRslt',
  'CRVideo_MeetingDropped',
  'CRVideo_MicEnergyUpdate',
  'CRVideo_OpenVideoFailed',
  'CRVideo_VideoDevChanged'
]

const noDebugArr = ['CRVideo_MicEnergyUpdate']

Arr.forEach((item) => {
  window[item].callback = function(...arg) {
    if (noDebugArr.indexOf(item) === -1) {
      console.log(item, arg)
    }
    vm.$emit(item, ...arg)
  }
})
// 有用户进入房间，更新store
CRVideo_UserEnterMeeting.callback = function(UID) {
  store.commit('state/ADD_MEMBER', UID)
}
// 有用户离开房间，更新store
CRVideo_UserLeftMeeting.callback = function(UID) {
  store.commit('state/DEL_MEMBER', UID)
  vm.$emit('CRVideo_UserLeftMeeting', UID)
}
// 有用户改名，更新store
CRVideo_NotifyNickNameChanged.callback = function(UID, oldName, newName) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'nickname',
    val: newName
  })
}
// 用户摄像头状态更新，更新vuex
CRVideo_VideoStatusChanged.callback = function(UID, oldStatus, newStatus) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'videoStatus',
    val: newStatus
  })
  vm.$emit('CRVideo_VideoStatusChanged', UID, oldStatus, newStatus)
}
// 用户麦克风状态更新，更新vuex
CRVideo_AudioStatusChanged.callback = function(UID, oldStatus, newStatus) {
  store.commit('state/UPDATE_MEMBER', {
    UID,
    key: 'audioStatus',
    val: newStatus
  })
}
Vue.prototype.$SDKCallBack = vm
