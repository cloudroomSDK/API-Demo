<template>
    <div v-if="shareUserId">
        <div class="screen" ref="canvas" v-setVideo="{ type: 2, notifyFrameReceived: notifyFrameReceived  }">
            <VideoProgress v-if="shareUserId === appStore.myUserId" :curTime="curTime" :totalTime="totalTime">
                <span>{{ shareUserId }}的影音</span>
            </VideoProgress>
            <span v-else class="name">{{ shareUserId }}的影音</span>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import VideoProgress from "../components/videoProgress";
export default {
    data() {
        return {
            shareUserId: null, //当前的共享者
            isPause: false, //当前是暂停状态
            curTime: 0,
            totalTime: 0,
            curTime: 0,
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    components: { VideoProgress },
    created() {
        //获取屏幕共享信息
        const { _state, _userID, _mediaName } = this.$rtcsdk.getMediaInfo();
        if (_state !== 2) {
            this.shareUserId = _userID;
        }
        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("startPlayMediaFail", this.startPlayMediaFail);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStart", this.notifyMediaStart);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaOpened", this.notifyMediaOpened);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStop", this.notifyMediaStop);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaPause", this.notifyMediaPause);
        },
        startPlayMediaFail() {},
        notifyMediaStart(userId) {
            this.shareUserId = userId;
        },
        notifyMediaOpened(totalTime, w, h) {
            this.totalTime = totalTime;
        },
        notifyMediaStop() {
            this.isPause = false;
            this.shareUserId = null;
        },
        notifyMediaPause(userId, bPause) {
            this.isPause = bPause;
            console.log(userId, bPause);
        },
        // 帧回调函数
        notifyFrameReceived(frame){
            this.curTime = frame._pts;
        }
    },
};
</script>

<style lang="scss" scoped>
.screen {
    position: relative;
    max-width: 100%;
    background-color: #000;
    margin-bottom: 1px;
    .name {
        position: absolute;
        left: 5px;
        bottom: 5px;
        padding: 5px 5px;
        border-radius: 24px;
        background-color: rgba(0, 0, 0, 0.6);
        color: #fff;
        font-size: 12px;
        line-height: 12px;
    }
}
</style>
