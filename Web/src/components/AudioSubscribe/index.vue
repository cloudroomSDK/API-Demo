<template>
  <div class="audioSubscribe" :class="isMobile ? 'mobile' : 'desktop'">
    <el-radio-group v-model="mode" @change="modeChange">
      <el-radio :label="0" size="large">混流模式</el-radio>
      <el-radio :label="1" size="large">独立流模式</el-radio>
    </el-radio-group>

    <el-form :disabled="mode === 0">
      <el-form-item>
        <el-radio-group v-model="listType" @change="refershSubscribeList">
          <el-radio :label="0" size="large">白名单</el-radio>
          <el-radio :label="1" size="large">黑名单</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item>
        <el-transfer v-model="list" :data="allList" :titles="['房间人员', '名单列表']" @change="refershSubscribeList">
          <template #left-empty>
            <el-empty :image-size="60" description="No data" />
          </template>
          <template #right-empty>
            <el-empty :image-size="60" description="No data" />
          </template>
        </el-transfer>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import RTCSDK from '@/SDK'

export default {
  data() {
    return {
      mode: RTCSDK.GetAudioSubscribeMode(), // 音频订阅模式 0-混流模式 1-独立流模式
      listType: 0, // 音频订阅名单类型 0-白名单 1-黑名单
      list: [] // 音频订阅名单
    }
  },
  computed: {
    ...mapGetters(['UID', 'memberList', 'isMobile']),
    allList() {
      return this.memberList
        .filter((item) => item.userID !== this.UID)
        .map((item) => ({
          key: item.userID,
          label: item.nickname
        }))
    }
  },
  destroyed() {
    RTCSDK.SetAudioSubscribeMode(0)
    RTCSDK.SetAudioSubscribeList([], 0)
  },
  methods: {
    // 音频订阅模式切换
    modeChange(value) {
      console.log(value)
      this.mode = value
      RTCSDK.SetAudioSubscribeMode(value)
      this.refershSubscribeList()
    },
    refershSubscribeList() {
      RTCSDK.SetAudioSubscribeList(this.list, this.listType)
    }
  }
}
</script>

<style lang="scss" scoped>
.audioSubscribe {
  padding: 10px;
  display: inline-block;
  width: 100%;

  ::v-deep .el-transfer {
    display: flex;
    flex-wrap: nowrap;
    align-items: center;
    .el-transfer-panel {
      flex: 1;
      width: unset;
    }
    .el-transfer__buttons {
      padding: 0 10px;
      .el-button {
        display: block;
        margin-left: 0;
        padding: 0;
        margin: 10px 0;
        width: 36px;
        height: 36px;
      }
    }
  }

  &.mobile {
    ::v-deep .el-transfer {
      margin: 0 -36px;
      width: calc(100% + 72px);
    }
  }
}
</style>
