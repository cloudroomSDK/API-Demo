<template>
    <div class="content">
        <div class="crtl">
            <el-input v-model="input" :disabled="!!appStore.networkCam || select === 'screen' || select === 'canvas'" :placeholder="select == 'rtmp' || select == 'rtsp' ? '请输入地址' : ''">
                <template #prepend>
                    <el-select v-model="select" class="select" :class="{ disabled: !!appStore.networkCam }" :disabled="!!appStore.networkCam" @change="selectChange">
                        <el-option label="rtmp://" value="rtmp" />
                        <el-option label="rtsp://" value="rtsp" />
                        <el-option v-if="appStore.platform === 'win32'" label="桌面" value="screen" />
                        <el-option label="自定义采集" value="canvas" />
                    </el-select>
                </template>
            </el-input>

            <el-button v-if="!appStore.networkCam" type="primary" class="btn" @click="add"> 添加 </el-button>
            <el-button v-else type="danger" class="btn" @click="del"> 删除 </el-button>
        </div>
        <div class="preview">
            <div
                v-if="appStore.networkCam && select !== 'canvas'"
                v-setVideo="{
                    userId: appStore.myUserId,
                    camId: appStore.networkCam.videoId,
                }"
            ></div>
            <canvas v-if="select === 'canvas'" width="640" height="480" class="canvas" ref="canvas"></canvas>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessage } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
export default {
    data() {
        return {
            input: "",
            select: "rtmp",
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        if (this.appStore.networkCam) {
            const { type, url } = this.appStore.networkCam;
            this.select = type;
            this.input = url || "";
        }
    },
    methods: {
        add() {
            let videoId = 0;
            if (this.select === "screen") {
                videoId = this.addScreenCam();
            } else if (this.select === "canvas") {
                videoId = this.addCanvasCam();
            } else {
                videoId = this.addIpCam();
            }

            if (videoId < 0) {
                //添加失败，则是错误码
                return ElMessage.error(`添加失败，错误码: ${videoId},${errDesc[videoId]}`);
            }

            // 如果开启多摄像头时，把摄像头添加到多摄像头列表中
            // 未开启多摄像头时，把虚拟摄像头设置为默认摄像头
            if (this.appStore.enableMutiVideos) {
                const camList = this.$rtcsdk.getMutiVideos(this.appStore.myUserId);
                camList.push(videoId);
                this.$rtcsdk.setMutiVideos(camList);
            } else {
                this.$rtcsdk.setDefaultVideo(videoId); //设置为摄像头
            }
        },
        addScreenCam() {
            const videoId = this.$rtcsdk.createScreenCamDev("桌面摄像头", -1);
            if (videoId >= 0) {
                this.appStore.networkCam = {
                    videoId: videoId,
                    type: "screen",
                };
            }
            return videoId;
        },
        addCanvasCam() {
            const canvas = this.$refs.canvas;
            const videoId = this.$rtcsdk.createCustomVideoDev("canvas", 12, canvas.width, canvas.height);
            if (videoId >= 0) {
                this.appStore.networkCam = {
                    videoId: videoId,
                    type: "canvas",
                };
            }
            return videoId;
        },
        addIpCam() {
            let url, type;
            if (!this.input.trim()) {
                return ElMessage.error(`请输入地址`);
            } else if (this.input.indexOf("://") > -1) {
                const arr = this.input.trim().split("://");
                type = arr[0];
                url = arr[1];
            } else {
                type = this.select;
                url = this.input;
            }
            console.log(url);
            const videoId = this.$rtcsdk.addIPCam(`${type}://${url}`);
            if (videoId >= 0) {
                this.appStore.networkCam = {
                    videoId: videoId,
                    type: type,
                    url: url,
                };
            }
            return videoId;
        },
        del() {
            const { type, videoId } = this.appStore.networkCam;
            if (type === "screen") {
                this.$rtcsdk.destroyScreenCamDev(videoId);
            } else if (type === "canvas") {
                this.$rtcsdk.destroyCustomVideoDev(videoId);
            } else {
                this.$rtcsdk.delIPCam(videoId);
            }
            this.appStore.networkCam = null;
        },
        //更新canvas画布
        updateCanvasView() {
            const canvas = this.$refs.canvas;
            const ctx = canvas.getContext("2d");
            const centerX = canvas.width / 2;
            const centerY = canvas.height / 2;
            const stars = [];

            class Star {
                constructor(x, y, radius, speed) {
                    this.x = x;
                    this.y = y;
                    this.radius = radius;
                    this.speed = speed;
                    this.alpha = Math.random() * Math.PI * 2;
                }

                update() {
                    this.x = centerX + Math.cos(this.alpha) * this.radius;
                    this.y = centerY + Math.sin(this.alpha) * this.radius;
                    this.alpha += this.speed;
                }

                draw() {
                    ctx.beginPath();
                    ctx.arc(this.x, this.y, 1, 0, Math.PI * 2);
                    ctx.fillStyle = "white";
                    ctx.fill();
                }
            }

            const createStars = () => {
                for (let i = 0; i < 200; i++) {
                    const radius = Math.random() * 200 + 100;
                    const speed = Math.random() * 0.005 + 0.002;
                    const star = new Star(centerX, centerY, radius, speed);
                    stars.push(star);
                }
            };

            const draw = () => {
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                for (let i = 0; i < stars.length; i++) {
                    const star = stars[i];
                    star.update();
                    star.draw();
                }
                if (this.appStore.networkCam && this.appStore.networkCam.type === "canvas") {
                    this.updateCanvasCam();
                }

                this.animationFrame = requestAnimationFrame(draw);
            };

            createStars();
            draw();
        },
        //更新canvas摄像头
        updateCanvasCam() {
            const canvas = this.$refs.canvas;
            const ctx = canvas.getContext("2d");

            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height); //获取rgba格式数据
            const _data = new Uint8Array(imageData.data.buffer);

            const frame = {
                _format: 12,
                _data: _data,
                _width: canvas.width,
                _height: canvas.height,
                _timestamp: Date.now(),
            };

            const sdkErr = this.$rtcsdk.inputCustomVideoDat(this.appStore.networkCam.videoId, frame);
            if (sdkErr !== 0) {
                console.log(`更新失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        selectChange(type) {
            if (type === "canvas") {
                this.$nextTick(() => {
                    this.updateCanvasView();
                });
            } else {
                cancelAnimationFrame(this.animationFrame);
            }
        },
    },
};
</script>

<style lang="scss" scoped>
.content {
    width: 428px;
    margin: 0 auto;
    .crtl {
        display: flex;
        .select {
            width: 120px;
            background-color: #fff;
            &.disabled {
                background-color: #f5f7fa;
                :deep .el-input__inner {
                    cursor: not-allowed;
                }
            }

            :deep .el-input__inner {
                cursor: pointer;
            }
        }
        .btn {
            margin-left: 10px;
        }
    }
    .preview {
        width: 428px;
        height: 252px;
        background-color: #000;
        margin-top: 10px;
        .canvas {
            border: 1px solid #ccc;
            width: 100%;
            height: 100%;
        }
    }
}
</style>
