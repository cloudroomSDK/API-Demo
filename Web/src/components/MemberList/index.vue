<template>
  <div>
    <el-collapse v-model="activeNames">
      <el-collapse-item title="成员列表" name="1">
        <div v-if="meetingState === 2" class="memberList">
          <div v-for="item in memberList" :key="item.userID" class="member">
            <span
              class="name text-overflow"
            >{{ item.nickname }}
              <template v-if="item.userID === UID">(我)</template>
            </span>
            <div class="device-icon">
              <i
                v-if="item.videoStatus === 3"
                class="icon icon-cam-open"
                @click="openCam(item.userID, true)"
              />
              <i
                v-else
                class="icon icon-cam-close"
                @click="openCam(item.userID, false)"
              />
              <i
                v-if="item.audioStatus === 3"
                class="icon icon-mic-open"
                @click="openMic(item.userID, true)"
              >
                <i
                  class="voice"
                ><i
                  class="green"
                  :style="{
                    height: voiceDate[item.userID]
                      ? voiceDate[item.userID] * 10 + '%'
                      : 0
                  }"
                /></i>
              </i>
              <i
                v-else
                class="icon icon-mic-close"
                @click="openMic(item.userID, false)"
              />
            </div>
          </div>
        </div>
        <div v-else>请先进入房间</div>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  data() {
    return {
      voiceDate: {}, // 存储麦克风音量大小
      activeNames: ''
    }
  },
  computed: {
    ...mapGetters(['UID', 'meetingState', 'memberList'])
  },
  watch: {
    meetingState(value) {
      this.activeNames = value === 2 ? '1' : ''
    }
  },
  created() {
    this.$SDKCallBack.$on('CRVideo_MicEnergyUpdate', this.MicEnergyUpdate)
  },
  destroyed() {
    this.$SDKCallBack.$off('CRVideo_MicEnergyUpdate', this.MicEnergyUpdate)
  },
  methods: {
    // 点击了开关摄像头
    openCam(UID, curStatue) {
      curStatue ? CRVideo_CloseVideo(UID) : CRVideo_OpenVideo(UID) // SDK主调接口：开关摄像头
    },
    // 点击了开关麦克风
    openMic(UID, curStatue) {
      curStatue ? CRVideo_CloseMic(UID) : CRVideo_OpenMic(UID) // SDK主调接口：开关麦克风
    },
    // 通知麦克风音量变化
    MicEnergyUpdate(UID, oldLevel, newLevel) {
      this.$set(this.voiceDate, UID, newLevel)
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/styles/mixin.scss';
.el-collapse {
  border: 0 none;
  ::v-deep {
    .el-collapse-item__wrap,
    .el-collapse-item__header {
      border: 0 none;
      font-size: 20px;
    }
  }
  .memberList {
    font-size: 16px;
    .member {
      height: 40px;
      line-height: 40px;
      .name {
        display: inline-block;
        max-width: 200px;
      }
      .device-icon {
        float: right;
        height: 100%;
        .icon {
          display: inline-block;
          margin-top: 4px;
          width: 32px;
          height: 32px;
          cursor: pointer;
          &.icon-cam-open {
            background-image: url('~@/assets/image/icon/member_video_open.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/member_video_open@2x.png');
            }
          }
          &.icon-cam-close {
            background-image: url('~@/assets/image/icon/member_video_close.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/member_video_close@2x.png');
            }
          }
          &.icon-mic-open {
            background-image: url('~@/assets/image/icon/member_mic_open.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/member_mic_open@2x.png');
            }
            position: relative;
            .voice {
              position: absolute;
              bottom: 10px;
              left: 10px;
              width: 10px;
              height: 18px;
              border-radius: 5px;
              overflow: hidden;
              .green {
                position: absolute;
                transition: height 0.5s;
                content: '';
                bottom: 0;
                width: 100%;
                background: #2cff10;
              }
            }
          }
          &.icon-mic-close {
            background-image: url('~@/assets/image/icon/member_mic_mute.png');
            @include pic2x {
              background-image: url('~@/assets/image/icon/member_mic_mute@2x.png');
            }
          }
          &:hover {
            background-color: #eee;
          }
        }
      }
    }
  }
}
</style>
