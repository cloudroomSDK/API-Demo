<template>
  <div>
    <div class="user">
      <template v-for="user in memberList">
        <template
          v-if="
            user.videoStatus === 3 &&
              watchList[user.userID] &&
              watchList[user.userID].length
          "
        >
          <div
            v-for="openCamId in watchList[user.userID]"
            :key="`${user.userID}-${openCamId}`"
            :class="isMobile ? 'mobile' : 'desktop'"
            class="user-video"
          >
            <!-- SDKVideo为创建SDK视图容器指令，此处代码不可忽略 -->
            <div
              v-SDKVideo.user="{ UID: user.userID, camId: openCamId }"
              class="video"
            >
              <div class="top">{{ user.nickname }}-{{ openCamId }}</div>
              <div class="bottom">
                <i
                  v-if="user.videoStatus === 3"
                  class="icon icon-cam-open"
                  @click="toggleCam(user.userID, false)"
                />
                <i
                  v-else
                  class="icon icon-cam-close"
                  @click="toggleCam(user.userID, true)"
                />
                <i
                  v-if="user.audioStatus === 3"
                  class="icon icon-mic-open"
                  @click="toggleMic(user.userID, false)"
                />
                <i
                  v-else
                  class="icon icon-mic-mute"
                  @click="toggleMic(user.userID, true)"
                />
              </div>
            </div>
          </div>
        </template>
        <div
          v-else
          :key="`${user.userID}`"
          :class="isMobile ? 'mobile' : 'desktop'"
          class="user-video"
        >
          <div class="video empty">
            <div class="top">{{ user.nickname }}</div>
            <div class="bottom">
              <i
                v-if="user.videoStatus === 3"
                class="icon icon-cam-open"
                @click="toggleCam(user.userID, false)"
              />
              <i
                v-else
                class="icon icon-cam-close"
                @click="toggleCam(user.userID, true)"
              />
              <i
                v-if="user.audioStatus === 3"
                class="icon icon-mic-open"
                @click="toggleMic(user.userID, false)"
              />
              <i
                v-else
                class="icon icon-mic-mute"
                @click="toggleMic(user.userID, true)"
              />
            </div>
          </div>
        </div>
      </template>
      <!-- 放两个i标签是为了解决弹性布局最后一排的的元素能实现左对齐的效果 -->
      <i style="width: 400px" />
      <i style="width: 400px" />
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { difference } from '@/utils'
export default {
  data() {
    return {
      watchList: {}
    }
  },
  computed: {
    ...mapGetters(['UID', 'memberList', 'isMobile'])
  },
  created() {
    this.$SDKCallBack.$on('CRVideo_UserLeftMeeting', this.UserLeftMeeting)
    this.$SDKCallBack.$on('CRVideo_VideoDevChanged', this.VideoDevChanged)
    this.start()
  },
  destroyed() {
    this.$SDKCallBack.$off('CRVideo_UserLeftMeeting', this.UserLeftMeeting)
    this.$SDKCallBack.$off('CRVideo_VideoDevChanged', this.VideoDevChanged)
  },
  methods: {
    start() {
      const watchList = {}
      this.memberList.forEach((item) => {
        const { userID: UID } = item
        watchList[UID] = CRVideo_GetOpenedVideoIDs(UID) // SDK主调接口：获取房间内用户打开的摄像头列表
      })
      this.watchList = watchList
    },
    // 有用户离开通知
    UserLeftMeeting(UID) {
      delete this.watchList[UID]
    },
    // 用户的摄像头设备变化了
    VideoDevChanged(UID) {
      const openCamList = CRVideo_GetOpenedVideoIDs(UID)
      let curCamList = this.watchList[UID] || [] // 当前该用户的观看摄像头列表
      const addArr = difference(openCamList, curCamList) // 计算出新打开的摄像头
      const delArr = difference(curCamList, openCamList) // 计算出新关闭的摄像头
      console.log('openCamList', openCamList)
      console.log('curCamList', curCamList)
      console.log('delArr', delArr)
      console.log('addArr', addArr)

      // 关闭的摄像头,从页面中删除掉
      delArr.forEach((delInx) => {
        curCamList = curCamList.filter((camId) => delInx !== camId)
      })

      // 新打开的摄像头,添加在页面上
      addArr.forEach((addIdx) => {
        curCamList.push(addIdx)
      })
      this.$set(this.watchList, UID, curCamList)
    },
    // 开关摄像头
    toggleCam(UID, operate) {
      operate ? CRVideo_OpenVideo(UID) : CRVideo_CloseVideo(UID) // SDK主调接口：开关摄像头
    },
    // 开关麦克风
    toggleMic(UID, operate) {
      operate ? CRVideo_OpenMic(UID) : CRVideo_CloseMic(UID) // SDK主调接口：开关麦克风
    }
  }
}
</script>

<style lang="scss" scoped>
.user {
  margin-top: 20px;
  margin-bottom: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;

  .user-video {
    margin-bottom: 20px;
    &.desktop {
      width: 400px;
    }
    &.mobile {
      width: 100%;
    }
    .video {
      width: 100%;
      height: 225px;
      color: #fff;
      background-color: #19263d;
      position: relative;
      &.empty::after {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 55px;
        height: 40px;
        transform: translate(-50%, -50%);
        background: url('~@/assets/image/icon/no_video.png') no-repeat;
      }
      .top {
        position: absolute;
        width: 100%;
        height: 32px;
        background-color: rgba(0, 0, 0, 0.6);
        text-align: center;
        color: #fff;
        font-size: 14px;
        line-height: 32px;
        z-index: 1;
      }
      .bottom {
        position: absolute;
        right: 5px;
        bottom: 5px;
        background-color: rgba(0, 0, 0, 0.6);
        display: flex;
        z-index: 1;
        padding: 0 8px;
        border-radius: 16px;
        .icon {
          width: 30px;
          height: 30px;
          cursor: pointer;
          background-repeat: no-repeat;
          &.icon-cam-open {
            background-image: url('~@/assets/image/icon/video_cam_open.png');
          }
          &.icon-cam-close {
            background-image: url('~@/assets/image/icon/video_cam_close.png');
          }
          &.icon-mic-open {
            background-image: url('~@/assets/image/icon/video_mic_open.png');
          }
          &.icon-mic-mute {
            background-image: url('~@/assets/image/icon/video_mic_mute.png');
          }
        }
      }
    }
  }
}
</style>
