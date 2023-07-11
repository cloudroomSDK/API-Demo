import App from './App'

// #ifndef VUE3
console.log('vue2')
import Vue from 'vue'
import './uni.promisify.adaptor'
App.mpType = 'app'
Vue.config.productionTip = false

const app = new Vue({
  ...App
})
app.$mount()
// #endif

// #ifdef VUE3
console.log('vue3')
import { createSSRApp } from 'vue'

export function createApp() {
  const app = createSSRApp(App)
  return {
    app
  }
}
// #endif