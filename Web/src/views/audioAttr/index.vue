<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          type="primary"
          :disabled="meetingState !== 2"
          @click="toggleMute"
        >{{ speakerPause ? '解除静音' : '静音' }}</el-button>
      </ButtonGroup>
      <div class="attr">
        <div class="select">
          <div class="label">扬声器：</div>
          <el-select
            v-model="speakerId"
            :disabled="meetingState !== 2"
            placeholder=""
            @change="speakerChange($event)"
          >
            <el-option
              v-for="item in speakerList"
              :key="item.speakerID"
              :label="item.speakerName"
              :value="item.speakerID"
            />
          </el-select>
        </div>
      </div>

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
  data() {
    return {
      speakerId: null, // 当前扬声器ID
      speakerPause: false, // 静音
      speakerList: [] // 扬声器列表
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
        this.speakerList = CRVideo_GetAudioSpkNames()
        const { speakerID, speakerPause } = CRVideo_GetAudioCfg()
        this.speakerId = speakerID
        this.speakerPause = speakerPause
      }
    }
  },
  methods: {
    // 视频配置发生改变
    speakerChange(speakerId) {
      CRVideo_SetAudioCfg({ speakerID: speakerId })
    },
    // 点击了静音按钮
    toggleMute() {
      this.speakerPause ? CRVideo_PlaySpeaker() : CRVideo_PauseSpeaker()
      this.speakerPause = !this.speakerPause
    }
  }
}
</script>

<style lang="scss" scoped>
.attr {
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
</style>
