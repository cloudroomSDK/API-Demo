<template>
    <div class="context">
        <div class="form">
            <el-row>
                <el-col :span="12">
                    清晰度：
                    <el-select class="select" v-model="definition" :disabled="state !== 0">
                        <!-- 640*360 -->
                        <el-option label="标清" :value="0" />
                        <!-- 848*480 -->
                        <el-option label="高清" :value="1" />
                        <!-- 1280*720 -->
                        <el-option label="超清" :value="2" />
                    </el-select>
                </el-col>
                <el-col :span="12">
                    格式：
                    <el-select class="select" v-model="format" :disabled="state !== 0">
                        <el-option label="mp4" :value="0" />
                        <el-option label="flv" :value="1" />
                        <el-option label="avi" :value="2" />
                    </el-select>
                </el-col>
            </el-row>
        </div>
        <div class="btn">
            <el-button v-if="state === 0" class="btn" type="primary" @click="start">开始录制</el-button>
            <el-button v-else class="btn" type="danger" @click="stop" :loading="state === 1">{{ state === 1 ? "启动中" : "停止录制" }} </el-button>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { parseTime } from "@/utils";
import { ElMessage, ElNotification } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
import { h } from "vue";
import RecordToast from "./cloudRecordToast";
export default {
    data() {
        return {
            definition: 2,
            format: 0,
            state: 0, //录制状态: 0未开始，1启动中，2正在录制
            mixerId: null, //当前混图器ID
            historyMixer: {}, //历史的混图器ID列表
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    watch: {
        "appStore.watchList"(val) {
            this.updateMixerContent();
        },
        "appStore.shareType"(val) {
            this.updateMixerContent();
        },
    },
    created() {
        this.callbackHanle(true);
        const mixerList = JSON.parse(this.$rtcsdk.getAllCloudMixerInfo());
        mixerList.some(({ ID, owner, state }) => {
            if (owner === this.appStore.myUserId) {
                console.log(ID, owner, state);
                this.state = state;
                this.mixerId = ID;
                return true;
            }
        });
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyCloudMixerStateChanged", this.notifyCloudMixerStateChanged);
            this.$rtcsdk[bool ? "on" : "off"]("notifyCloudMixerOutputInfoChanged", this.notifyCloudMixerOutputInfoChanged);
        },
        start() {
            const [VW, VH, bitRate] = [
                [640, 360, 700000],
                [848, 480, 1000000],
                [1280, 720, 2000000],
            ][this.definition];
            const format = ["mp4", "flv", "avi"][this.format];

            const filePath = parseTime(Date.now(), "/YYYY-MM-DD/YYYY-MM-DD_HH-mm-ss") + `_Electron_${this.appStore.meetId}.${format}`;
            const cfg = {
                mode: 0,
                videoFileCfg: {
                    svrPathName: filePath,
                    vWidth: VW,
                    vHeight: VH,
                    vFps: 15,
                    vBps: bitRate,
                    layoutConfig: this.generateLayout(),
                },
            };

            this.mixerId = this.$rtcsdk.createCloudMixer(JSON.stringify(cfg));
            this.state = 1;
        },
        stop() {
            this.$rtcsdk.destroyCloudMixer(this.mixerId);
            this.historyMixer[this.mixerId] = {};

            this.mixerId = null;
            this.state = 0;
        },
        generateLayout() {
            const { watchList, shareType } = this.appStore;
            const videoList = [];
            const [VW, VH] = [
                [640, 360],
                [848, 480],
                [1280, 720],
            ][this.definition];

            if (shareType) {
                //共享布局，录制一大3小

                // 按16:9 计算3小的宽高
                const w = VW / 3;
                const h = (w * 9) / 16;

                // 剩余高度给大的盒子
                const mh = VH - h;
                const mw = VW;

                videoList.push({
                    type: shareType === 1 ? 3 : 5, //添加影音共享或者影音共享
                    top: 0,
                    left: 0,
                    width: mw,
                    height: mh,
                    keepAspectRatio: 1,
                });

                //共享模式只录制共享画面+前3个成员摄像头
                watchList.slice(0, 3).forEach((member, i) => {
                    const top = mh;
                    const left = i * w;
                    videoList.push({
                        type: 0, //添加摄像头
                        top: top,
                        left: left,
                        width: w,
                        height: h,
                        keepAspectRatio: 1,
                        param: { camid: `${member.userId}.${member.camId}` },
                    });

                    const offset = parseInt(w / 42);
                    videoList.push({
                        type: 10, //添加昵称
                        top: top + offset,
                        left: left + offset,
                        param: { text: member.nickname, "font-size": parseInt(w / 35.5) },
                    });
                });
            } else {
                //非共享布局，录制1、2、4、9等分屏幕
                let w, h, col;
                // 一个人时录制一个大屏
                if (watchList.length <= 1) {
                    col = 1;
                    w = VW;
                    h = VH;
                } else if (watchList.length <= 2) {
                    // 两个时录制两等分屏
                    col = 2;
                    w = VW / 2;
                    h = VH;
                } else if (watchList.length <= 4) {
                    // 小于4个人时录制四等分屏
                    col = 2;
                    w = VW / 2;
                    h = VH / 2;
                } else {
                    col = 3;
                    w = VW / 3;
                    h = VH / 3;
                }

                //这里最大值只会录制9个摄像头，因为在计算属性中过滤了9个之后的摄像头
                watchList.forEach((member, idx) => {
                    const top = Math.floor(idx / col) * h;
                    const left = (idx % col) * w;
                    videoList.push({
                        type: 0,
                        top,
                        left,
                        width: w,
                        height: h,
                        keepAspectRatio: 1,
                        param: { camid: `${member.userId}.${member.camId}` },
                    });
                    const offset = parseInt(w / 42);
                    videoList.push({
                        type: 10,
                        top: top + offset,
                        left: left + offset,
                        param: { text: watchList.filter((item) => item.userId === member.userId).length > 1 ? `${member.nickname}-${member.camId}号摄像头` : member.nickname, "font-size": parseInt(w / 35.5) },
                    });
                });
            }

            videoList.push({
                //添加时间戳
                type: 10,
                top: VH / 1.1,
                left: VW / 1.38,
                param: { text: "%timestamp%", "font-size": parseInt(VW / 64) },
            });
            console.log(videoList);
            return videoList;
        },
        updateMixerContent() {
            if (this.mixerId) {
                const cfg = {
                    mode: 0,
                    videoFileCfg: {
                        layoutConfig: this.generateLayout(),
                    },
                };
                const sdkErr = this.$rtcsdk.updateCloudMixerContent(this.mixerId, JSON.stringify(cfg));

                console.log("updateMixerContent", sdkErr);
            }
        },
        notifyCloudMixerStateChanged(mixerId, state, exParam, operUserID) {
            if (this.mixerId === mixerId) {
                if (state === 0 && this.state === 1) {
                    try {
                        // {"err":907,"errDesc":"too many cloud records"}
                        const { err, errDesc: desc } = JSON.parse(exParam);

                        ElMessage.error(`启动录制失败，错误码: ${err},${errDesc[err]}(${desc})`);
                    } catch (error) {}
                }
                this.state = state;
            }
        },
        notifyCloudMixerOutputInfoChanged(mixerId, jsonStr) {
            if (!this.historyMixer[mixerId]) return;
            const data = JSON.parse(jsonStr);
            console.log(data);
            if (data.state === 2) {
                this.historyMixer[mixerId] = data;
                const element = h(RecordToast, {
                    info: this.historyMixer[mixerId],
                });
                ElNotification({
                    title: "云端录制文件通知",
                    dangerouslyUseHTMLString: true,
                    message: element,
                    duration: 0,
                });
            } else if (data.state === 3) {
                ElNotification({
                    title: "录制出错",
                    message: `错误码: ${data.errCode},${data.errDesc}`,
                    type: "error",
                });
            } else if (data.state > 2) {
                Object.keys(data).forEach((key) => {
                    this.historyMixer[mixerId][key] = data[key];
                });
            }

            if ([3, 6, 7].indexOf(data.state) > -1) {
                delete this.historyMixer[mixerId];
            }
        },
    },
};
</script>

<style lang="scss" scoped>
.context {
    .form {
        .select {
            width: 80px;
        }
    }
    .btn {
        margin-top: 10px;
        text-align: center;
    }
}
</style>
