<template>
  <div>
    <div class="user">
      <template v-for="user in memberList">
        <div
          v-if="user.videoStatus === 3"
          :key="`${user.userID}-open`"
          class="user-video"
          :class="isMobile ? 'mobile' : 'desktop'"
        >
          <!-- SDKVideo为创建SDK视图容器指令，此处代码不可忽略 -->
          <div v-SDKVideo.user="{ UID: user.userID }" class="video">
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
        <div
          v-else
          :key="`${user.userID}-close`"
          class="user-video"
          :class="isMobile ? 'mobile' : 'desktop'"
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
export default {
  data() {
    return {
      watchList: {}
    }
  },
  computed: {
    ...mapGetters(['UID', 'memberList', 'isMobile'])
  },
  methods: {
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
@import '~@/styles/mixin.scss';
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
        @include pic2x {
          background-image: url('~@/assets/image/icon/no_video@2x.png');
        }
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
            @include pic2x {
              background-image: url('~@/assets/image/icon/video_cam_open@2x.png');
            }
          }
          &.icon-cam-close {
            background-image: url('~@/assets/image/icon/video_cam_close.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/video_cam_close@2x.png');
            }
          }
          &.icon-mic-open {
            background-image: url('~@/assets/image/icon/video_mic_open.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/video_mic_open@2x.png');
            }
          }
          &.icon-mic-mute {
            background-image: url('~@/assets/image/icon/video_mic_mute.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/video_mic_mute@2x.png');
            }
          }
        }
      }
    }
  }
}
</style>
