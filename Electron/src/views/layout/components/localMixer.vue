<template>
    <div class="context">
        <div class="form">
            <el-row>
                <el-col :span="19">
                    <el-form-item label="存储路径：">
                        <el-input v-model="folderInput" disabled />
                    </el-form-item>
                </el-col>
                <el-col :span="4" :offset="1">
                    <el-button type="primary" plain @click="folderSelect">选择</el-button>
                </el-col>
            </el-row>
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
            <el-button v-else class="btn" type="danger" @click="stop" :loading="state === 1 || state === 4" :disabled="state === 4">
                <span v-if="state === 1">启动中</span>
                <span v-else-if="state === 4">停止中</span>
                <span v-else>停止录制</span>
            </el-button>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { parseTime } from "@/utils";
import { ElMessage, ElNotification } from "element-plus";
import { ipcRenderer } from "electron";
import { errDesc } from "@/rtcsdk/sdkErr";
import { h } from "vue";
import RecordToast from "./localRecordToast";
const path = require("path");

export default {
    data() {
        return {
            folderInput: "",
            definition: 2,
            share: 0, // 共享状态: 0未开启，1影音共享，2屏幕共享
            format: 0,
            state: 0, //录制状态: 0未开始，1启动中，2正在录制 ,4停止中
            mixerId: "1", //当前混图器ID
            historyFilePath: {}, //历史的文件名记录
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        const path = require("path");
        const os = require("os");
        const folderInput = path.join(os.homedir(), "Videos");
        this.folderInput = folderInput;

        this.callbackHanle(true);

        const { _state: mediaState } = this.$rtcsdk.getMediaInfo();
        //当前有影音在共享,添加到录制内容里面
        if (mediaState !== 2) {
            this.share = 1;
        }

        const { _state: screenState } = this.$rtcsdk.getScreenShareInfo();
        if (screenState === 1) {
            this.share = 2;
        }
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyLocMixerStateChanged", this.notifyLocMixerStateChanged);
            this.$rtcsdk[bool ? "on" : "off"]("notifyLocMixerOutputInfo", this.notifyLocMixerOutputInfo);
            this.$rtcsdk[bool ? "on" : "off"]("notifyUserEnterMeeting", this.updateMixerContent);
            this.$rtcsdk[bool ? "on" : "off"]("notifyUserLeftMeeting", this.updateMixerContent);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStart", this.notifyMediaStart);
            this.$rtcsdk[bool ? "on" : "off"]("notifyMediaStop", this.notifyShareStopped);
            this.$rtcsdk[bool ? "on" : "off"]("startScreenShareRslt", this.startScreenShareRslt);
            this.$rtcsdk[bool ? "on" : "off"]("stopScreenShareRslt", this.notifyShareStopped);
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStarted", this.notifyScreenShareStarted);
            this.$rtcsdk[bool ? "on" : "off"]("notifyScreenShareStopped", this.notifyShareStopped);
        },
        async folderSelect() {
            const path = await ipcRenderer.invoke("electron-select-localMixer"); //通知主进程弹出文件选择框
            if (path) this.folderInput = path;
        },
        start() {
            this.state = 1;
            const [VW, VH, bitRate] = [
                [640, 360, 1000000],
                [848, 480, 2000000],
                [1280, 720, 4000000],
            ][this.definition];

            const cfg = {
                width: VW,
                height: VH,
                // frameRate: 8,
                bitRate: bitRate,
                defaultQP: 18,
                // gop: 15,
            };
            const mixerContent = this.generateLayout();
            const sdkErr1 = this.$rtcsdk.createLocMixer(this.mixerId, JSON.stringify(cfg), JSON.stringify(mixerContent));
            console.log("sdkErr1", sdkErr1);
            if (sdkErr1 !== 0) {
                this.state = 0;
                return ElMessage.error(`启动录制失败，错误码: ${sdkErr1},${errDesc[sdkErr1]}`);
            }

            const format = ["mp4", "flv", "avi"][this.format];
            const filePath = this.folderInput + parseTime(Date.now(), "/YYYY-MM-DD_HH-mm-ss") + `_Electron_${this.appStore.meetId}.${format}`;
            const normalizedPath = path.normalize(filePath);

            console.log(normalizedPath);
            const mixerOutput = [{ type: 0, filename: normalizedPath }];

            const sdkErr2 = this.$rtcsdk.addLocMixerOutput(this.mixerId, JSON.stringify(mixerOutput));
            console.log("sdkErr2", sdkErr2);
            if (sdkErr2 !== 0) {
                this.state = 0;
                return ElMessage.error(`启动录制失败，错误码: ${sdkErr2},${errDesc[sdkErr2]}`);
            }

            this.historyFilePath[normalizedPath] = {};
            this.state = 2;
        },
        stop() {
            this.$rtcsdk.destroyLocMixer(this.mixerId);
            this.state = 0;
        },
        notifyMediaStart() {
            this.share = 1;
            this.updateMixerContent();
        },
        startScreenShareRslt(sdkErr) {
            if (sdkErr === 0) {
                this.notifyScreenShareStarted();
            }
        },
        notifyScreenShareStarted() {
            this.share = 2;
            this.updateMixerContent();
        },
        notifyShareStopped() {
            this.share = 0;
            this.updateMixerContent();
        },
        generateLayout() {
            const userIds = Object.keys(this.appStore.memberList);
            const videoList = [];
            const [VW, VH] = [
                [640, 360],
                [848, 480],
                [1280, 720],
            ][this.definition];

            if (this.share) {
                //共享布局，录制一大3小

                // 按16:9 计算3小的宽高
                const w = VW / 3;
                const h = (w * 9) / 16;

                // 剩余高度给大的盒子
                const mh = VH - h;
                const mw = VW;

                videoList.push({
                    type: this.share === 1 ? 3 : 5, //添加影音共享或者影音共享
                    top: 0,
                    left: 0,
                    width: mw,
                    height: mh,
                    keepAspectRatio: 1,
                });

                if (userIds.length > 3) userIds.length = 3; //只录制前3位
                userIds.forEach((userId, i) => {
                    const top = mh;
                    const left = i * w;
                    videoList.push({
                        type: 0, //添加摄像头
                        top: top,
                        left: left,
                        width: w,
                        height: h,
                        keepAspectRatio: 1,
                        param: { camid: `${userId}.-1` },
                    });

                    const offset = parseInt(w / 42);
                    videoList.push({
                        type: 10,
                        top: top + offset,
                        left: left + offset,
                        param: { text: userId, "font-size": parseInt(w / 35.5) },
                    });
                });
            } else {
                //非共享布局，录制1、2、4、9等分屏幕
                let w, h, col;
                // 一个人时录制一个大屏
                if (userIds.length <= 1) {
                    col = 1;
                    w = VW;
                    h = VH;
                } else if (userIds.length <= 2) {
                    // 两个时录制两等分屏
                    col = 2;
                    w = VW / 2;
                    h = VH;
                } else if (userIds.length <= 4) {
                    // 小于4个人时录制四等分屏
                    col = 2;
                    w = VW / 2;
                    h = VH / 2;
                } else {
                    // 如果超过9人，只录制前9人，录制9等分屏
                    if (userIds.length > 9) {
                        userIds.length = 9;
                    }
                    col = 3;
                    w = VW / 3;
                    h = VH / 3;
                }

                userIds.forEach((userId, idx) => {
                    const top = Math.floor(idx / col) * h;
                    const left = (idx % col) * w;
                    videoList.push({
                        type: 0,
                        top,
                        left,
                        width: w,
                        height: h,
                        keepAspectRatio: 1,
                        param: { camid: `${userId}.-1` },
                    });
                    const offset = parseInt(w / 42);
                    videoList.push({
                        type: 10,
                        top: top + offset,
                        left: left + offset,
                        param: { text: userId, "font-size": parseInt(w / 35.5) },
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
                const layout = this.generateLayout();
                const sdkErr = this.$rtcsdk.updateLocMixerContent(this.mixerId, JSON.stringify(layout));

                console.log("updateMixerContent", sdkErr);
            }
        },
        notifyLocMixerStateChanged(mixerId, state) {
            if (this.mixerId === mixerId) {
                this.state = state;
            }
        },
        notifyLocMixerOutputInfo(mixerId, nameOrUrl, outputInfo) {
            const filePath = path.normalize(nameOrUrl);
            if (!this.historyFilePath[filePath]) return;
            const data = JSON.parse(outputInfo);
            console.log(data);
            if (data.state === 0) {
                this.historyFilePath[filePath] = {
                    fileName: path.basename(filePath),
                    filePath: filePath,
                    ...data,
                };
                const element = h(RecordToast, {
                    info: this.historyFilePath[filePath],
                });
                ElNotification({
                    title: "本地录制文件通知",
                    dangerouslyUseHTMLString: true,
                    message: element,
                    duration: 0,
                });
            } else {
                Object.keys(data).forEach((key) => {
                    this.historyFilePath[filePath][key] = data[key];
                });

                if (data.state !== 1) {
                    delete this.historyFilePath[filePath];
                }
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
