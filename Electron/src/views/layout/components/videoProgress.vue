<template>
    <div class="context">
        <svg class="btn" @click="videoPause" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" data-v-ea893728="">
            <path v-if="!isPause" fill="currentColor" d="M512 64a448 448 0 1 1 0 896 448 448 0 0 1 0-896zm0 832a384 384 0 0 0 0-768 384 384 0 0 0 0 768zm-96-544q32 0 32 32v256q0 32-32 32t-32-32V384q0-32 32-32zm192 0q32 0 32 32v256q0 32-32 32t-32-32V384q0-32 32-32z"></path>
            <path v-else fill="currentColor" d="M512 64a448 448 0 1 1 0 896 448 448 0 0 1 0-896zm0 832a384 384 0 0 0 0-768 384 384 0 0 0 0 768zm-48-247.616L668.608 512 464 375.616v272.768zm10.624-342.656 249.472 166.336a48 48 0 0 1 0 79.872L474.624 718.272A48 48 0 0 1 400 678.336V345.6a48 48 0 0 1 74.624-39.936z"></path>
        </svg>
        <el-slider v-model="time" :max="totalTime" @input="changeCurrentTime" class="slider" :show-tooltip="false"></el-slider>
        <span class="time">{{ format() }}</span>
        <div class="text"><slot></slot></div>
    </div>
</template>
<script>
import { parseTime } from "@/utils";
export default {
    data() {
        return {
            time: 0,
            isPause: false, //当前是暂停状态
        };
    },
    watch: {
        curTime(newVal) {
            this.time = newVal;
        },
    },
    computed: {
        percentage() {
            return parseInt((this.time / this.totalTime) * 100);
        },
    },
    props: {
        curTime: Number,
        totalTime: Number,
    },
    methods: {
        format() {
            const time = parseTime(this.time, "mm:ss");
            const totalTime = parseTime(this.totalTime, "mm:ss");
            return `${time}/${totalTime}`;
        },
        changeCurrentTime(val) {
            this.$rtcsdk.setMediaPlayPos(val);
        },
        videoPause() {
            this.isPause = !this.isPause;
            this.$rtcsdk.pausePlayMedia(this.isPause);
        },
    },
};
</script>
<style lang="scss" scoped>
.context {
    position: absolute;
    bottom: 0;
    height: 40px;
    width: 100%;
    background-color: rgba(0, 0, 0, 0.4);
    color: #fff;
    display: flex;
    // justify-content: center;
    align-items: center;
    padding: 0 10px;
    .btn {
        width: 30px;
        cursor: pointer;
    }
    .slider {
        flex: 1;
        margin: 0 20px;
    }
    .time {
        margin-right: 20px;
    }
    .text {
        color: #fff;
        font-size: 12px;
        max-width: 150px;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
    }
}
</style>
