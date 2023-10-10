console.log(`version: 1.0.3`)
import Vue from 'vue'

import 'normalize.css/normalize.css' // A modern alternative to CSS resets

import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

import '@/styles/index.scss' // global css

import App from './App'
import store from './store'
import router from './router'
import { parseTime } from './utils'

import '@/utils/resizeHandler' // 监听窗口大小变化
import '@/icons' // icon
import '@/permission' // permission control

import '@/SDK/SDK_CallBack' // 注册SDK回调事件，并且将事件发布到vue实例中

Vue.use(ElementUI)

Vue.config.productionTip = false

// 添加SDK的容器指令，创建虚拟DOM后可通知指令的方式直接在虚拟DOM里添加HTML元素
Vue.directive('SDKVideo', {
  // 当被绑定的元素插入到 DOM 中时……
  inserted(el, { value, modifiers }) {
    if (modifiers.user) {
      // 添加成员视图容器
      const { UID, camId } = value
      const userVideoObj = CRVideo_CreatVideoObj() // 创建视频对象
      userVideoObj.setVideo(UID, camId) // 设置显示成员摄像头画面,camId为undefined时则订阅默认摄像头

      // 创建SDK视频对象，并挂载到DOM上
      el.appendChild(userVideoObj.handler()) // 将组件DOM放到页面上
    } else if (modifiers.screen) {
      // 插入屏幕共享视频容器
      const screenObj = CRVideo_CreatScreenShareObj() // SDK主调接口：创建屏幕共享容器
      screenObj.setVideo(value) // setVideo后才会显示内容
      console.log(screenObj.handler())
      const dom = screenObj.handler()
      dom.getElementsByTagName('video')[0].controls = true
      el.appendChild(dom) // 将组件DOM放到页面上
    } else if (modifiers.media) {
      // 插入影音共享视频容器
      const { shareUID, curPlayFile } = value
      const mediaObj = CRVideo_CreatMediaObj() // SDK通知接口：创建影音共享播放容器
      if (curPlayFile) {
        CRVideo_StartPlayMedia(mediaObj, curPlayFile) // SDK通知接口：开始播放影音共享
      }
      mediaObj.setVideo(shareUID) // setVideo后才会显示视频
      el.appendChild(mediaObj.handler()) // 将组件DOM放到页面上
    }
  }
})

// 添加全局时间过滤器
Vue.filter('parseTime', parseTime)

new Vue({
  el: '#app',
  router,
  store,
  render: (h) => h(App)
})
