<template>
    <el-button v-if="starting || otherUserShare" class="btn" type="danger" @click="stop">停止</el-button>
    <el-button v-else class="btn" plain @click="start">开始</el-button>
</template>

<script>
import { ElMessage } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
import store from "@/store";
import { mapStores } from "pinia";
export default {
    data() {
        return {
            starting: false, //自己的共享状态
            otherUserShare: false, //他人正在共享
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        if (this.appStore.shareType === 2) {
            this.otherUserShare = true;
        }
        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("startScreenShareRslt", this.startScreenShareRslt);
            this.$rtcsdk[bool ? "on" : "off"]("stopScreenShareRslt", this.stopScreenShareRslt);
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStarted", this.notifyScreenShareStarted);
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStopped", this.notifyScreenShareStopped);
        },
        stop() {
            if (this.otherUserShare) {
                return ElMessage.warning(`他人正在共享屏幕，不能停止`);
            }
            this.starting = false;
            this.appStore.shareType = 0;
            this.$rtcsdk.stopScreenShare(); //停止屏幕共享
        },
        start() {
            if (this.appStore.shareType === 1) {
                return ElMessage.warning(`请先停止影音共享`);
            }
            this.starting = true;
            this.appStore.shareType = 2;
            this.$rtcsdk.startScreenShare(); //开启屏幕共享
        },
        startScreenShareRslt(sdkErr) {
            if (sdkErr != 0) {
                this.starting = false;
                this.appStore.shareType = 0;
                ElMessage.error(`开启屏幕共享失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
                return;
            }
        },
        stopScreenShareRslt(sdkErr) {
            if (sdkErr != 0) {
                ElMessage.error(`停止屏幕共享失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        notifyScreenShareStarted(userId) {
            if (userId !== this.appStore.myUserId) {
                this.otherUserShare = true;
                this.appStore.shareType = 2;
            }
        },
        notifyScreenShareStopped(oprUserID) {
            this.appStore.shareType = 0;
            this.starting = false;
            this.otherUserShare = false;
        },
    },
};
</script>
