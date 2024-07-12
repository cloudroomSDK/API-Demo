<template>
    <el-form :model="form" label-width="140px">
        <el-form-item label="选择摄像头：">
            <el-select class="select" v-model="form.camSel" @change="camChange" :disabled="!camList.length"
                placeholder="请插入设备">
                <el-option v-for="cam in camList" :key="cam._videoID" :label="cam._devName" :value="cam._videoID" />
            </el-select>
        </el-form-item>
        <el-form-item label="分辨率：">
            <el-select class="select" v-model="form.ratioSel" @change="rateChange">
                <el-option v-for="(rate, idx) in rateConfigs" :key="idx" :label="rate.name" :value="idx"></el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="帧率：" class="slider">
            <el-slider v-model="form.fps" :max="30" :show-tooltip="false" @change="fpsChange" /><span class="text">{{
                form.fps }}fps</span>
        </el-form-item>
        <el-form-item label="码率：" class="slider">
            <el-slider v-model="form.rate" :max="form.maxRatio" :min="form.minRatio" :step="form.ratioStep"
                :show-tooltip="false" @change="ratioChange" />
            <span class="text">{{ form.rate }}kbps</span>
        </el-form-item>
        <el-radio-group style="text-align: center; width: 100%; display: block" v-model="form.maxQb" @change="maxQbChange">
            <el-radio :label="22" size="large">画质优先</el-radio>
            <el-radio :label="40" size="large">流畅优先</el-radio>
        </el-radio-group>
    </el-form>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
export default {
    data() {
        return {
            form: {
                camSel: null,
                fps: 20,
                rate: 350,
                ratioSel: 0,
                ratioStep: 35,
                minRatio: 175,
                maxRatio: 700,
                maxQb: 22,
            },
            camList: [],
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
        rateConfigs() {
            return this.appStore.rateConfigs;
        },
    },
    created() {
        const config = JSON.parse(this.$rtcsdk.getVideoCfg());
        this.form.fps = config.fps;
        this.form.rate = parseInt(config.maxbps / 1000);
        this.form.maxQb = config.qp_max;

        const videoHeight = +config.size.split("*").pop(); //截取当前视频高度

        const idx = this.rateConfigs.findIndex((item) => item.height === videoHeight);
        if (idx > -1) {
            this.form.ratioSel = idx;
            this.form.minRatio = this.rateConfigs[idx].minRatio;
            this.form.maxRatio = this.rateConfigs[idx].maxRatio;
            this.form.ratioStep = this.rateConfigs[idx].ratioStep;
        }

        this.form.camSel = this.$rtcsdk.getDefaultVideo(this.appStore.myUserId) || null; //获取当前显示的默认摄像头
        this.camList = this.$rtcsdk.getAllVideoInfo(this.appStore.myUserId); //获取所有摄像头列表
    },
    methods: {
        // 改变默认摄像头
        camChange(camId) {
            this.$rtcsdk.setDefaultVideo(camId); //设置当前显示的默认摄像头
        },
        // 改变fps
        fpsChange(value) {
            const config = JSON.parse(this.$rtcsdk.getVideoCfg());
            config.fps = value;

            this.$rtcsdk.setVideoCfg(JSON.stringify(config)); //配置摄像头
        },
        // 改变分辨率
        rateChange(value) {
            const videoConfig = this.rateConfigs[value];

            this.form.minRatio = videoConfig.minRatio;
            this.form.maxRatio = videoConfig.maxRatio;
            this.form.ratioStep = videoConfig.ratioStep;
            this.form.rate = videoConfig.defaultRatio;

            const config = JSON.parse(this.$rtcsdk.getVideoCfg());
            config.maxbps = videoConfig.defaultRatio * 1000;
            config.size = `${videoConfig.width}*${videoConfig.height}`;

            this.$rtcsdk.setVideoCfg(JSON.stringify(config)); //配置摄像头
        },
        // 改变码率
        ratioChange(value) {
            const config = JSON.parse(this.$rtcsdk.getVideoCfg());
            config.maxbps = value * 1000;

            this.$rtcsdk.setVideoCfg(JSON.stringify(config)); //配置摄像头
        },
        maxQbChange(value) {
            const config = JSON.parse(this.$rtcsdk.getVideoCfg());
            config.qp_max = value;

            this.$rtcsdk.setVideoCfg(JSON.stringify(config)); //配置摄像头
        },
    },
};
</script>

<style lang="scss" scoped>
.select {
    width: 100%;
}

.slider {
    .el-form-item__content {
        .el-slider {
            flex: 1;
            margin-right: 20px;
        }

        .text {
            width: 70px;
            text-align: right;
        }
    }
}
</style>
