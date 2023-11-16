<template>
    <el-form label-width="140px">
        <el-form-item label="选择麦克风：">
            <el-select class="select" v-model="micSel" :disabled="!micList.length" placeholder="请插入设备" @change="micChange">
                <el-option v-for="item in micList" :key="item._id" :label="item._name" :value="item._id" />
            </el-select>
        </el-form-item>
        <el-form-item label="选择扬声器：">
            <el-select class="select" v-model="speakerSel" :disabled="!speakerList.length" placeholder="请插入设备" @change="speakerChange">
                <el-option v-for="item in speakerList" :key="item._id" :label="item._name" :value="item._id" />
            </el-select>
        </el-form-item>
        <el-form-item label="麦克风采集音量：">
            <el-slider style="margin-right:20px;" v-model="micValue" :max="255" @change="micValChange" />
        </el-form-item>
        <el-form-item label="本地扬声器音量：">
            <el-slider style="margin-right:20px;"  v-model="speakerValue" :max="255" @change="speakerValChange" />
        </el-form-item>
    </el-form>
</template>

<script>
export default {
    data() {
        return {
            micSel: null,
            speakerSel: null,
            micValue: 0,
            speakerValue: 0,
            micList: [], //麦克风列表
            speakerList: [],
        };
    },
    created() {
        this.callbackHanle(true);
        this.init();
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyAudioDevChanged", this.notifyAudioDevChanged);
        },
        init() {
            const audioCfg = this.$rtcsdk.getAudioCfg(); //获取当前音频配置
            const micList = this.$rtcsdk.getAudioMics(); //获取系统麦克风设备列表
            const speakerList = this.$rtcsdk.getAudioSpks(); //获取系统扬声器设备列表
            const micVol = this.$rtcsdk.getMicVolume(); //获取麦克风音量
            const speakerVol = this.$rtcsdk.getSpkVolume(); //获取扬声器音量

            this.micValue = micVol;
            this.speakerValue = speakerVol;

            if (micList.length) {
                this.micList = [
                    {
                        _id: "",
                        _name: "系统默认设备",
                    },
                ].concat(micList);

                this.micSel = audioCfg._micGuid;
            }

            if (speakerList.length) {
                this.speakerList = [
                    {
                        _id: "",
                        _name: "系统默认设备",
                    },
                ].concat(speakerList);

                this.speakerSel = audioCfg._spkGuid;
            }
        },
        // 通知有音频设备变化
        notifyAudioDevChanged() {
            setTimeout(() => {
                this.micSel = null;
                this.micList = [];
                this.speakerSel = null;
                this.speakerList = [];
                this.init();
            }, 100);
        },
        micChange(val) {
            this.editConfig({ _micGuid: val });
            this.micValue = this.$rtcsdk.getMicVolume(); //重新获取本设备的麦克风音量
        },
        speakerChange(val) {
            this.editConfig({ _spkGuid: val });
        },
        editConfig(obj) {
            const audioCfg = this.$rtcsdk.getAudioCfg(); //得到当前音频配置
            //{_micGuid: '', _spkGuid: '', _agc: true, _ans: true, _aec: true}
            this.$rtcsdk.setAudioCfg(Object.assign(audioCfg, obj));
        },
        micValChange(val) {
            this.$rtcsdk.setMicVolume(val);
        },
        speakerValChange(val) {
            this.$rtcsdk.setSpkVolume(val);
        },
    },
};
</script>

<style lang="scss" scoped>
.select {
    width: 100%;
    box-sizing: border-box;
}
</style>
