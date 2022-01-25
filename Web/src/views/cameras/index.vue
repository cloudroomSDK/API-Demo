<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || isCameras"
          @click="toggleCameras(true)"
        >启动多摄像头</el-button>
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || !isCameras"
          @click="toggleCameras(false)"
        >关闭多摄像头</el-button>
      </ButtonGroup>
      <MemberList />
      <QRCode v-if="!isMobile" />
    </div>
    <div class="right-container">
      <MultipleCameras v-if="meetingState === 2" />
    </div>
  </div>
</template>

<script>
import BaseForm from '@/components/BaseForm'
import ButtonGroup from '@/components/ButtonGroup'
import MemberList from '@/components/MemberList'
import MultipleCameras from '@/components/MultipleCameras'
import RoomIdMixin from '../RoomIdMixin'

import { mapGetters } from 'vuex'

export default {
  components: {
    BaseForm,
    ButtonGroup,
    MemberList,
    QRCode: () => import('@/components/QRCode'),
    MultipleCameras
  },
  mixins: [RoomIdMixin],
  data() {
    return {
      isCameras: false // 启动多摄像头
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'UID', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      // 该组件自动打开摄像头麦克风
      if (newValue === 2) {
        CRVideo_OpenVideo(this.UID) // SDK主调接口：打开摄像头
        CRVideo_OpenMic(this.UID) // SDK主调接口：打开麦克风

        // 掉线重登后，根据当前状态是否开启多摄像头
        if (this.isCameras) {
          this.toggleCameras(true)
        }
      }
    }
  },
  methods: {
    toggleCameras(bool) {
      CRVideo_SetEnableMutiVideo(this.UID, bool)
      this.isCameras = bool
    }
  }
}
</script>
