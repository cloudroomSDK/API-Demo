<template>
  <div>
    <div class="button-container">
      <el-button
        v-if="!meetingState"
        type="primary"
        :loading="creating"
        @click="createRoom"
      >创建</el-button>
      <el-button v-else type="danger" @click="exitRoom">退出</el-button>
      <el-button
        type="primary"
        :disabled="meetingState === 2"
        :loading="meetingState === 1"
        @click="joinRoom"
      >加入</el-button>
      <slot />
    </div>
  </div>
</template>

<script>
import SDKError from '@/SDK/Code'
import Cookies from 'js-cookie'
import { mapGetters } from 'vuex'

const lastRoomId = 'LastRoomId'
export default {
  props: {
    roomId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      creating: false
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'UID'])
  },
  created() {
    this.$SDKCallBack.$on(
      'CRVideo_CreateMeetingSuccess',
      this.CreateMeetingSuccess
    )
    this.$SDKCallBack.$on('CRVideo_CreateMeetingFail', this.CreateMeetingFail)
    this.$SDKCallBack.$on('CRVideo_EnterMeetingRslt', this.EnterMeetingRslt)
    this.$SDKCallBack.$on('CRVideo_MeetingDropped', this.MeetingDropped)
  },
  destroyed() {
    this.$SDKCallBack.$off(
      'CRVideo_CreateMeetingSuccess',
      this.CreateMeetingSuccess
    )
    this.$SDKCallBack.$off('CRVideo_CreateMeetingFail', this.CreateMeetingFail)
    this.$SDKCallBack.$off('CRVideo_EnterMeetingRslt', this.EnterMeetingRslt)
    this.$SDKCallBack.$off('CRVideo_MeetingDropped', this.MeetingDropped)
  },
  methods: {
    // 点击创建按钮
    createRoom() {
      this.creating = true
      CRVideo_CreateMeeting() // SDK主调接口：创建房间
    },
    // 点击加入按钮
    joinRoom() {
      if (!this.roomId || this.roomId.length !== 8) {
        return this.$message.error(
          `请输入8位房间号，如果没有房间号可以先创建房间`
        )
      }
      this.$store.commit('state/SET_MEETING_STATE', 1)
      CRVideo_EnterMeeting3(+this.roomId) // SDK主调接口：进入房间
    },
    // 点击退出按钮
    exitRoom() {
      CRVideo_ExitMeeting() // SDK主调接口：退出房间
      this.$message.success(`您已退出房间`)
      this.$store.commit('state/SET_MEETING_STATE', 0)
    },
    // 创建房间成功
    CreateMeetingSuccess(MeetInfoObj, cookie) {
      this.creating = false
      const roomId = String(MeetInfoObj.ID)
      this.$emit('updateRoomId', roomId)
      // 等待渲染后再进入会议，否则roomId不会更新
      this.$nextTick(() => {
        this.joinRoom() // 进入房间
      })
    },
    // 创建房间失败
    CreateMeetingFail(code, cookie) {
      this.creating = false
      this.$message.error(`创建房间失败，错误码: ${code},${SDKError[code]}`)
    },
    // 进入房间的结果
    EnterMeetingRslt(code, cookie) {
      if (code !== 0) {
        this.$store.commit('state/SET_MEETING_STATE', 0)
        return this.$message.error(
          `进入房间失败，错误码: ${code},${SDKError[code]}`
        )
      }

      Cookies.set(lastRoomId, this.roomId) // 添加cookie，刷新或者下次进入再填充此房间号
      this.$message.success(`已加入房间`)
      this.$store.commit('state/SET_MEETING_STATE', 2)
    },
    // 会议掉线通知
    MeetingDropped(code) {
      this.$message.error(`从房间中掉线了，正在尝试重新进入...`)
      this.$store.commit('state/SET_MEETING_STATE', 1)
      this.joinRoom() // 进入房间
    }
  }
}
</script>

<style lang="scss" scoped>
.form {
  .item {
    margin-bottom: 20px;
    .label {
      margin-bottom: 8px;
      font-size: 14px;
    }
    .el-select {
      width: 100%;
      height: 20px;
    }
  }
}
.button-container {
  display: flex;
  width: 100%;
  flex-wrap: wrap;
  justify-content: space-between;
  margin-bottom: 10px;
  .el-button {
    margin-bottom: 10px;
    width: 48%;
    margin-left: 0;
    &.is-disabled {
      background-color: #c9c9c9;
      border-color: #c9c9c9;
    }
    &.el-button--primary:focus {
      background-color: #3981fc;
    }
  }
}
.videoAttr {
  display: flex;
  flex-direction: column;

  .select {
    display: flex;
    margin-bottom: 10px;
    line-height: 40px;
    font-size: 14px;
    .label {
      width: 100px;
    }
  }
}
::v-deep .upload {
  width: 100%;
  .el-upload {
    width: 100%;
    .el-upload-dragger {
      width: 100%;
      height: 150px;
      &:hover {
        border-color: #3981fc;
      }
      .el-icon-upload {
        margin: 16px 0;
      }
    }
  }
}
</style>
