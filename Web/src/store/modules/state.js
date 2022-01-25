const getDefaultState = () => {
  return {
    meetingState: 0, // 表示当前会议状态 0未开始，1进入中，2正在会议中
    memberList: []
  }
}

const state = getDefaultState()

const mutations = {
  RESET_STATE: (state) => {
    Object.assign(state, getDefaultState())
  },
  SET_MEETING_STATE: (state, meetingState) => {
    state.meetingState = meetingState
    state.memberList = meetingState === 2 ? CRVideo_GetAllMembers() : []
  },
  DEL_MEMBER: (state, UID) => {
    const idx = state.memberList.findIndex((item) => item.userID === UID)
    if (idx > -1) {
      state.memberList.splice(idx, 1)
    }
  },
  ADD_MEMBER: (state, UID) => {
    const userInfo = CRVideo_GetMemberInfo(UID)
    if (userInfo) {
      state.memberList.push(userInfo)
    }
  },
  UPDATE_MEMBER: (state, user) => {
    const { UID, key, val } = user
    const userInfo = state.memberList.find((item) => item.userID === UID)
    if (userInfo) {
      userInfo[key] = val
    }
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
