<template>
  <div>
    <p>大小: {{ (info.fileSize / 1000000) | keepTwoDecimal }}MB</p>
    <p>视频时长: {{ parseInt(info.duration / 1000) }}秒</p>
    <p>
      状态:
      <span v-if="state === 2">正在进行...</span>
      <span v-if="state === 4">正在上传...</span>
      <span v-if="state === 5">上传完成...</span>
      <span v-if="state === 6">上传出错...</span>
      <span
        v-if="state === 7 && !downloadUrl"
      >录制完成,正在查询下载地址...</span>
      <span v-if="state === 7 && downloadUrl">完成</span>
    </p>
    <p>
      下载地址：<a :href="downloadUrl">{{ downloadUrl }}</a>
    </p>
  </div>
</template>

<script>
import { jsonp } from '@/utils'
import { getToken } from '@/utils/auth'
import Cookies from 'js-cookie'
export default {
  filters: {
    // 四舍五入保留两位小数
    keepTwoDecimal(num) {
      return Math.round(num * 100) / 100
    }
  },
  props: {
    info: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      downloadUrl: ''
    }
  },
  computed: {
    state() {
      return this.info.state
    }
  },
  watch: {
    state(newVal, oldVal) {
      if (newVal === 7) {
        this.getDownload()
        console.log(this.info.id)
      }
    }
  },
  methods: {
    // 调用服务端api，获取录像下载地址
    getDownload() {
      const { AppId, MD5_AppSecret } = JSON.parse(getToken())
      const data = {
        RequestId: '' + new Date().getTime(),
        UserName: AppId,
        UserPswd: MD5_AppSecret,
        fileName: this.info.fileName
      }
      jsonp({
        url: `https://${Cookies.get('addr')}/CLOUDROOM-API/netDisk/query`,
        data,
        success: (data) => {
          try {
            this.downloadUrl = data.Data.fileList[0].downUrl
          } catch (error) {
            this.downloadUrl = '查询失败'
            console.log(error)
          }
        },
        fail: (e) => {}
      })
    }
  }
}
</script>

<style lang="scss" scoped>
p {
  word-break: break-all;
  a {
    color: #3981fc;
    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
