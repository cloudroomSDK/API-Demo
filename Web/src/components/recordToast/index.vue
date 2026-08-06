<template>
  <div>
    <p v-if="currentJsonState.size">大小: {{ (currentJsonState.size / 1000000) | keepTwoDecimal }}MB</p>
    <p v-if="currentJsonState.duration">视频时长: {{ parseInt(currentJsonState.duration / 1000) }}秒</p>
    <p>
      状态:
      <span v-if="currentState === 2 || currentState === 4">正在处理...</span>
      <span v-if="currentState === 3 || currentState === 6">录制出错,错误码:{{ currentJsonState.errCode }},{{ currentJsonState.errDesc }}</span>
      <template v-if="currentState === 5">
        <span v-if="downloadUrl">完成</span>
        <span v-else>录制完成,正在查询下载地址...</span>
      </template>
    </p>
    <p v-if="downloadUrl">
      下载地址：<a :href="downloadUrl">{{ downloadUrl }}</a>
    </p>
  </div>
</template>

<script>
import { jsonp } from '@/utils';
import { getToken } from '@/utils/auth';
import Cookies from 'js-cookie';
import MD5 from 'crypto-js/md5';

export default {
  filters: {
    // 四舍五入保留两位小数
    keepTwoDecimal(num) {
      return Math.round(num * 100) / 100;
    },
  },
  props: {
    fileName: {
      type: String,
      required: true,
    },
    state: {
      type: Number,
      required: true,
    },
    jsonState: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      downloadUrl: '',
      currentState: this.state,
      currentJsonState: this.jsonState,
    };
  },
  methods: {
    // 供父组件调用，更新状态
    updateState(state, jsonState) {
      this.currentState = state;
      this.currentJsonState = jsonState;
      if (state === 5) {
        this.getDownload();
      }
    },
    // 调用服务端api，获取录像下载地址
    getDownload() {
      const { AppId, MD5_AppSecret } = JSON.parse(getToken());
      const serverAddr = Cookies.get('addr');
      const data = {
        RequestId: '' + new Date().getTime(),
        fileName: this.fileName,
      };

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
        data['SecretKey'] = MD5(`${CompID}&${CompSecret}`.toString());

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
            this.downloadUrl = data.Data.fileList[0].downUrl;
          } catch (error) {
            this.downloadUrl = '查询失败';
            console.log(error);
          }
        },
        fail: (e) => {},
      });
    },
  },
};
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
