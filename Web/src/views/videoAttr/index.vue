<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId" />
      <div class="videoAttr">
        <div class="select">
          <div class="label">分辨率：</div>
          <el-select
            v-model="videoCfg.size"
            :disabled="meetingState !== 2"
            placeholder=""
            @change="videoCfgChange('size', $event)"
          >
            <el-option
              v-for="item in videoCfgOptions.size"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </div>
        <div class="select">
          <div class="label">视频帧率：</div>
          <el-select
            v-model="videoCfg.fps"
            :disabled="meetingState !== 2"
            placeholder=""
            @change="videoCfgChange('fps', $event)"
          >
            <el-option
              v-for="item in videoCfgOptions.frame"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </div>
        <div class="select">
          <div class="label">视频比例：</div>
          <el-select
            v-model="videoCfg.ratio"
            :disabled="meetingState !== 2"
            placeholder=""
            @change="videoCfgChange('ratio', $event)"
          >
            <el-option
              v-for="item in videoCfgOptions.ratio"
              :key="item.value"
              :label="item.label"
              :value="item.value"
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
      videoCfg: {}, // 视频配置
      videoCfgOptions: {
        size: [
          {
            label: '360P',
            value: 1
          },
          {
            label: '480P',
            value: 2
          },
          {
            label: '720P',
            value: 3
          },
          {
            label: '1080P',
            value: 4
          }
        ],
        frame: [
          {
            label: '5 fps',
            value: 5
          },
          {
            label: '10 fps',
            value: 10
          },
          {
            label: '15 fps',
            value: 15
          },
          {
            label: '20 fps',
            value: 20
          },
          {
            label: '25 fps',
            value: 25
          },
          {
            label: '30 fps',
            value: 30
          }
        ],
        ratio: [
          {
            label: '16/9',
            value: 1
          },
          {
            label: '4/3',
            value: 2
          },
          {
            label: '1/1',
            value: 3
          },
          {
            label: '3/4',
            value: 4
          },
          {
            label: '9/16',
            value: 5
          }
        ]
      }
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
        this.videoCfg = CRVideo_GetVideoCfg()
      }
    }
  },
  methods: {
    // 视频配置发生改变
    videoCfgChange(event, value) {
      CRVideo_SetVideoCfg({ [event]: value })
    }
  }
}
</script>

<style lang="scss" scoped>
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
</style>
