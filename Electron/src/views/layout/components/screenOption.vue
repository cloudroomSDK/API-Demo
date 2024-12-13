<template>
    <div>
        <el-scrollbar height="300px">
            <div class="title">屏幕：</div>
            <div class="list clearfix">
                <div class="pd" v-for="(item, idx) in screenSources" :key="item._sourceId">
                    <div class="item" :class="{ active: selectID === item._sourceId }" @click="(selectID = item._sourceId), (isSelectScreen = true)">
                        <div class="box">
                            <img v-loadPic="item._thumbImage" />
                        </div>
                        <p>屏幕{{ idx + 1 }}</p>
                    </div>
                </div>
            </div>
            <div class="title">窗口：</div>
            <div class="list clearfix">
                <div class="pd" v-for="(item, idx) in windowSources" :key="item._sourceId">
                    <div class="item" :class="{ active: selectID === item._sourceId }" @click="(selectID = item._sourceId), (isSelectScreen = false)">
                        <div class="box">
                            <img class="thumb" v-loadPic="item._thumbImage" />
                        </div>
                        <div class="bottom">
                            <p>{{ item._sourceTitle }}</p>
                            <img v-loadPic="item._iconImage" />
                        </div>
                    </div>
                </div>
            </div>
        </el-scrollbar>
        <div class="ctrl">
            <el-checkbox v-if="appStore.platform === 'win32'" v-model="isShareSound">共享电脑的声音</el-checkbox>
            <el-checkbox v-model="isFluency">流畅优先</el-checkbox>
            <el-button class="btn" type="primary" :disabled="selectID === null" @click="startShare">开始共享</el-button>
        </div>
    </div>
</template>
<script>
import store from "@/store";
import { mapStores } from "pinia";
import { thumbImageBufferToBase64 } from "@/utils";
export default {
    data() {
        return {
            isSelectScreen: false,
            selectID: null,
            isShareSound: false,
            isFluency: false,
            screenSources: [],
            windowSources: [],
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    directives: {
        loadPic: {
            created(el, { value }) {
                setTimeout(() => {
                    el.src = thumbImageBufferToBase64(value);
                }, 0);
            },
        },
    },
    mounted() {
        const captureSources = this.$rtcsdk.getScreenCaptureSources({ width: 190, height: 108 }, { width: 32, height: 32 }); //开启屏幕共享
        this.screenSources = captureSources.filter((item) => item._type === 1);

        this.windowSources = captureSources.filter((item) => item._type === 2);

        console.log(this.screenSources, this.windowSources);
    },
    methods: {
        startShare() {
            console.log(this.selectID);
            const cfg = {
                [this.isSelectScreen ? "monitorID" : "catchWnd"]: this.selectID,
                shareSound: this.isShareSound,
                qp: this.isFluency ? 28 : 22,
                maxKbps: this.isFluency ? 1000 : 2000,
                activateWindow: true,
                borderHighLight: true,
            };
            console.log(cfg);
            this.$rtcsdk.setScreenShareCfg(JSON.stringify(cfg));
            this.appStore.isMyScreenShare = true;
            this.appStore.shareType = 2;
            this.$rtcsdk.startScreenShare(); //开启屏幕共享
            this.$emit("close");
        },
    },
};
</script>
<style lang="scss" scoped>
.title {
    font-size: 16px;
    margin-bottom: 10px;
}
.list {
    .pd {
        float: left;
        width: 33.3333%;
        text-align: center;
    }
    .item {
        display: inline-block;
        margin-bottom: 10px;
        overflow: hidden;
        width: 192px;
        text-align: center;
        border-radius: 6px;
        color: #000;
        border: 1px solid #ccc;
        cursor: pointer;
        &.active {
            background-color: #3981fc;
            color: #fff;
        }
        .box {
            .thumb {
                width: 100%;
                height: 108px;
                object-fit: contain;
            }
        }
        .bottom {
            display: flex;
            line-height: 32px;
            align-items: center;
            padding-left: 10px;
            padding-right: 5px;

            p {
                text-overflow: ellipsis;
                overflow: hidden;
                white-space: nowrap;
                flex: 1;
            }
        }
    }
}
.ctrl {
    padding-top: 20px;
    position: relative;
    .btn {
        float: right;
    }
}
</style>
