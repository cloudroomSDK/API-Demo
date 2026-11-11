import { setToken, removeToken } from '@/utils/auth'
import { SDKInit } from '@/SDK/SDK_Init'
import { randomNumber } from '@/utils/index'
import Cookies from 'js-cookie'
import RTCSDK from '@/SDK'

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
  login({ commit }, loginInfo) {
    var {
      authType = '1', // '1' 密码登录 '2' Token登录
      AppId,
      MD5_AppSecret,
      token,
      UID,
      nickName,
      addr = Cookies.get('addr')
    } = loginInfo

    RTCSDK.SetServerAddr(addr) // 设置服务器地址

    UID = UID || `H5_${randomNumber(4)}`
    nickName = nickName || UID

    // Token登录时userID由SDK从token中解析，登录成功后返回
    const loginPromise =
      authType === '2'
        ? SDKInit.LoginByToken({ token })
        : SDKInit.Login({ AppId, MD5_AppSecret, UID, nickName })

    return loginPromise.then((res) => {
      Cookies.set('addr', addr) // 添加cookie
      const { UID, nickName } = res
      commit('SET_NICKNAME', nickName || UID)
      commit('SET_UID', UID)
      setToken(
        JSON.stringify({
          authType,
          AppId,
          MD5_AppSecret,
          token,
          UID,
          nickName: nickName || UID
        })
      ) // 保存toekn用于下次自动登录
    })
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
