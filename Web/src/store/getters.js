const getters = {
  sidebar: state => state.app.sidebar,
  isSmallScreen: state => state.app.isSmallScreen,
  isMobile: state => state.app.isMobile,
  UID: state => state.user.UID,
  nickname: state => state.user.nickname,
  meetingState: state => state.state.meetingState,
  memberList: state => state.state.memberList
}
export default getters
