import router from './router'
import store from './store'
import { Loading, MessageBox } from 'element-ui'
import NProgress from 'nprogress' // progress bar
import 'nprogress/nprogress.css' // progress bar style
import { getToken, removeToken } from '@/utils/auth' // get token from cookie
import getPageTitle from '@/utils/get-page-title'
import { SDKInit } from '@/SDK/SDK_Init'
import SDKError from '@/SDK/Code'

NProgress.configure({ showSpinner: false }) // NProgress Configuration

const whiteList = ['/login', '/404'] // no redirect whitelist

router.beforeEach(async(to, from, next) => {
  // 正在会议或者加入会议中禁止跳转
  if (store.getters.meetingState) {
    return MessageBox.confirm(
      '您正在房间中,继续操作将退出房间,是否继续?',
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(() => {
        CRVideo_ExitMeeting()
        store.commit('state/SET_MEETING_STATE', 0)
        next()
      })
      .catch(() => {})
  }

  // start progress bar
  NProgress.start()

  // set page title
  document.title = getPageTitle(to.meta.title)

  // determine whether the user has logged in
  const hasToken = getToken()
  const loadingInstance = Loading.service({ fullscreen: true })
  await SDKInit.init()
    .then(() => {
      loadingInstance.close()
    })
    .catch((errCode) => {
      // 初始化失败
      loadingInstance.close()
      MessageBox.alert(`错误码: ${errCode},${SDKError[errCode]}`, '初始化失败')
    })

  if (hasToken) {
    if (to.path === '/login') {
      // if is logged in, redirect to the home page
      next({ path: '/' })
      NProgress.done()
    } else {
      const isLogin = store.getters.UID
      if (isLogin) {
        next()
      } else {
        try {
          await store.dispatch('user/login', JSON.parse(hasToken))

          next()
        } catch (error) {
          removeToken()
          next(`/login?redirect=${to.path}`)
          NProgress.done()
        }
      }
    }
  } else {
    /* has no token*/

    if (whiteList.indexOf(to.path) !== -1) {
      // in the free login whitelist, go directly
      next()
    } else {
      // other pages that do not have permission to access are redirected to the login page.
      next(`/login?redirect=${to.path}`)
      NProgress.done()
    }
  }
})

router.afterEach(() => {
  // finish progress bar
  NProgress.done()
})
