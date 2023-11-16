<template>
    <div v-if="shareUserId">
        <div class="screen" v-setVideo="{ type: 1 }">
            <span class="name">{{ shareUserId }}的屏幕</span>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
export default {
    data() {
        return {
            shareUserId: null, //当前的共享者
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        //获取屏幕共享信息
        const { _state, _sharerUserID } = this.$rtcsdk.getScreenShareInfo();
        if (_state === 1 && _sharerUserID !== this.appStore.myUserId) {
            this.shareUserId = _sharerUserID;
        }
        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStarted", this.notifyScreenShareStarted);
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStopped", this.notifyScreenShareStopped);
            this.$rtcsdk[bool ? "on" : "off"]("startScreenShareRslt", this.startScreenShareRslt);
            this.$rtcsdk[bool ? "on" : "off"]("stopScreenShareRslt", this.stopScreenShareRslt);
        },
        notifyScreenShareStarted(userId) {
            this.shareUserId = userId;
        },
        notifyScreenShareStopped() {
            this.shareUserId = null;
        },
        //自己开始屏幕共享按钮接收到的回调
        startScreenShareRslt(sdkErr) {
            if (sdkErr === 0) {
                this.shareUserId = this.appStore.myUserId;
            }
        },
        //自己停止屏幕共享按钮接收到的回调
        stopScreenShareRslt(sdkErr) {
            if (sdkErr === 0) {
                this.shareUserId = null;
            }
        },
    },
};
</script>

<style lang="scss" scoped>
.screen {
    position: relative;
    width: 100%;
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
