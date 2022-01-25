import store from '@/store'
import router from '@/router'
;(function() {
  const { body } = document
  let smallScreen = false

  function getScreen() {
    const { width } = body.getBoundingClientRect()
    return {
      isSmallScreen: width - 1 < 992,
      isMobile: width - 1 < 760
    }
  }

  function resizeHandler() {
    if (!document.hidden) {
      const { isSmallScreen, isMobile } = getScreen()
      smallScreen = isSmallScreen
      store.dispatch('app/toggleSize', {
        isSmallScreen,
        isMobile
      })
      if (isSmallScreen) {
        store.dispatch('app/closeSideBar', { withoutAnimation: true })
      } else {
        store.dispatch('app/openSideBar')
      }
    }
  }

  router.afterEach((to, from) => {
    // 如果是小屏幕那就关闭侧边导航栏
    if (smallScreen && store.state.app.sidebar.opened) {
      store.dispatch('app/closeSideBar', { withoutAnimation: false })
    }
  })

  resizeHandler()
  window.addEventListener('resize', resizeHandler)
})()
