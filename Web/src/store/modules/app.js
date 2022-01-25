const state = {
  sidebar: {
    opened: false,
    withoutAnimation: false
  },
  isSmallScreen: false,
  isMobile: false
}

const mutations = {
  TOGGLE_SIDEBAR: (state) => {
    state.sidebar.opened = !state.sidebar.opened
    state.sidebar.withoutAnimation = false
  },
  CLOSE_SIDEBAR: (state, withoutAnimation) => {
    state.sidebar.opened = false
    state.sidebar.withoutAnimation = withoutAnimation
  },
  OPEN_SIDEBAR: (state) => {
    state.sidebar.opened = true
  },
  TOGGLE_SCREEN_SIZE: (state, { isSmallScreen, isMobile }) => {
    state.isSmallScreen = isSmallScreen
    state.isMobile = isMobile
  }
}

const actions = {
  toggleSideBar({ commit }) {
    commit('TOGGLE_SIDEBAR')
  },
  closeSideBar({ commit }, { withoutAnimation }) {
    commit('CLOSE_SIDEBAR', withoutAnimation)
  },
  openSideBar({ commit }) {
    commit('OPEN_SIDEBAR')
  },
  toggleSize({ commit }, obj) {
    commit('TOGGLE_SCREEN_SIZE', obj)
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
