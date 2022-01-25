<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || recordState !== 0"
          :loading="recordState === 1"
          @click="clickStartBtn"
        >开始录制</el-button>
        <el-button
          type="danger"
          :disabled="meetingState !== 2 || recordState === 0"
          @click="clickEndBtn"
        >结束录制</el-button>
      </ButtonGroup>
      <div class="block">
        <div class="text">录制清晰度:</div>
        <el-select
          v-model="recordConfig.definition"
          class="right"
          :disabled="meetingState !== 2 || recordState !== 0"
          placeholder=""
        >
          <el-option
            v-for="(item, index) in definitionConfig"
            :key="index"
            :label="item.text"
            :value="index"
          />
        </el-select>
      </div>

      <div class="block">
        <div class="text">录制帧率:</div>
        <el-slider
          v-model="recordConfig.frameRate"
          class="right"
          :min="5"
          :max="30"
          :disabled="meetingState !== 2 || recordState !== 0"
        />
      </div>
      <div class="checkboxGroup">
        <el-checkbox
          v-model="recordConfig.onlyMe" @change="updateContents"
        >只录自己</el-checkbox>
        <el-checkbox
          v-model="recordConfig.showTime" @change="updateContents"
        >录制时戳</el-checkbox>
        <el-checkbox
          v-model="recordConfig.showNickname"
          @change="updateContents"
        >录制昵称水印</el-checkbox>
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
import RecordToast from '@/components/recordToast'
import RoomIdMixin from '../RoomIdMixin'
import { parseTime } from '@/utils'

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
      isMyStart: false, // 我开启的录制
      id: 0, // 当前录制的id
      recordState: 0, // 录制状态 0:未开启，1：启动中，2：录制中
      recordConfig: {
        // 录制配置
        definition: 2, // 清晰度选项，参看definitionConfig
        frameRate: 15, // 录制帧率
        onlyMe: false, // 只录制自己
        showTime: true, // 录制时间
        showNickname: true // 录制昵称
      },
      definitionConfig: [
        // 清晰度
        {
          text: '360p',
          w: 640,
          h: 360,
          bitRate: 400000
        },
        {
          text: '480p',
          w: 856,
          h: 480,
          bitRate: 600000
        },
        {
          text: '720p',
          w: 1280,
          h: 720,
          bitRate: 1200000
        }
      ],
      recordResultToast: []
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'UID', 'memberList', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      // 该组件自动打开摄像头麦克风
      if (newValue === 2) {
        CRVideo_OpenVideo(this.UID) // SDK主调接口：打开摄像头
        CRVideo_OpenMic(this.UID) // SDK主调接口：打开麦克风
      }

      this.recordState = CRVideo_GetSvrMixerState() // SDK主调接口：获取云端录制状态
    },
    memberList: {
      handler() {
        if (this.meetingState === 2 && this.recordState === 2) {
          this.updateContents()
        }
      },
      deep: true
    }
  },
  created() {
    CRVideo_SvrMixerStateChanged.callback = this.SvrMixerStateChanged // SDK回调接口：通知云端录制状态发生了变化
    this.$SDKCallBack.$on('CRVideo_SvrMixerOutputInfo', this.SvrMixerOutputInfo) // SDK回调接口：通知云端录制文件生成进度
  },
  destroyed() {
    CRVideo_SvrMixerStateChanged.callback = null
    this.$SDKCallBack.$off(
      'CRVideo_SvrMixerOutputInfo',
      this.SvrMixerOutputInfo
    )
  },
  methods: {
    clickStartBtn() {
      this.recordState = 1
      this.id++
      const cfgs = this.getCfg(this.id) // 获取生成视频的配置
      const contents = this.getContnets(this.id) // 获取需要录制的内容
      const outputs = this.createOutputs(this.id) // 获取视频输出的配置
      console.log(cfgs, contents, outputs)
      this.isMyStart = true
      CRVideo_StartSvrMixer(cfgs, contents, outputs) // SDK主调接口：开启云端录制
    },
    clickEndBtn() {
      CRVideo_StopSvrMixer() // SDK主调接口：结束云端录制
    },
    // 生成录制文件配置
    getCfg(id) {
      const { definition, frameRate } = this.recordConfig
      const videoConfig = this.definitionConfig[definition]
      const cfg = {
        width: videoConfig.w,
        height: videoConfig.h,
        frameRate: frameRate,
        bitRate: videoConfig.bitRate
      }
      return [
        {
          id,
          streamTypes: 3,
          cfg
        }
      ]
    },
    // 生成录制内容
    getContnets(id) {
      const { onlyMe, definition, showNickname, showTime } = this.recordConfig
      const videoConfig = this.definitionConfig[definition]
      const { w, h } = videoConfig
      const recordList = [] // 需要录制的成员

      if (onlyMe) {
        const myInfo = this.memberList.find((item) => item.userID === this.UID)
        if (myInfo && myInfo.videoStatus === 3) recordList.push(myInfo)
      } else {
        this.memberList.forEach((item) => {
          // 只录制开启摄像头的成员
          if (item.videoStatus === 3) {
            recordList.push(item)
          }
        })
      }

      let row = 0 // 云端录制的分为几行几列
      let col = 0
      if (recordList.length > 9) recordList.length = 9 // 最大录制9个摄像头
      if (recordList.length <= 1) {
        row = 1
        col = 1
      } else if (recordList.length <= 2) {
        row = 1
        col = 2
      } else if (recordList.length <= 4) {
        row = 2
        col = 2
      } else {
        row = 3
        col = 3
      }

      const contents = []
      if (recordList.length) {
        const itemW = w / col // 单个成员视频的宽度
        const itemH = h / row // 单个成员视频的高度
        recordList.forEach((item, idx) => {
          const left = (idx % col) * itemW
          const top = parseInt(idx / col) * itemH
          const width = w / col
          const height = h / row

          // 往录制内容里添加成员视频
          contents.push({
            type: 0,
            left, // 视频的x坐标
            top, // 视频的y坐标
            width, // 视频的宽度
            height, // 视频的高度
            param: {
              camid: `${item.userID}.-1` // -1的意思是录取默认的摄像头
            },
            keepAspectRatio: 1
          })
          // 往录制内容里添加成员昵称
          if (showNickname) {
            contents.push({
              type: 7,
              left: left + 20, // 视频的x坐标
              top: top + 20, // 视频的y坐标
              param: {
                text: `<span style='font-size:14px;color:#e21918'>${item.nickname}</span>`
              }
            })
          }
        })
      } else {
        // 没有成员开启摄像头时，放一段提示文本在视频上
        contents.push({
          type: 7,
          left: w / 2 - 150, // 视频的x坐标
          top: h / 2 - 100, // 视频的y坐标
          width: 300,
          height: 200,
          param: {
            text: `<span style='font-size:30px;color:#ffffff'>暂无成员开启摄像头</span>`
          }
        })
      }

      // 往录制内容里添加时间
      if (showTime) {
        const height = 40
        const width = parseInt(w / 4)
        contents.push({
          type: 4,
          left: w - width - 10,
          top: h - height - 10,
          width,
          height,
          keepAspectRatio: 1
        })
      }
      return [
        {
          id,
          content: contents
        }
      ]
    },
    // 生成录制文件输出配置
    createOutputs(id) {
      // /2022-01-17/2022-01-17_14-12-04_H5_API_69293670.mp4
      const filename =
        parseTime(new Date(), '/YYYY-MM-DD/YYYY-MM-DD_HH-mm-ss') +
        `_H5_API_${this.roomId}.mp4`

      return [
        {
          id,
          output: [
            {
              type: 0,
              filename
            }
          ]
        }
      ]
    },
    // 更新录制内容
    updateContents() {
      if (this.isMyStart) {
        CRVideo_UpdateSvrMixerContent(this.getContnets(this.id)) // SDK主调接口：更新云端录制内容
      }
    },
    // 通知云端录制状态变化
    SvrMixerStateChanged(MIXER_STATE, code) {
      this.recordState = MIXER_STATE
    },
    // 云端录制文件、云端直播推流信息变化
    SvrMixerOutputInfo(MixerOutputInfo) {
      if (MixerOutputInfo.state === 2) {
        this.recordResultToast.push(MixerOutputInfo)
        const element = this.$createElement(RecordToast, {
          props: {
            info: MixerOutputInfo
          }
        })
        this.$notify({
          title: MixerOutputInfo.fileName,
          duration: 0,
          message: element
        })
      } else {
        const idx = this.recordResultToast.findIndex(
          (item) => item.id === MixerOutputInfo.id
        )
        if (idx > -1) {
          this.recordResultToast[idx].state = MixerOutputInfo.state
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.block {
  display: flex;
  align-items: center;
  height: 50px;
  .text {
    width: 100px;
  }
  .right {
    flex: 1;
  }
}
.checkboxGroup {
  line-height: 30px;
  .el-checkbox {
    width: 50%;
    margin-right: 0;
    ::v-deep .el-checkbox__input.is-checked + .el-checkbox__label {
      color: #3981fc;
    }
    ::v-deep .el-checkbox__input.is-checked .el-checkbox__inner,
    .el-checkbox__input.is-indeterminate .el-checkbox__inner {
      background-color: #3981fc;
      border-color: #3981fc;
    }
  }
}
</style>
