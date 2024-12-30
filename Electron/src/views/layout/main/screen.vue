<template>
    <div v-if="shareUserId">
        <!-- 屏幕共享组件 -->
        <div class="screen" :class="{ fullscreen: fullscreen }" v-setVideo="{ type: 1 }" ref="screenRef">
            <span class="name">{{ shareUserId }}的屏幕</span>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessageBox } from "element-plus";
import { ipcRenderer } from "electron";
export default {
    data() {
        return {
            shareUserId: null, //当前的共享者
            remoteControler: null, //远程控制者ID
            fullscreen: false, //是否全屏
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
        optionList() {
            const { memberList, myUserId } = this.appStore;
            return Object.keys(memberList)
                .filter((item) => item !== myUserId)
                .map((item) => ({
                    userId: item,
                    nickname: memberList[item].nickname,
                }));
        },
    },
    watch: {
        optionList() {
            ipcRenderer.send("common", {
                module: "screenOption",
                method: "updateMemberList",
                data: this.optionList,
            });
        },
        "appStore.hasCtrlMode"(newVal) {
            this.toggleCtrlMode(newVal);
        },
    },
    created() {
        //获取屏幕共享信息
        const { _state, _sharerUserID } = this.$rtcsdk.getScreenShareInfo();
        if (_state === 1 && _sharerUserID !== this.appStore.myUserId) {
            this.shareUserId = _sharerUserID;
        }
        this.callbackHanle(true);
        // 开始标注
        ipcRenderer.on("marker-start", (event) => {
            this.startScreenMark();
        });
        // 停止标注
        ipcRenderer.on("marker-stop", (event) => {
            this.stopScreenMark();
        });
        // 清空标注
        ipcRenderer.on("marker-clear", (event) => {
            this.clearScreenMarks();
        });
        //刷新浮窗成员列表
        ipcRenderer.on("getMemberList", (event) => {
            ipcRenderer.send("common", {
                module: "screenOption",
                method: "updateMemberList",
                data: this.optionList,
            });
        });
        //回收远程控制权限
        ipcRenderer.on("releaseCtrlRight", (event) => {
            console.log("releaseCtrlRight");
            this.$rtcsdk.releaseCtrlRight(this.remoteControler);
            this.remoteControler = null;
        });
        //赋予远程控制权限
        ipcRenderer.on("giveCtrlRight", (event, data) => {
            if (this.remoteControler) {
                this.$rtcsdk.releaseCtrlRight(this.remoteControler);
            }
            this.remoteControler = data;
            this.$rtcsdk.giveCtrlRight(data);
        });
    },
    mounted() {
        this.appStore.hasCtrlMode && this.toggleCtrlMode(true);
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
        toggleCtrlMode(bool) {
            //  screenRef.videoUI 是在指令集中创建的
            if (bool) {
                ElMessageBox.alert("您已经获得了远程屏幕控制权限", {
                    confirmButtonText: "确定",
                });
                this.$refs.screenRef?.videoUI?.ctrlMode(true);
            } else {
                ElMessageBox.alert(`您的远程屏幕控制权限已经被回收`, {
                    confirmButtonText: "确定",
                });
                this.$refs.screenRef?.videoUI?.ctrlMode(false);
            }
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
                //打开控制条浮窗
                ipcRenderer.send("common", { method: "createScreenOption" });
            }
        },
        //自己停止屏幕共享按钮接收到的回调
        stopScreenShareRslt(sdkErr) {
            if (sdkErr === 0) {
                this.shareUserId = null;
                this.fullscreen = false;

                //销毁控制条浮窗
                ipcRenderer.send("common", { method: "destoryScreenOption" });
            }
        },
        startScreenMark() {
            this.$rtcsdk.startScreenMark();
            //如果调用videoUI会报错，因为全屏事件需要从交互事件中调用，否则会报错
            //这里采用了一个伪全屏的方式结合主线程调用的setFullScreen Api，实现全屏效果。
            setTimeout(() => {
                this.fullscreen = true;
            }, 200);
        },
        stopScreenMark() {
            this.$rtcsdk.stopScreenMark();
            this.fullscreen = false;
        },
        clearScreenMarks() {
            this.$rtcsdk.clearScreenMarks();
        },
    },
};
</script>

<style lang="scss" scoped>
.ctrlOption {
    padding: 10px 20px;
}

.screenOption {
    padding-left: 20px;
    padding-bottom: 8px;

    .screenOptionItem {
        padding-left: 20px;

        .span {
            margin-right: 40px;

            .switch {
                margin-right: 8px;
            }
        }
    }
}

.screen {
    position: relative;
    width: 100%;
    background-color: #000;
    margin-bottom: 1px;
    &.fullscreen {
        position: fixed;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
        margin-bottom: 0;
        z-index: 999;
    }

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
