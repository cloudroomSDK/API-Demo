<template>
  <div>
    <div class="form">
      <div class="item">
        <div class="label">摄像头：</div>
        <el-select
          v-model="camID"
          :disabled="meetingState !== 2"
          placeholder=""
          @change="camChange"
        >
          <el-option
            v-for="item in camList"
            :key="item.videoID"
            :label="item.videoName"
            :value="item.videoID"
          />
        </el-select>
      </div>
      <div class="item">
        <div class="label">麦克风：</div>
        <el-select
          v-model="micID"
          :disabled="meetingState !== 2"
          placeholder=""
          @change="micChange"
        >
          <el-option
            v-for="item in micList"
            :key="item.micID"
            :label="item.micName"
            :value="item.micID"
          />
        </el-select>
      </div>
      <div class="item">
        <div class="label">房间号：</div>
        <el-input
          :disabled="!!meetingState"
          placeholder="请输入内容"
          :value="value"
          @input="$emit('input', $event)"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  props: {
    value: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      camID: '',
      camList: [],
      micID: '',
      micList: []
    }
  },
  computed: {
    ...mapGetters(['meetingState', 'UID'])
  },
  watch: {
    meetingState(val) {
      if (val === 2) {
        this.camID = CRVideo_GetDefaultVideo(this.UID) // SDK主调接口：获取自己的当前使用的摄像头ID
        this.camList = CRVideo_GetAllVideoInfo(this.UID) // SDK主调接口：获取自己的摄像头列表
        this.micID = CRVideo_GetAudioCfg().micID // SDK主调接口：获取自己当前使用的麦克风ID
        this.micList = CRVideo_GetAudioMicNames() // SDK主调接口：获取自己的麦克风列表
      } else if (val === 0) {
        this.camID = this.micID = ''
      }
    }
  },
  methods: {
    // 选择了其他摄像头
    camChange(camId) {
      CRVideo_SetDefaultVideo(this.UID, camId) // SDK主调接口：切换默认摄像头
    },
    // 选择了其他麦克风
    micChange(micId) {
      CRVideo_SetAudioCfg({ micID: micId }) // SDK主调接口：切换默认麦克风
    }
  }
}
</script>

<style lang="scss" scoped>
.form {
  .item {
    margin-bottom: 20px;
    .label {
      margin-bottom: 8px;
      font-size: 14px;
    }
    .el-select {
      width: 100%;
      height: 20px;
    }
  }
}
</style>
