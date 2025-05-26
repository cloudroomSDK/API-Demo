<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId" />
      <MemberList />
      <QRCode v-if="!isMobile" />
    </div>
    <div class="right-container">
      <VideoView v-if="meetingState === 2" />
    </div>
  </div>
</template>

<script>
import BaseForm from '@/components/BaseForm'
import ButtonGroup from '@/components/ButtonGroup'
import MemberList from '@/components/MemberList'
import VideoView from '@/components/VideoView'
import RoomIdMixin from '../RoomIdMixin'
import RTCSDK from '@/SDK'

import { mapGetters } from 'vuex'

export default {
  components: {
    BaseForm,
    ButtonGroup,
    MemberList,
    QRCode: () => import('@/components/QRCode'),
    VideoView
  },
  mixins: [RoomIdMixin],
  computed: {
    ...mapGetters(['meetingState', 'UID', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      // 该组件自动打开摄像头麦克风
      if (newValue === 2) {
        RTCSDK.OpenVideo(this.UID) // SDK主调接口：打开摄像头
        RTCSDK.OpenMic(this.UID) // SDK主调接口：打开麦克风
      }
    }
  },
  created() {
    this.$SDKCallBack.$on('OpenVideoFailed', this.OpenVideoFailed)
  },
  destroyed() {
    this.$SDKCallBack.$off('OpenVideoFailed', this.OpenVideoFailed)
  },
  methods: {
    OpenVideoFailed(errDesc) {
      this.$message.error('打开摄像头失败,可能的原因有：设备被占用、用户未授权访问、硬件设备发生错误等')
    }
  }
}
</script>
