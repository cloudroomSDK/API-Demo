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
import MD5 from 'crypto-js/md5'

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
      const serverAddr = Cookies.get('addr');
      const data = {
        RequestId: '' + new Date().getTime(),
        fileName: this.info.fileName
      }

      // appID为‘默认’的情况下，要用compID和compSecret鉴权
      if (AppId === '默认') {
        // 自建环境CompID和CompSecret默认都是1
        let CompID = 1;
        let CompSecret = 1;
        if (serverAddr.includes('crlab.cloudr')) {
          // 内网25环境
          CompID = 213213;
          CompSecret = '7859f2ee1064f3fac228b1792f8ca48b';
        } else if (serverAddr.includes('sdk.cloudr')) {
          // 公有云环境
          CompID = 213213;
          CompSecret = '1hm4fn0lop79oyz7kjorzp0szis95uia';
        }
        data['CompID'] = CompID;
        data['SecretKey'] = MD5((`${CompID}&${CompSecret}`).toString());

        // appID不为‘默认’的情况下，可以用userName和userPswd鉴权
      } else {
        data['UserName'] = AppId;
        data['UserPswd'] = MD5_AppSecret;
      }


      jsonp({
        url: `https://${serverAddr}/CLOUDMEETING-API/netDisk/query`,
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
