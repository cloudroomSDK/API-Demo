<template>
  <div>
    <div class="control">
      <BaseForm v-model="roomId" />
      <ButtonGroup :room-id="roomId" @updateRoomId="updateRoomId">
        <el-form ref="form" :model="form" class="form" :rules="rules" @submit.native.prevent="submitForm()">
          <el-form-item v-for="item in addrList" :key="item.addr" prop="addr" class="formItem">
            <el-input v-model="item.addr" class="input" disabled />
            <el-button v-if="item.state === 0" type="primary" disabled loading>
              邀请中
            </el-button>
            <el-button v-else-if="item.state === 1" type="primary" @click="invite(item.addr)">
              重邀
            </el-button>
            <el-button v-else-if="item.state === 2" type="danger" @click="kickout(item)">
              踢出
            </el-button>
          </el-form-item>
          <el-form-item prop="addr" class="formItem">
            <el-input v-model="form.addr" class="input" placeholder="请输入设备地址" :disabled="meetingState !== 2" />
            <el-button type="primary" :disabled="meetingState !== 2" @click="submitForm">
              邀请
            </el-button>
          </el-form-item>
        </el-form>
        <div class="des">
          <p class="title">设备地址格式：</p>
          <p>rtsp://192.168.1.1:554/live</p>
          <p>rtmp://192.168.1.1/live</p>
          <p>onvif://admin:8888@192.168.1.1:8080/live</p>
          <p>gb28181:44010200402000000123</p>
        </div>
      </ButtonGroup>
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
import RTCSDK from '@/SDK'

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
    var validateAddr = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请输入设备地址'))
      } else if (!value.match(/^((rtmp|rtsp|onvif):\/\/|gb28181:).+/)) {
        callback(new Error('设备地址格式不正确'))
      } else {
        callback()
      }
    }
    return {
      addrList: [],
      form: {
        addr: ''
      },
      rules: {
        addr: [{ validator: validateAddr, trigger: 'blur' }]
      }
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'memberList', 'UID', 'isMobile'])
  },
  watch: {
    meetingState(newValue) {
      // 该组件自动打开摄像头麦克风
      if (newValue === 2) {
        RTCSDK.OpenVideo(this.UID) // SDK主调接口：打开摄像头
        RTCSDK.OpenMic(this.UID) // SDK主调接口：打开麦克风
      }
      if (newValue === 0) {
        this.addrList = []
      }
    }
  },
  created() {
    this.$SDKCallBack.$on('OpenVideoFailed', this.OpenVideoFailed)
    this.$SDKCallBack.$on('UserLeftMeeting', this.UserLeftMeeting)
    RTCSDK.NotifyInviteAccepted.callback = this.NotifyInviteAccepted // SDK通知接口：对端接受邀请
    RTCSDK.InviteFail.callback = this.InviteFail // SDK通知接口：邀请失败
    RTCSDK.NotifyInviteRejected.callback = this.NotifyInviteRejected // SDK通知接口：邀请被拒绝
    RTCSDK.NotifyInviteCanceled.callback = this.NotifyInviteCanceled // SDK通知接口：邀请已经被取消了
  },
  destroyed() {
    this.$SDKCallBack.$off('OpenVideoFailed', this.OpenVideoFailed)
    this.$SDKCallBack.$off('UserLeftMeeting', this.UserLeftMeeting)
    RTCSDK.NotifyInviteAccepted.callback = null
    RTCSDK.InviteFail.callback = null
    RTCSDK.NotifyInviteRejected.callback = null
    RTCSDK.NotifyInviteCanceled.callback = null
  },
  methods: {
    invite(addr) {
      // 被邀请的监控设备的url
      const targetUrl = addr
      const usrExtDat = {
        meeting: { ID: this.roomId }, // xxx为会议号
        devInfo: {
          userID: addr, // userID为用户唯一ID（UserID）
          nickName: addr
          // autoOpenSpk: 1,
        }
      }
      const inviteID = RTCSDK.Invite(targetUrl, JSON.stringify(usrExtDat))

      const item = this.addrList.find((item) => item.addr === targetUrl)
      if (item) {
        item.inviteID = inviteID
        item.state = 0
      } else {
        this.addrList.push({ addr, inviteID, state: 0 })
      }
    },
    submitForm() {
      this.$refs.form.validate((valid) => {
        if (valid) {
          const userInfo = this.memberList.findIndex(item => item.userID === this.form.addr)
          if (userInfo > -1) {
            this.$message.error('该用户已在房间内')
            return
          }

          this.invite(this.form.addr)
          this.form.addr = ''
        } else {
          return false
        }
      })
    },
    OpenVideoFailed(errDesc) {
      this.$message.error(
        '打开摄像头失败,可能的原因有：设备被占用、用户未授权访问、硬件设备发生错误等'
      )
    },
    UserLeftMeeting(UID) {
      const idx = this.addrList.findIndex((item) => item.addr === UID)
      if (idx > -1) {
        this.addrList.splice(idx, 1)
      }
    },
    kickout(info) {
      RTCSDK.Kickout(info.addr)
      const idx = this.addrList.findIndex((item) => item === info)
      if (idx > -1) {
        this.addrList.splice(idx, 1)
      }
    },
    NotifyInviteAccepted(inviteID, userExtDat) {
      const item = this.addrList.find((item) => item.inviteID === inviteID)
      if (!item) return
      item.state = 2
    },
    InviteFail(inviteID, sdkErr) {
      const item = this.addrList.find((item) => item.inviteID === inviteID)
      if (!item) return
      item.state = 1
      this.$message.error(`邀请失败,错误码：${sdkErr}`)
    },
    NotifyInviteRejected(inviteID, sdkErr) {
      const item = this.addrList.find((item) => item.inviteID === inviteID)
      if (!item) return
      item.state = 1
      this.$message.error(`邀请被拒绝,错误码：${sdkErr}`)
    },
    NotifyInviteCanceled(inviteID, sdkErr) {
      const item = this.addrList.find((item) => item.inviteID === inviteID)
      if (!item) return
      item.state = 1
      this.$message.error(`邀请被取消,错误码：${sdkErr}`)
    }
  }
}
</script>

<style lang="scss" scoped>
.control {
  ::v-deep .form {
    width: 100%;
    margin-bottom: 10px;

    .el-form-item__content {
      display: flex;
      width: 100%;

      .input {
        flex: 1;
        margin-right: 4px;
      }
    }
  }

  .des {
    p {
      font-size: 14px;
      line-height: 20px;
      margin: 0;

      &.title {
        font-size: 16px;
      }
    }
  }
}
</style>
