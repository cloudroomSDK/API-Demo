<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          :disabled="meetingState !== 2"
          type="primary"
          @click="openMeetingAttr(null)"
        >房间属性</el-button>
      </ButtonGroup>
      <MeetingAttr @clickMemberAttr="openMeetingAttr" />
      <QRCode v-if="!isMobile" />
    </div>
    <div class="right-container">
      <AttrBox
        v-if="meetingState === 2 && showAttrBox"
        :other-id="openUIDBox"
        @closed="showAttrBox = !showAttrBox"
      />
      <VideoView v-if="meetingState === 2" />
    </div>
  </div>
</template>

<script>
import BaseForm from '@/components/BaseForm'
import ButtonGroup from '@/components/ButtonGroup'
import MeetingAttr from '@/components/meetingAttr'
import AttrBox from '@/components/meetingAttr/attrBox'
import VideoView from '@/components/VideoView'
import RoomIdMixin from '../RoomIdMixin'

import { mapGetters } from 'vuex'

export default {
  components: {
    BaseForm,
    ButtonGroup,
    MeetingAttr,
    QRCode: () => import('@/components/QRCode'),
    AttrBox,
    VideoView
  },
  mixins: [RoomIdMixin],
  data() {
    return {
      showAttrBox: false,
      openUIDBox: null
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
      }
    }
  },
  methods: {
    openMeetingAttr(UID) {
      this.openUIDBox = UID
      this.showAttrBox = true
    }
  }
}
</script>
