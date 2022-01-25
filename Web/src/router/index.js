import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

/* Layout */
import Layout from '@/layout'

/**
 * Note: sub-menu only appear when route children.length >= 1
 * Detail see: https://panjiachen.github.io/vue-element-admin-site/guide/essentials/router-and-nav.html
 *
 * hidden: true                   if set true, item will not show in the sidebar(default is false)
 * alwaysShow: true               if set true, will always show the root menu
 *                                if not set alwaysShow, when item has more than one children route,
 *                                it will becomes nested mode, otherwise not show the root menu
 * redirect: noRedirect           if set noRedirect will no redirect in the breadcrumb
 * name:'router-name'             the name is used by <keep-alive> (must set!!!)
 * meta : {
    roles: ['admin','editor']    control the page roles (you can set multiple roles)
    title: 'title'               the name show in sidebar and breadcrumb (recommend set)
    icon: 'svg-name'/'el-icon-x' the icon show in the sidebar
    breadcrumb: false            if set false, the item will hidden in breadcrumb(default is true)
    activeMenu: '/example/list'  if set path, the sidebar will highlight the path you set
  }
 */

/**
 * constantRoutes
 * a base page that does not have permission requirements
 * all roles can be accessed
 */
export const constantRoutes = [
  { path: '/', redirect: '/example', hidden: true },
  {
    path: '/login',
    component: () => import('@/views/login/index'),
    hidden: true
  },
  {
    path: '/example',
    component: Layout,
    redirect: '/example/video',
    name: 'Example',
    meta: { title: '基础演示' },
    children: [
      {
        path: 'video',
        name: 'video',
        component: () => import('@/views/video'),
        meta: { title: '音视频通话' }
      },
      {
        path: 'screen',
        name: 'screen',
        component: () => import('@/views/screen'),
        meta: { title: '屏幕共享' }
      },
      {
        path: 'audioAttr',
        name: 'audioAttr',
        component: () => import('@/views/audioAttr'),
        meta: { title: '设置音频属性' }
      },
      {
        path: 'videoAttr',
        name: 'videoAttr',
        component: () => import('@/views/videoAttr'),
        meta: { title: '设置视频属性' }
      },
      {
        path: 'record',
        name: 'record',
        component: () => import('@/views/record'),
        meta: { title: '云端录制' }
      }
    ]
  },
  {
    path: '/advanced',
    component: Layout,
    redirect: '/advanced/table',
    name: 'Advanced',
    meta: { title: '高级示例' },
    children: [
      {
        path: 'media',
        name: 'media',
        component: () => import('@/views/media'),
        meta: { title: '影音播放' }
      },
      {
        path: 'cameras',
        name: 'cameras',
        component: () => import('@/views/cameras'),
        meta: { title: '多摄像头' }
      },
      {
        path: 'chat',
        name: 'chat',
        component: () => import('@/views/chat'),
        meta: { title: '聊天' }
      },
      {
        path: 'meettingAttr',
        name: 'meettingAttr',
        component: () => import('@/views/meettingAttr'),
        meta: { title: '房间和成员属性' }
      }
    ]
  },
  /*
  {
    path: 'external-link',
    component: Layout,
    children: [
      {
        path: 'https://sdk.cloudroom.com/sdkdoc/H5/',
        meta: { title: 'H5_SDK帮助文档', icon: 'link' }
      }
    ]
  }, */

  // 404 page must be placed at the end !!!
  { path: '*', component: () => import('@/views/404'), hidden: true }
]

const createRouter = () =>
  new Router({
    mode: 'history', // require service support
    base: process.env.BASE_URL,
    scrollBehavior: () => ({ y: 0 }),
    routes: constantRoutes
  })

const router = createRouter()

// Detail see: https://github.com/vuejs/vue-router/issues/1234#issuecomment-357941465
export function resetRouter() {
  const newRouter = createRouter()
  router.matcher = newRouter.matcher // reset router
}

export default router
