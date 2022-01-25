<template>
  <div :class="isMobile ? 'mobile' : 'desktop'">
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || !isMyShare || !shareUID || !isPause"
          @click="pauseMedia"
        >播放</el-button>
        <el-button
          type="primary"
          :disabled="meetingState !== 2 || !isMyShare || !shareUID || isPause"
          @click="pauseMedia"
        >暂停</el-button>
      </ButtonGroup>
      <el-upload
        class="upload"
        drag
        :multiple="false"
        :auto-upload="false"
        action="sdk.cloudroom.com"
        :on-change="handleUploadChange"
        :on-remove="handleUploadRemove"
        accept="video/*"
      >
        <i class="el-icon-upload" />
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <div class="el-upload__text">只能上传媒体文件</div>
      </el-upload>
      <MemberList />
      <QRCode v-if="!isMobile" />
    </div>
    <div class="right-container">
      <div v-if="shareUID" v-SDKVideo.media="{ shareUID, curPlayFile }" />
      <el-empty v-else-if="meetingState === 2" description="等待开启影音共享" />
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
      shareUID: null, // 当前共享中的UID
      curPlayFile: null, // 当前播放的文件
      isPause: false, // 暂停中
      isMyShare: false // 自己开启的共享
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'UID', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      const defaultData = this.$options.data()
      delete defaultData.roomId
      Object.assign(this.$data, defaultData) // 重置data数据
    }
  },
  created() {
    CRVideo_NotifyMediaStart.callback = this.NotifyMediaStart // SDK通知接口：通知开启了影音共享
    CRVideo_NotifyMediaStop.callback = this.NotifyMediaStop // SDK通知接口：通知结束了影音共享
    CRVideo_NotifyMediaPause.callback = this.NotifyMediaPause // SDK通知接口：通知影音共享暂停了
  },
  destroyed() {
    CRVideo_NotifyMediaStart.callback = null
    CRVideo_NotifyMediaStop.callback = null
    CRVideo_NotifyMediaPause.callback = null
  },
  methods: {
    // 点击了播放或者暂停
    pauseMedia() {
      CRVideo_PausePlayMedia(!this.isPause) // SDK主调接口：暂停屏幕共享
      this.isPause = !this.isPause
    },
    // 开始屏幕共享通知,进入已在共享中的房间也会有此通知
    NotifyMediaStart(UID) {
      if (UID === this.UID) return // 自己开启的共享在点击按钮的时候已经创建过媒体组件了
      this.shareUID = UID
      this.isMyShare = false
      const mediaInfo = CRVideo_GetMediaInfo() // SDK通知接口：获取影音共享信息
      this.isPause = Boolean(mediaInfo.state)
    },
    // 结束屏幕共享通知
    NotifyMediaStop() {
      this.shareUID = null
      this.curPlayFile = null

      // 如果是替换影音文件，结束后立马播放新的文件
      this.nextPlayMedia &&
        this.$nextTick(() => {
          this.startMedia(this.nextPlayMedia)
          this.nextPlayMedia = null
        })
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
    // 影音共享暂停通知
    NotifyMediaPause(UID, status) {
      this.isPause = Boolean(status)
    },
    // 结束共享的结果
    StopScreenShareRslt() {
      this.stopping = false
    },
    // 开始播放影音共享
    startMedia(file) {
      this.selectMediaFiles = file
      this.shareUID = this.UID
      this.curPlayFile = file
      this.isMyShare = true
      this.isPause = false
    },
    // 添加文件自动播放影音
    handleUploadChange(files, fileList) {
      // 不在房间内禁止上传文件
      if (this.meetingState !== 2) {
        fileList.shift()
        this.$message.warning('请先进入房间')
        return
      }
      if (fileList.length >= 2) {
        fileList.shift()
      }
      if (this.shareUID) {
        CRVideo_StopPlayMedia() // SDK主调接口：结束影音共享
        this.shareUID = null
        this.curPlayFile = null
        this.isMyShare = null
        this.nextPlayMedia = files.raw // 如果当前正在共享中，那么等结束通知来了之后再开启共享
      } else {
        this.startMedia(files.raw)
      }
    },
    // 移除文件
    handleUploadRemove(files, fileList) {
      if (this.shareUID) {
        CRVideo_StopPlayMedia() // SDK主调接口：结束影音共享
        this.shareUID = null
        this.curPlayFile = null
      }
    }
  }
}
</script>

<style lang="scss" scoped>
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

.desktop {
  .el-empty {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }
}
</style>
