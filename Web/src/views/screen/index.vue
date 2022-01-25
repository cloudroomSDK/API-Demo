<template>
  <div :class="isMobile ? 'mobile' : 'desktop'">
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || !!shareUID"
          :loading="starting"
          @click="startScreen"
        >开始共享</el-button>
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || !shareUID"
          :loading="stopping"
          @click="stopScreen"
        >停止共享</el-button>
      </ButtonGroup>
      <MemberList />
      <QRCode v-if="!isMobile" />
    </div>
    <div class="right-container">
      <!-- SDKVideo为创建SDK视图容器指令，此处代码不可忽略 -->
      <div v-if="shareUID" ref="screen" v-SDKVideo.screen="shareUID" />
      <el-empty v-else-if="meetingState === 2" description="等待开启屏幕共享" />
    </div>
  </div>
</template>

<script>
import BaseForm from '@/components/BaseForm'
import ButtonGroup from '@/components/ButtonGroup'
import MemberList from '@/components/MemberList'
import SDKError from '@/SDK/Code'
import { mapGetters } from 'vuex'
import RoomIdMixin from '../RoomIdMixin'

export default {
  components: {
    BaseForm,
    ButtonGroup,
    MemberList,
    QRCode: () => import('@/components/QRCode')
  },
  mixins: [RoomIdMixin],
  data() {
    return {
      shareUID: null, // 当前开启共享的UID
      starting: false, // 屏幕共享开始中
      stopping: false // 屏幕共享结束中
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      const defaultData = this.$options.data()
      delete defaultData.roomId
      Object.assign(this.$data, defaultData) // 重置data数据
    }
  },
  created() {
    CRVideo_NotifyScreenShareStarted.callback = this.ScreenShareStarted // SDK通知接口：通知开启了屏幕共享
    CRVideo_NotifyScreenShareStopped.callback = this.NotifyScreenShareStopped // SDK通知接口：通知结束了屏幕共享
    CRVideo_StartScreenShareRslt.callback = this.StartScreenShareRslt // SDK通知接口：通知屏幕共享开启的结果
    CRVideo_StopScreenShareRslt.callback = this.StopScreenShareRslt // SDK通知接口：通知屏幕共享结束的结果
  },
  destroyed() {
    CRVideo_NotifyScreenShareStarted.callback = null
    CRVideo_NotifyScreenShareStopped.callback = null
    CRVideo_StartScreenShareRslt.callback = null
    CRVideo_StopScreenShareRslt.callback = null
  },
  methods: {
    // 点击了开始共享
    startScreen() {
      this.starting = true
      CRVideo_StartScreenShare() // SDK主调接口：开始屏幕共享
    },
    // 点击了结束共享
    stopScreen() {
      this.stopping = true
      CRVideo_StopScreenShare() // SDK主调接口：结束屏幕共享
    },
    // 开始屏幕共享通知,进入已在共享中的房间也会有此通知
    ScreenShareStarted(UID) {
      this.shareUID = UID
    },
    // 结束屏幕共享通知
    NotifyScreenShareStopped() {
      this.shareUID = null
    },
    // 开始屏幕共享的结果
    StartScreenShareRslt(code) {
      this.starting = false
      if (code !== 0) {
        this.$message.error(
          `开启屏幕共享失败，错误码: ${code},${SDKError[code]}`
        )
      }
    },
    // 结束共享的结果
    StopScreenShareRslt() {
      this.stopping = false
    }
  }
}
</script>

<style lang="scss" scoped>
.desktop {
  .el-empty {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }
}
</style>
