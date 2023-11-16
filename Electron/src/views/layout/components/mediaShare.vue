<template>
    <el-button v-if="starting || otherUserShare" class="btn" type="danger" @click="stop">停止</el-button>
    <el-button v-else class="btn" plain @click="selectFile"> 选择文件 </el-button>
</template>

<script>
import { ipcRenderer } from "electron";
import { ElMessage } from "element-plus";
import store from "@/store";
import { mapStores } from "pinia";
import { errDesc } from "@/rtcsdk/sdkErr";
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
        if (this.appStore.shareType === 1) {
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
            this.$rtcsdk[bool ? "on" : "off"]("startPlayMediaFail", this.startPlayMediaFail);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStart", this.notifyMediaStart);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStop", this.notifyMediaStop);
        },
        stop() {
            if (this.otherUserShare) {
                return ElMessage.warning(`他人正在共享，不能停止`);
            }
            this.$rtcsdk.stopPlayMedia();
        },
        async selectFile() {
            if (this.appStore.shareType === 2) {
                return ElMessage.warning(`请先停止屏幕共享`);
            }
            const path = await ipcRenderer.invoke("electron-select-meida"); //通知主进程弹出文件选择框

            if (this.appStore.shareType === 2) {
                return ElMessage.warning(`请先停止屏幕共享`);
            }

            if (path) {
                this.starting = true;
                this.appStore.shareType = 1;
                this.$rtcsdk.startPlayMedia(path);
            }
        },
        startPlayMediaFail(sdkErr) {
            this.starting = false;
            this.appStore.shareType = 0;
            ElMessage.error(`开启影音共享失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
        },
        notifyMediaStart(userId) {
            if (this.appStore.myUserId === userId) {
                this.starting = true;
            } else {
                this.otherUserShare = true;
            }
            this.appStore.shareType = 1;
        },
        notifyMediaStop(userId, reason) {
            /* reason原因
                0	被关闭
                1	播放完成
                2	打开失败
                3	格式错误
                4	不支持的编码
                5	不支持的编码 
            */
            this.starting = false;
            this.appStore.shareType = 0;
            this.otherUserShare = false;
        },
    },
};
</script>
