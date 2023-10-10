import { setToken, removeToken } from '@/utils/auth'
import { SDKInit } from '@/SDK/SDK_Init'
import { randomNumber } from '@/utils/index'
import Cookies from 'js-cookie'

const getDefaultState = () => {
  return {
    UID: '',
    nickname: ''
  }
}

const state = getDefaultState()

const mutations = {
  RESET_STATE: (state) => {
    Object.assign(state, getDefaultState())
  },
  SET_UID: (state, UID) => {
    state.UID = UID
  },
  SET_NICKNAME: (state, nickname) => {
    state.nickname = nickname
  }
}

const actions = {
  // SDK login
  login({ commit }, token) {
    var {
      AppId,
      MD5_AppSecret,
      UID,
      nickName,
      addr = Cookies.get('addr')
    } = token

    CRVideo_SetServerAddr(addr) // 设置服务器地址

    UID = UID || `H5_${randomNumber(4)}`
    nickName = nickName || UID

    return SDKInit.Login({ AppId, MD5_AppSecret, UID, nickName }).then(
      (res) => {
        Cookies.set('addr', addr) // 添加cookie
        const { UID, nickName } = res

        commit('SET_NICKNAME', nickName)
        commit('SET_UID', UID)
        setToken(JSON.stringify({ AppId, MD5_AppSecret, UID, nickName })) // 保存toekn用于下次自动登录
      }
    )
  },
  // SDK logout
  logout({ commit }) {
    removeToken()
    commit('RESET_STATE')
    SDKInit.Logout()
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
