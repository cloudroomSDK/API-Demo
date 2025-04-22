<template>
    <el-button v-if="appStore.enableMutiVideos" class="btn" type="danger" @click="stop">停止</el-button>
    <el-button v-else class="btn" plain @click="start">开启</el-button>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessage } from "element-plus";
export default {
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    methods: {
        stop() {
            this.appStore.enableMutiVideos = false;
            this.$rtcsdk.setMutiVideos([]);
        },
        start() {
            const camList = this.$rtcsdk.getAllVideoInfo(this.appStore.myUserId).map((item) => item._videoID);
            if (camList.length < 2) {
                ElMessage.warning({
                    message: "当前摄像头数量不足，您也可以添加虚拟摄像头进行测试",
                    duration: 6000,
                });
            }
            this.appStore.enableMutiVideos = true;
            this.$rtcsdk.setMutiVideos(camList);
        },
    },
};
</script>
