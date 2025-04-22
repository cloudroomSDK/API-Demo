<template>
    <el-scrollbar class="scroll">
        <el-menu class="menu" active-text-color="#ffd04b" background-color="#272f44" :default-openeds="['1', '2']" style="height: 100vh" text-color="#fff">
            <el-sub-menu index="1">
                <template #title>
                    <span>基础功能</span>
                </template>
                <el-menu-item index="1-1">
                    音频设置
                    <el-button @click="openAudioSetting" class="btn" plain>音频设置</el-button>
                </el-menu-item>
                <el-menu-item index="1-2">
                    视频设置
                    <el-button @click="openVideoSetting" class="btn" plain>视频设置</el-button>
                </el-menu-item>
                <el-menu-item index="1-3">
                    本地录制
                    <el-button class="btn" plain @click="openLocalMixer">开始/停止录制</el-button>
                </el-menu-item>
                <el-menu-item index="1-4">
                    云端录制
                    <el-button class="btn" plain @click="openCloudMixer">开始/停止录制</el-button>
                </el-menu-item>
            </el-sub-menu>
            <el-sub-menu index="2">
                <template #title>
                    <span>进阶功能</span>
                </template>
                <el-menu-item index="2-1">
                    屏幕共享
                    <ScreenShare @openScreenOption="openScreenOption" />
                </el-menu-item>
                <el-menu-item index="2-2">
                    影音播放
                    <MediaShare />
                </el-menu-item>
                <el-menu-item index="2-5">
                    房间消息
                    <MeetingMsg />
                </el-menu-item>
                <el-menu-item index="2-6">
                    房间属性
                    <el-button @click="openAttr(null)" class="btn" plain>设置</el-button>
                </el-menu-item>
                <el-menu-item index="2-7">成员属性 <el-button @click="openMemberAttr" class="btn" plain>设置</el-button></el-menu-item>
                <el-menu-item index="2-8">
                    多摄像头
                    <MultipleVideos />
                </el-menu-item>
                <el-menu-item index="2-9">
                    虚拟摄像头
                    <el-button @click="openVirtualCam" class="btn" plain>设置</el-button>
                </el-menu-item>
                <el-menu-item index="2-10" v-if="appStore.platform === 'win32'">
                    美颜和虚拟背景
                    <el-button @click="openEffectsSetting" class="btn" plain>设置</el-button>
                </el-menu-item>
                <el-menu-item index="2-11">
                    变声
                    <el-button class="btn" plain @click="openVoiceChange">设置</el-button>
                </el-menu-item>
                <el-menu-item index="2-12">
                    声音环回测试
                    <el-button class="btn" plain @click="openEchoTest">测试</el-button>
                </el-menu-item>
            </el-sub-menu>
            <div class="bottom">
                <p class="roomId">
                    <span>房间号: {{ appStore.meetId }}</span>
                    <el-tooltip class="box-item" effect="light" trigger="click" :auto-close="1000" content="已复制" placement="top">
                        <svg @click="copyMeetId" class="copy" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" data-v-ea893728="">
                            <path fill="currentColor" d="M128 320v576h576V320H128zm-32-64h640a32 32 0 0 1 32 32v640a32 32 0 0 1-32 32H96a32 32 0 0 1-32-32V288a32 32 0 0 1 32-32zM960 96v704a32 32 0 0 1-32 32h-96v-64h64V128H384v64h-64V96a32 32 0 0 1 32-32h576a32 32 0 0 1 32 32zM256 672h320v64H256v-64zm0-192h320v64H256v-64z"></path>
                        </svg>
                    </el-tooltip>
                </p>
                <el-button type="danger" class="lougoutBtn" @click="exitMeeting">退出房间</el-button>
            </div>
        </el-menu>
    </el-scrollbar>

    <el-dialog class="dialog" v-model="dialogVisible" :title="dialogTitle" :width="dialogWidth" append-to-body draggable>
        <el-scrollbar max-height="500px" :style="{ padding: dialogTitle === '屏幕共享' ? '0' : '20px' }">
            <component :is="component" v-if="!permanent && dialogVisible" :extend="dialogExtend" @close="dialogClose" @openMamberAttr="openAttr" />

            <!-- 云端录制、本地录制模块为常驻模，为了保持窗口关闭后能持续更新录制内容 -->
            <CloudMixer v-show="permanent == 'cloudMixer'" />
            <LocalMixer v-show="permanent == 'localMixer'" />
            <VirtualCam v-show="permanent == 'virtualCam'" />
        </el-scrollbar>
    </el-dialog>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { markRaw } from "vue";

import Attribute from "./components/attribute";
import MemberAttrSel from "./components/memberAttrSel";
import AudioSetting from "./components/audioSetting";
import VideoSetting from "./components/videoSetting";
import ScreenOption from "./components/screenOption";
import LocalMixer from "./components/localMixer";
import CloudMixer from "./components/cloudMixer";
import MediaShare from "./components/mediaShare";
import ScreenShare from "./components/screenShare";
import MultipleVideos from "./components/multipleVideos";
import MeetingMsg from "./components/meetingMsg";
import VirtualCam from "./components/virtualCam";
import EchoTest from "./components/echoTest";
import EffectsSetting from "./components/effectsSetting.vue";
import VoiceChange from "./components/voiceChange";
import { ipcRenderer } from "electron";

export default {
    components: {
        MediaShare,
        ScreenShare,
        MeetingMsg,
        MultipleVideos,
        LocalMixer,
        CloudMixer,
        VirtualCam,
    },
    data() {
        return {
            dialogTitle: "",
            dialogWidth: "0px",
            dialogVisible: false,
            dialogExtend: null, //弹出层的扩展数据
            component: null,
            permanent: null, //常驻component
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    methods: {
        exitMeeting() {
            this.$rtcsdk.exitMeeting();
            this.appStore.meetId = null;
            this.appStore.enableMutiVideos = false;
            this.appStore.isMyScreenShare = false;
            ipcRenderer.send("common", { method: "exitMeeting" });
            this.$router.replace("/");
        },
        openAudioSetting() {
            this.component = markRaw(AudioSetting);
            this.dialogWidth = "500px";
            this.dialogTitle = "音频设置";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openVideoSetting() {
            this.component = markRaw(VideoSetting);
            this.dialogWidth = "500px";
            this.dialogTitle = "视频设置";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openLocalMixer() {
            this.dialogVisible = true;
            this.permanent = "localMixer";
            this.dialogWidth = "500px";
            this.dialogTitle = "本地录制";
        },
        openCloudMixer() {
            this.dialogVisible = true;
            this.permanent = "cloudMixer";
            this.dialogWidth = "400px";
            this.dialogTitle = "云端录制";
        },
        openScreenOption() {
            this.component = markRaw(ScreenOption);
            this.dialogWidth = "710px";
            this.dialogTitle = "屏幕共享";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openAttr(userId) {
            this.dialogVisible = false;
            this.permanent = false;

            //加nextTick解决选择成员属性后的弹窗变白屏的问题
            this.$nextTick(() => {
                this.component = markRaw(Attribute);
                this.dialogWidth = "60%";
                this.dialogTitle = userId ? "成员属性" : "房间属性";
                this.dialogExtend = userId;
                this.dialogVisible = true;
            });
        },
        openMemberAttr() {
            this.component = markRaw(MemberAttrSel);
            this.dialogWidth = "400px";
            this.dialogTitle = "成员属性";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openVirtualCam() {
            this.dialogVisible = true;
            this.permanent = "virtualCam";
            this.dialogWidth = "500px";
            this.dialogTitle = "虚拟摄像头";
            this.dialogVisible = true;
        },
        openEffectsSetting() {
            this.component = markRaw(EffectsSetting);
            this.dialogWidth = "1200px";
            this.dialogTitle = "美颜和虚拟背景";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openVoiceChange() {
            this.component = markRaw(VoiceChange);
            this.dialogWidth = "400px";
            this.dialogTitle = "变声";
            this.permanent = false;
            this.dialogVisible = true;
        },
        openEchoTest() {
            this.component = markRaw(EchoTest);
            this.dialogWidth = "400px";
            this.dialogTitle = "声音环回测试";
            this.permanent = false;
            this.dialogVisible = true;
        },
        dialogClose() {
            this.dialogVisible = false;
            this.permanent = false;
            this.component = null;
            this.dialogTitle = null;
            this.dialogWidth = null;
            this.dialogExtend = null;
        },
        copyMeetId() {
            navigator.clipboard.writeText(this.appStore.meetId).then(function () {});
        },
    },
};
</script>

<style lang="scss" scoped>
.el-sub-menu {
    :deep .el-sub-menu__title {
        font-size: 16px;
        --el-menu-item-height: 50px;
        --el-menu-level-padding: 10px;
    }

    .el-menu-item {
        cursor: auto;
        --el-menu-active-color: #fff;
        --el-menu-sub-item-height: 36px;
        --el-menu-base-level-padding: 10px;
    }
}

.btn {
    position: absolute;
    right: 10px;
    height: 14px;
    padding: 10px 5px;
}

.scroll {
    position: relative;
    .bottom {
        position: absolute;
        bottom: 10px;
        left: 50%;
        width: 100%;
        transform: translateX(-50%);
        text-align: center;
        .roomId {
            color: #fff;
            margin-bottom: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            span {
                margin-right: 10px;
            }
            .copy {
                cursor: pointer;
                width: 18px;
            }
        }
        .lougoutBtn {
            width: 70px;
            height: 30px;
        }
    }
}
</style>
