<template>
    <div class="videoList clearfix">
        <div v-for="(member, key) in watchList" class="videoBox" :key="member">
            <div class="scale">
                <div class="video">
                    <div v-if="member.videoStatus === 3" v-setVideo="{ userId: key }"></div>
                    <div v-else>
                        <img src="@/assets/videoList/video_close.jpg" alt="" />
                    </div>
                    <div class="box">
                        <div class="uid">{{ key }}</div>
                        <div class="ctrl">
                            <i
                                :class="[
                                    'icon',
                                    member.audioStatus === 3 ? 'icon-mic-open' : 'icon-mic-close',
                                    {
                                        'icon-mic-small': 1 < memberMicEnergy[key] && 3 <= memberMicEnergy[key],
                                        'icon-mic-middle': 3 < memberMicEnergy[key] && 6 <= memberMicEnergy[key],
                                        'icon-mic-big': 6 < memberMicEnergy[key],
                                    },
                                ]"
                                @click="toggleMic(key, member)"
                            ></i>
                            <i :class="['icon', member.videoStatus === 3 ? 'icon-video-open' : 'icon-video-close']" @click="toggleVideo(key, member)"></i>
                        </div>
                        <div v-if="appStore.myUserId === key" class="title">
                            <div class="signal">
                                <i
                                    v-for="num in 5"
                                    :key="num"
                                    :style="{
                                        height: 4 + (num - 1) * 3 + 'px',
                                        backgroundColor: netStateLevel / 2 >= num ? '#00ff00' : '#ffffff',
                                    }"
                                ></i>
                            </div>
                            <div class="fnbtn">
                                <button @click="setUpsideDown">
                                    <svg t="1698893928810" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1116" width="200" height="200"><path d="M759.56906666 235.487232l0 156.03029333-503.922688 0 0-156.03029333 503.922688 0Z" fill="#ffffff" p-id="1117"></path><path d="M988.43170133 475.17969067l0 75.595776-944.85981867 1e-8 0-75.59577601 944.85981867 0Z" fill="#ffffff" p-id="1118"></path><path d="M775.68 637.65435733l0 33.06837334-536.40669867 1e-8 0-33.06837336L775.68 637.65435733zM775.68 794.05602133l0 33.06837334-536.40669867 0 0-33.06837334L775.68 794.05602133zM742.61162666 666.763264l33.06837334 0 0 131.252224-33.06837334 0L742.61162666 666.763264zM239.31153066 666.959872l33.06837334 0 0 131.252224-33.06837334 0L239.31153066 666.959872z" fill="#ffffff" p-id="1119"></path></svg>
                                </button>
                                <button @click="setMirror">
                                    <svg t="1698893970309" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1407" width="200" height="200"><path d="M235.487232 264.43093334l156.03029333 0 0 503.922688-156.03029333 0 0-503.922688Z" fill="#ffffff" p-id="1408"></path><path d="M475.17969067 35.56829867l75.595776 0 0 944.85981867-75.595776 0 0-944.85981867Z" fill="#ffffff" p-id="1409"></path><path d="M637.65435733 248.32l33.06837334 0 0 536.40669867-33.06837334 0L637.65435733 248.32zM794.05602133 248.32l33.06837334 0 0 536.40669867-33.06837334 0L794.05602133 248.32zM666.763264 281.38837334l0-33.06837334 131.252224 0 0 33.06837334L666.763264 281.38837334zM666.959872 784.68846934l0-33.06837334 131.252224 0 0 33.06837334L666.959872 784.68846934z" fill="#ffffff" p-id="1410"></path></svg>
                                </button>
                                <button @click="setDegree">
                                    <svg t="1698892248371" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1019" width="200" height="200">
                                        <path d="M934.08 416.448h-220.352a46.4 46.4 0 0 1-47.232-47.232c0-26.752 20.48-47.232 47.232-47.232h173.184V148.8c0-26.752 20.48-47.168 47.168-47.168 26.816 0 47.232 20.48 47.232 47.168V369.28a47.36 47.36 0 0 1-47.232 47.232z" fill="#ffffff" p-id="1020"></path>
                                        <path d="M509.056 978.432A470.976 470.976 0 0 1 38.4 507.712 470.976 470.976 0 0 1 509.056 37.12a472.32 472.32 0 0 1 434.56 288.064c9.408 23.68-1.6 51.968-25.216 61.44-23.68 9.408-51.968-1.6-61.44-25.216a377.92 377.92 0 0 0-347.904-229.824 376.192 376.192 0 1 0 0 752.448c190.528 0 351.104-141.696 373.12-328.96a47.36 47.36 0 0 1 51.904-40.96 47.36 47.36 0 0 1 40.96 51.904 469.504 469.504 0 0 1-465.92 412.48z" fill="#ffffff" p-id="1021"></path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessage } from "element-plus";
export default {
    data() {
        return {
            netStateLevel: 10, //网络信号等级
            memberMicEnergy: {}, //存储成员麦克风音量大小
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
        watchList() {
            // 因为elecrton渲染视图性能有限，仅渲染包括自己在内9名成员
            const { memberList, myUserId } = this.appStore;
            const obj = {};
            let i = 0;
            if (memberList[myUserId]) {
                obj[myUserId] = memberList[myUserId];
                i = 1;
            }

            Object.keys(memberList).some((userId) => {
                if (userId !== myUserId) {
                    obj[userId] = memberList[userId];
                    i++;

                    //最多只渲染9名成员
                    if (i >= 9) return true;
                }
            });
            return obj;
        },
    },
    created() {
        this.callbackHanle(true);
    },
    mounted() {
        this.setVideoConfig();
        this.$rtcsdk.openVideo(this.appStore.myUserId); //打开自己的摄像头
        this.$rtcsdk.openMic(this.appStore.myUserId); //打开自己的摄像头
    },

    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("openVideoDevRslt", this.openVideoDevRslt);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMicEnergy", this.notifyMicEnergy); //麦克风音量变化通知
            this.$rtcsdk[bool ? "on" : "off"]("notifyNetStateChanged", this.notifyNetStateChanged); //通知网络状态变化
        },
        setVideoConfig() {
            const config = this.appStore.rateConfigs[1]; //取一个默认配置

            const curConfig = JSON.parse(this.$rtcsdk.getVideoCfg()); //获取当前配置

            curConfig.size = `${config.width}*${config.height}`;

            curConfig.maxbps = config.defaultRatio * 1000;
            curConfig.qp_min = 22;
            curConfig.qp_max = 22;
            this.$rtcsdk.setVideoCfg(JSON.stringify(curConfig));
        },
        toggleMic(userId, userInfo) {
            userInfo.audioStatus === 3 ? this.$rtcsdk.closeMic(userId) : this.$rtcsdk.openMic(userId);
        },
        toggleVideo(userId, userInfo) {
            userInfo.videoStatus === 3 ? this.$rtcsdk.closeVideo(userId) : this.$rtcsdk.openVideo(userId);
        },
        openVideoDevRslt(videoID, isSucceed) {
            if (!isSucceed) {
                ElMessage.error(`打开摄像头失败`);
            }
        },
        notifyMicEnergy(userId, oldLevel, newLevel) {
            this.memberMicEnergy[userId] = newLevel;
        },
        notifyNetStateChanged(level) {
            console.log("netStateLevel", level);
            this.netStateLevel = level;
        },
        setUpsideDown() {
            const videoEffects = JSON.parse(this.$rtcsdk.getVideoEffects());
            videoEffects.upsideDown = videoEffects.upsideDown === 1 ? 0 : 1;
            this.$rtcsdk.setVideoEffects(JSON.stringify(videoEffects));
        },
        setMirror() {
            const videoEffects = JSON.parse(this.$rtcsdk.getVideoEffects());
            videoEffects.mirror = videoEffects.mirror === 1 ? 0 : 1;
            this.$rtcsdk.setVideoEffects(JSON.stringify(videoEffects));
        },
        setDegree() {
            const videoEffects = JSON.parse(this.$rtcsdk.getVideoEffects());
            const newCfg = Object.assign(
                {
                    degree: 0, //默认值是0
                },
                videoEffects
            );

            newCfg.degree = newCfg.degree === 270 ? 0 : newCfg.degree + 90;
            this.$rtcsdk.setVideoEffects(JSON.stringify(newCfg));
        },
    },
};
</script>

<style lang="scss" scoped>
.icon {
    // display: block;
    float: left;
    height: 26px;
    width: 26px;
    background-size: 100%;
    cursor: pointer;
    &:hover {
        background-color: rgba(255, 255, 255, 0.2);
    }

    &.icon-video-open {
        background-image: url("@/assets/videoList/video_open.png");
    }
    &.icon-video-close {
        background-image: url("@/assets/videoList/video_close.png");
    }
    &.icon-mic-open {
        background-image: url("@/assets/videoList/mic_open.png");
    }
    &.icon-mic-close {
        background-image: url("@/assets/videoList/mic_close.png");
    }
    &.icon-mic-small {
        background-image: url("@/assets/videoList/mic_small.png");
    }
    &.icon-mic-middle {
        background-image: url("@/assets/videoList/mic_middle.png");
    }
    &.icon-mic-big {
        background-image: url("@/assets/videoList/mic_big.png");
    }
}
.videoList {
    //   display: flex;
    width: 100%;
    box-sizing: border-box;
    .videoBox {
        max-width: 33.33%;
        float: left;
        width: 33.33%;
        &:nth-of-type(3n + 1),
        &:nth-of-type(3n + 2) {
            border-right: 1px solid #ccc;
        }
        border-bottom: 1px solid #ccc;
        .scale {
            width: 100%;
            padding-bottom: 56.25%;
            height: 0;
            position: relative;
            .video {
                width: 100%;
                height: 100%;
                > div {
                    height: 100%;
                }
                background-color: #000;
                position: absolute;
                img {
                    width: 100%;
                }
                .box {
                    position: absolute;
                    left: 0;
                    top: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 1;
                    .uid {
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
                    .ctrl {
                        position: absolute;
                        bottom: 5px;
                        right: 5px;
                        //   width: 20px;
                        height: 26px;
                        padding: 0 10px;
                        border-radius: 26px;
                        background-color: rgba(0, 0, 0, 0.5);
                    }
                    .title {
                        position: absolute;
                        top: 0;
                        height: 30px;
                        width: 100%;
                        background-color: rgba(0, 0, 0, 0.5);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0 5px;
                        .signal {
                            display: flex;
                            flex-direction: row;
                            flex-wrap: nowrap;
                            align-items: flex-end;
                            i {
                                width: 3px;
                                margin-right: 1px;
                                border-radius: 1px 1px 0 0;
                            }
                        }
                        .fnbtn {
                            height: 100%;
                            float: right;
                            button {
                                svg {
                                    padding: 6px;
                                    height: 30px;
                                    width: 30px;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
</style>
