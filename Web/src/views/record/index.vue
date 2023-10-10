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
        >结束录制
        </el-button>
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
          v-model="recordConfig.onlyMe" @change="updateLayout"
        >只录自己</el-checkbox>
        <el-checkbox
          v-model="recordConfig.showTime" @change="updateLayout"
        >录制时戳</el-checkbox>
        <el-checkbox
          v-model="recordConfig.showNickname" @change="updateLayout"
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
import SDKError from '@/SDK/Code'
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
      mixerId: null, // 当前录制的id
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
          W: 640,
          H: 360,
          bitRate: 400000
        },
        {
          text: '480p',
          W: 856,
          H: 480,
          bitRate: 600000
        },
        {
          text: '720p',
          W: 1280,
          H: 720,
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
        this.updateRecordState() // 更新录制状态
      }
    },
    memberList: {
      handler() {
        if (this.meetingState === 2) {
          this.updateLayout()
        }
      },
      deep: true
    }
  },
  created() {
    CRVideo_CreateCloudMixerFailed.callback = this.CreateCloudMixerFailed // SDK回调接口：启动云端录制、云端直播失败通知
    CRVideo_CloudMixerStateChanged.callback = this.CloudMixerStateChanged // SDK回调接口：通知云端录制状态发生了变化
    CRVideo_CloudMixerOutputInfoChanged.callback =
      this.CloudMixerOutputInfoChanged // SDK回调接口：通知云端录制文件生成进度
  },
  destroyed() {
    CRVideo_CreateCloudMixerFailed.callback = null
    CRVideo_CloudMixerOutputInfoChanged.callback = null
    CRVideo_CloudMixerStateChanged.callback = null
  },
  methods: {
    // 更新录制状态
    updateRecordState() {
      // SDK主调接口：获取云端录制状态
      CRVideo_GetAllCloudMixerInfo().some((item) => {
        if (item.owner === this.UID) {
          this.mixerId = item.ID
          this.recordState = item.state
          if (item.state === 2) {
            this.updateLayout()
          }
          return true
        }
      })
    },
    clickStartBtn() {
      const { definition, frameRate, onlyMe } = this.recordConfig
      const { W, H, bitRate } = this.definitionConfig[definition]

      const svrPathName =
        parseTime(new Date(), '/YYYY-MM-DD/YYYY-MM-DD_HH-mm-ss') +
        `_Web_API_${this.roomId}.mp4`
      const cfg = {
        mode: 0, // 录制合流模式
        videoFileCfg: {
          svrPathName,
          vWidth: W,
          vHeight: H,
          vFps: frameRate,
          vBps: bitRate,
          aChannelContent: onlyMe ? [this.UID] : [], // 如果只录制自己，则声音也只录制自己的
          layoutConfig: this.createVideoLayout()
        }
      }
      this.mixerId = CRVideo_CreateCloudMixer(cfg) // SDK主调接口：创建云端混图器
      this.recordState = 1
    },
    clickEndBtn() {
      CRVideo_DestroyCloudMixer(this.mixerId) // SDK主调接口：消毁云端混图器
    },
    // 创建录制内容
    createVideoLayout() {
      const { onlyMe, definition, showNickname, showTime } = this.recordConfig
      const videoConfig = this.definitionConfig[definition]
      const { W, H } = videoConfig
      const recordMemberList = [] // 成员列表

      if (onlyMe) {
        // 只录制自己
        const myInfo = this.memberList.find((item) => item.userID === this.UID)
        if (myInfo && myInfo.videoStatus === 3) recordMemberList.push(myInfo)
      } else {
        // 只录制开启摄像头的成员
        this.memberList.forEach((item) => {
          if (item.videoStatus === 3) {
            recordMemberList.push(item)
          }
        })
      }

      let row = 0 // 云端录制的分为几行几列
      let col = 0
      if (recordMemberList.length > 9) recordMemberList.length = 9 // 最大录制9个摄像头
      if (recordMemberList.length <= 1) {
        row = 1
        col = 1
      } else if (recordMemberList.length <= 2) {
        row = 1
        col = 2
      } else if (recordMemberList.length <= 4) {
        row = 2
        col = 2
      } else {
        row = 3
        col = 3
      }

      const layout = [] // 录制的视图内容
      if (recordMemberList.length) {
        const itemW = W / col // 单个成员视频的宽度
        const itemH = H / row // 单个成员视频的高度
        recordMemberList.forEach((item, idx) => {
          const left = (idx % col) * itemW
          const top = parseInt(idx / col) * itemH
          const width = W / col
          const height = H / row

          // 往录制内容里添加成员视频
          layout.push({
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
            layout.push({
              type: 10,
              left: left + 20, // 视频的x坐标
              top: top + 20, // 视频的y坐标
              param: {
                color: '#e21918',
                'font-size': 14,
                text: item.nickname
              }
            })
          }
        })
      } else {
        // 没有成员开启摄像头时，放一段提示文本在视频上
        layout.push({
          type: 10,
          left: W / 2 - 150, // 视频的x坐标
          top: H / 2 - 100, // 视频的y坐标
          param: {
            color: '#ffffff',
            'font-size': 30,
            text: '暂无成员开启摄像头'
          }
        })
      }

      // 往录制内容里添加时间
      if (showTime) {
        layout.push({
          type: 10,
          left: W - 340,
          top: H - 50,
          param: {
            color: '#ffffff',
            'font-size': 18,
            text: '%timestamp%'
          }
        })
      }
      return layout
    },
    // 更新录制内容
    updateLayout() {
      if (this.recordState !== 2) return

      const { onlyMe } = this.recordConfig
      const cloudMixerCfg = {
        videoFileCfg: {
          aChannelContent: onlyMe ? [this.UID] : [], // 如果只录制自己，则声音也只录制自己的
          layoutConfig: this.createVideoLayout()
        }
      }

      CRVideo_UpdateCloudMixerContent(this.mixerId, cloudMixerCfg) // SDK主调接口：更新云端混图器
    },
    // 启动云端录制、云端直播失败通知
    CreateCloudMixerFailed(mixerID, sdkErr) {
      if (mixerID !== this.mixerId) return
      this.mixerId = null
      this.recordState = 0

      this.$message({
        message: `启动录制失败！错误码：${sdkErr},${SDKError[sdkErr]}`,
        type: 'error'
      })
    },
    // 云端录制、云端直播状态变化通知
    CloudMixerStateChanged(mixerID, state, exParam, operUserID) {
      if (mixerID !== this.mixerId) return
      this.recordState = state
    },
    // 云端录制文件、云端直播推流信息变化
    CloudMixerOutputInfoChanged(mixerID, outputInfo) {
      if (mixerID !== this.mixerId) return
      switch (outputInfo.state) {
        case 2: {
          this.recordResultToast.push(outputInfo)
          const element = this.$createElement(RecordToast, {
            props: {
              info: outputInfo
            }
          })
          this.$notify({
            title: outputInfo.fileName,
            duration: 0,
            message: element
          })
          break
        }
        case 3:
          this.$message({
            message: `录制出错！错误码：${outputInfo.errCode},${outputInfo.errDesc}`,
            type: 'error'
          })
          break
        case 6:
          // stateStr = '上传失败'
          break

        default: {
          const idx = this.recordResultToast.findIndex(
            (item) => item.id === outputInfo.id
          )
          if (idx > -1) {
            this.recordResultToast[idx].state = outputInfo.state
          }
          break
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
