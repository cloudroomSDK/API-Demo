<template>
    <div v-if="shareUserId">
        <!-- 主控端端选项 -->
        <!-- <div class="ctrlOption" v-if="appStore.hasCtrlMode">
            <el-dropdown>
                <el-button type="primary"> 发送组合键(系统键暂不可用) </el-button>
                <template #dropdown>
                    <el-dropdown-menu>
                        <el-dropdown-item @click="sengKey(162, 164, 46)">Ctrl+Alt+Del</el-dropdown-item>
                        <el-dropdown-item @click="sengKey(17, 18, 46)">Ctrl+Alt+Del</el-dropdown-item>
                        <el-dropdown-item @click="sengKey(92, 76)">锁屏</el-dropdown-item>
                        <el-dropdown-item @click="sengKey(162, 86)">Ctrl+V</el-dropdown-item>
                    </el-dropdown-menu>
                </template>
            </el-dropdown>
        </div> -->
        <!-- 被控端选项 -->
        <div class="screenOption" v-if="appStore.platform === 'win32' && appStore.myUserId === shareUserId">
            共享选项：
            <div class="screenOptionItem">
                <span class="span"><el-switch class="switch" v-model="allowRemoteControl" />允许他人远程控制</span>
                <el-select v-model="remoteControler" style="width: 240px" size="small" :disabled="!allowRemoteControl">
                    <el-option label="请选择远程控制者" value="" />
                    <el-option v-for="item in optionList" :key="item.userId" :label="item.nickname" :value="item.userId" />
                </el-select>
            </div>
        </div>
        <!-- 屏幕共享组件 -->
        <div class="screen" v-setVideo="{ type: 1 }" ref="screenRef">
            <span class="name">{{ shareUserId }}的屏幕</span>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessageBox } from "element-plus";
export default {
    data() {
        return {
            shareUserId: null, //当前的共享者
            allowRemoteControl: false, //是否允许远程控制
            remoteControler: "",
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
        allowRemoteControl(newVal) {
            if (this.remoteControler) {
                if (newVal) {
                    this.$rtcsdk.giveCtrlRight(this.remoteControler);
                } else {
                    this.$rtcsdk.releaseCtrlRight(this.remoteControler);
                }
            }
        },
        remoteControler(newVal, oldVal) {
            console.log(newVal, oldVal);
            oldVal && this.$rtcsdk.releaseCtrlRight(oldVal);
            newVal && this.$rtcsdk.giveCtrlRight(newVal);
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
        // sengKey(...args) {
        //     console.log(args);
        //     args.forEach((keyCode, i) => {
        //         setTimeout(() => {
        //             this.$rtcsdk.sendKeyCtrlMsg(0, keyCode,1);
        //         }, i * 20);
        //     });
        //     setTimeout(() => {
        //         args.forEach((keyCode) => {
        //             this.$rtcsdk.sendKeyCtrlMsg(1, keyCode,1);
        //         });
        //     }, 1000);
        // },
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
