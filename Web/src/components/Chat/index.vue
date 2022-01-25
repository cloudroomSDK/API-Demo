<template>
  <div class="chat">
    <div ref="chatList" class="content">
      <div
        v-for="(item, index) in list"
        :key="index"
        class="msg"
        :class="{ mymsg: UID === item.UID }"
      >
        <div class="first">
          <span class="time">{{ item.time | parseTime('HH:mm') }}</span><span v-if="UID !== item.UID">&nbsp;{{ item.UID }}：</span>
        </div>
        <div class="text">{{ item.msg }}</div>
      </div>
    </div>
    <div class="text-input">
      <el-input
        v-model="textarea"
        type="textarea"
        :rows="3"
        resize="none"
        placeholder="请输入内容"
        @keyup.enter.native.capture="send"
      />
      <el-button class="btn" type="primary" plain @click="send">发送</el-button>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  filters: {
    getTimeValue(date) {
      const h = ('0' + date.getHours()).slice(-2)
      const m = ('0' + date.getMinutes()).slice(-2)
      return `${h}:${m}`
    }
  },
  data() {
    return {
      textarea: '',
      list: []
    }
  },
  computed: {
    ...mapGetters(['UID'])
  },
  created() {
    CRVideo_NotifyMeetingCustomMsg.callback = this.NotifyMediaStart // SDK通知接口：通知广播消息
  },
  destroyed() {
    CRVideo_NotifyMeetingCustomMsg.callback = null
  },
  methods: {
    NotifyMediaStart(UID, stringMsg) {
      try {
        // {"CmdType":"IM","IMMsg":"2222"}
        const { CmdType, IMMsg } = JSON.parse(stringMsg)
        if (CmdType === 'IM') {
          this.list.push({
            UID,
            msg: IMMsg,
            time: new Date()
          })
          this.$nextTick(() => {
            this.$refs.chatList.scrollTop = 99999999 // 让滚动条滚动到最底部
          })
        }
      } catch (error) {
        this.$message.warning(`收到广播消息，但不是来自demo约定的数据格式`)
      }
    },
    // 点击了发送按钮
    send() {
      if (!this.textarea.trim()) {
        return this.$message.warning('请输入内容')
      }
      const json = {
        CmdType: 'IM',
        IMMsg: this.textarea
      }
      CRVideo_SendMeetingCustomMsg(JSON.stringify(json))
      this.textarea = ''
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/styles/mixin.scss';
.chat {
  max-height: 550px;
  padding-bottom: 10px;
  background-color: #efefef;
  .content {
    @include scrollBar;
    overflow-y: auto;
    max-height: 448px;
    font-size: 16px;
    line-height: 16px;
    color: #333;
    padding: 10px 30px;
    .msg {
      margin-bottom: 15px;
      &.mymsg {
        // text-align: right;
        @include clearfix;
        .first {
          text-align: right;
        }
        .text {
          float: right;
        }
      }
      .first {
        margin-bottom: 10px;
        .time {
          color: #666;
        }
      }
      .text {
        line-height: 18px;
        max-width: 95%;
      }
    }
  }
  .text-input {
    margin: 0 20px;
    position: relative;
    .btn {
      position: absolute;
      right: 10px;
      bottom: 10px;
      padding: 2px 5px;
      font-size: 16px;
      background-color: transparent;
      border-color: #3981fc;
      color: #3981fc;
      &:hover {
        background-color: #3981fc;
        border-color: #3981fc;
        color: #fff;
      }
      &:focus {
        background-color: #3981fc;
        border-color: #3981fc;
        color: #fff;
      }
    }
  }
}
</style>
