<template>
    <div class="container">
        <div class="video">
            <div v-if="isOpenCam" v-setVideo="{ userId: appStore.myUserId }"></div>
            <div v-else class="no-video">暂未开启摄像头</div>
        </div>
        <el-form class="form" label-width="100px">
            <el-form-item label="开启美颜：">
                <el-switch v-model="isStartBeauty" @change="toggleBeautySwitch" />
            </el-form-item>
            <el-form-item label="磨皮：" class="slider">
                <el-slider v-model="smooth" :disabled="!isStartBeauty" :step="0.05" :min="0" :max="1" @input="updateBeauty" /><span class="text">{{ smooth }}</span>
            </el-form-item>
            <el-form-item label="美白：" class="slider">
                <el-slider v-model="whiten" :disabled="!isStartBeauty" :step="0.05" :min="0" :max="1" @input="updateBeauty" /><span class="text">{{ whiten }}</span>
            </el-form-item>
            <el-form-item label="红唇：" class="slider">
                <el-slider v-model="lipstick" :disabled="!isStartBeauty" :step="0.05" :min="0" :max="1" @input="updateBeauty" /><span class="text">{{ lipstick }}</span>
            </el-form-item>
            <el-form-item label="腮红：" class="slider">
                <el-slider v-model="blusher" :disabled="!isStartBeauty" :step="0.05" :min="0" :max="1" @input="updateBeauty" /><span class="text">{{ blusher }}</span>
            </el-form-item>
            <el-form-item label="瘦脸：" class="slider">
                <el-slider v-model="thinface" :disabled="!isStartBeauty" :step="0.005" :min="0" :max="0.05" @input="updateBeauty" /><span class="text">{{ thinface }}</span>
            </el-form-item>
            <el-form-item label="大眼：" class="slider">
                <el-slider v-model="bigeye" :disabled="!isStartBeauty" :step="0.01" :min="0" :max="0.2" @input="updateBeauty" /><span class="text">{{ bigeye }}</span>
            </el-form-item>
            <el-form-item label="虚拟背景：" label-position="right">
                <el-radio-group v-model="VBType" @change="VBChange">
                    <el-radio-button label="关闭" :value="0" />
                    <el-radio-button label="ai人像模式" :value="2" />
                    <el-radio-button label="绿幕背景模式" :value="1" />
                </el-radio-group>
            </el-form-item>
            <el-form-item label="背景颜色值：" class="input">
                <el-input :disabled="VBType !== 1" v-model="color" placeholder="#RRGGBB 或 r,g,b" />
                <el-button :disabled="VBType !== 1" type="primary" @click="VbColorChange">应用</el-button>
            </el-form-item>
        </el-form>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ipcRenderer } from "electron";
import { ElMessage } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
export default {
    data() {
        return {
            isStartBeauty: false,
            smooth: 0, //	磨皮, 强度范围 0~1
            whiten: 0, //	美白, 强度范围 0~1
            lipstick: 0, //	红唇, 强度范围 0~1
            blusher: 0, //	腮红, 强度范围 0~1
            thinface: 0, //	瘦脸, 强度范围 0~1
            bigeye: 0, //	大眼, 强度范围 0~1
            color: "",
            VBType: 0,
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
        isOpenCam() {
            return this.appStore.memberList[this.appStore.myUserId].videoStatus === 3;
        },
    },
    created() {
        this.isStartBeauty = this.$rtcsdk.isBeautyStarted();
        const beautyParams = this.$rtcsdk.getBeautyParams();
        if (beautyParams) {
            console.log(beautyParams);
            beautyParams.filters.forEach((item) => {
                switch (item.type) {
                    case 0:
                        this.smooth = item.level;
                        break;
                    case 1:
                        this.whiten = item.level;
                        break;
                    case 2:
                        this.lipstick = item.level;
                        break;
                    case 3:
                        this.blusher = item.level;
                        break;
                    case 4:
                        this.thinface = item.level;
                        break;
                    case 5:
                        this.bigeye = item.level;
                        break;
                }
            });
        }

        const VBConfig = this.$rtcsdk.getVirtualBackgroundParams();
        this.VBType = VBConfig.type;
        if (VBConfig.type === 1) {
            this.color = VBConfig.colorKey;
        }
    },
    methods: {
        //开启关闭美颜
        toggleBeautySwitch(value) {
            if (value) {
                const config = {
                    filters: [
                        { type: 0, level: this.smooth },
                        { type: 1, level: this.whiten },
                        { type: 2, level: this.lipstick },
                        { type: 3, level: this.blusher },
                        { type: 4, level: this.thinface },
                        { type: 5, level: this.bigeye },
                    ],
                };
                const sdkErr = this.$rtcsdk.startBeauty(config);
                if (sdkErr !== 0) {
                    ElMessage.error(`开启失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
                    this.isStartBeauty = false;
                }
            } else {
                this.$rtcsdk.stopBeauty();
            }
        },
        updateBeauty() {
            const config = {
                filters: [
                    { type: 0, level: this.smooth },
                    { type: 1, level: this.whiten },
                    { type: 2, level: this.lipstick },
                    { type: 3, level: this.blusher },
                    { type: 4, level: this.thinface },
                    { type: 5, level: this.bigeye },
                ],
            };
            this.$rtcsdk.updateBeautyParams(config);
        },
        async VBChange(value) {
            if (value === 1) {
                return;
            }
            this.$rtcsdk.stopVirtualBackground();
            if (value === 2) {
                const VBPath = await ipcRenderer.invoke("common", { method: "getVBPath" });

                const sdkErr = this.$rtcsdk.startVirtualBackground({
                    type: 2,
                    bkImgFile: VBPath,
                });
                if (sdkErr !== 0) {
                    ElMessage.error(`开启失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
                    this.VBType = 0;
                }
            }
        },
        async VbColorChange() {
            const VBPath = await ipcRenderer.invoke("common", { method: "getVBPath" });

            this.$rtcsdk.stopVirtualBackground();
            const sdkErr = this.$rtcsdk.startVirtualBackground({
                type: 1,
                colorKey: this.color,
                bkImgFile: VBPath,
            });
            if (sdkErr !== 0) {
                ElMessage.error(`开启失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
    },
};
</script>

<style lang="scss" scoped>
.container {
    display: flex;
    align-items: center;
    .video {
        width: 704px;
        height: 396px;
        .no-video {
            background: #000;
            color: #fff;
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }
    }
    .select {
        width: 100%;
    }
    .form {
        flex: 1;
        margin-left: 10px;
        .el-form-item:last-of-type {
            margin-bottom: 0;
        }
        .slider {
            .el-form-item__content {
                .el-slider {
                    flex: 1;
                }

                .text {
                    width: 45px;
                    text-align: right;
                }
            }
        }
        .input {
            .el-input {
                flex: 1;
                margin-right: 10px;
            }
        }
    }
}
</style>
