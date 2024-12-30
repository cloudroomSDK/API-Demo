<template>
    <div class="common-layout">
        <el-container style="max-height: 100vh">
            <el-aside width="240px">
                <Aside></Aside>
            </el-aside>
            <el-main>
                <el-scrollbar height="100%">
                    <Main></Main>
                </el-scrollbar>
            </el-main>
        </el-container>
    </div>
</template>

<script>
import Aside from "./aside";
import Main from "./main/main.vue";
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessageBox } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";

export default {
    components: {
        Aside,
        Main,
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        this.callbackHanle(true);

        if (this.$rtcsdk.getScreenShareInfo()._state === 1) {
            //获取屏幕共享信息
            this.appStore.shareType = 2;
        } else if (this.$rtcsdk.getMediaInfo()._state !== 2) {
            //获取影音共享信息
            this.appStore.shareType = 1;
        } else {
            this.appStore.shareType = 0;
        }

        this.appStore.memberList = this.$rtcsdk.getAllMembers().reduce((previousValue, currentValue) => {
            previousValue[currentValue._userId] = {
                nickname: currentValue._nickName,
                audioStatus: currentValue._audioStatus,
                videoStatus: currentValue._videoStatus,
            };
            return previousValue;
        }, {});
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyUserEnterMeeting", this.notifyUserEnterMeeting);
            this.$rtcsdk[bool ? "on" : "off"]("notifyUserLeftMeeting", this.notifyUserLeftMeeting);
            this.$rtcsdk[bool ? "on" : "off"]("notifyVideoStatusChanged", this.notifyVideoStatusChanged);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMicStatusChanged", this.notifyMicStatusChanged);
            this.$rtcsdk[bool ? "on" : "off"]("notifyTokenWillExpire", this.notifyTokenWillExpire);
            this.$rtcsdk[bool ? "on" : "off"]("notifyLineOff", this.notifyLineOff);
        },
        //通知有用户进入了房间
        notifyUserEnterMeeting(userId) {
            const userInfo = this.$rtcsdk.getMemberInfo(userId);
            this.appStore.memberList[userId] = {
                nickname: userInfo._nickName,
                audioStatus: userInfo._audioStatus,
                videoStatus: userInfo._videoStatus,
            };
        },
        //通知有人离会
        notifyUserLeftMeeting(userId) {
            delete this.appStore.memberList[userId];
        },
        // 通知用户视频状态变化
        notifyVideoStatusChanged(userId, oldStatus, newStatus, oprUserId) {
            this.appStore.memberList[userId].videoStatus = newStatus;
        },
        //通知用户麦克风状态变化
        notifyMicStatusChanged(userId, oldStatus, newStatus, oprUserId) {
            this.appStore.memberList[userId].audioStatus = newStatus;
        },
        // 掉线通知
        notifyLineOff(sdkErr) {
            const text = `您已掉线，错误码: ${sdkErr},${errDesc[sdkErr]}`;
            this.appStore.isLogin = false;
            ElMessageBox.alert(text, "掉线通知", {
                confirmButtonText: "确定",
            }).then(() => {
                this.$router.replace("/");
            });
        },
        // token即将过期通知
        notifyTokenWillExpire() {
            ElMessageBox.prompt("请更新Token，否则30秒后将掉线", "Token即将过期", {
                confirmButtonText: "更新",
                cancelButtonText: "取消",
            }).then(({ value }) => {
                console.log(value);
                this.$rtcsdk.updateToken(value);
            });
        },
    },
};
</script>
