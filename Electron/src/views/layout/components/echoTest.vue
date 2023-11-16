<template>
    <div class="content">
        <template v-if="isStarting">
            <span>正在语音测试，{{ count }}秒后自动结束</span>
            <el-button type="danger" class="btn" @click="stop">停止</el-button>
        </template>
        <template v-else>
            <span>未开始</span>
            <el-button type="primary" class="btn" @click="start">开始</el-button>
        </template>
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
            isStarting: false,
            count: 10,
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        this.isStarting = this.$rtcsdk.isEchoTesting();
    },
    unmounted() {
        if (this.isStarting) {
            this.stop();
        }
    },
    methods: {
        stop() {
            clearInterval(this.timerId);
            this.$rtcsdk.stopEchoTest();
            this.isStarting = false;
        },
        start() {
            const sdkErr = this.$rtcsdk.startEchoTest();
            if (sdkErr !== 0) {
                return ElMessage.error(`启动失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
            this.isStarting = true;
            this.count = 10;
            clearInterval(this.timerId);
            this.timerId = setInterval(() => {
                if (--this.count === 0) {
                    this.stop();
                }
            }, 1000);
        },
    },
};
</script>

<style lang="scss" scoped>
.content {
    display: flex;
    align-items: center;
    span {
        flex: 1;
    }
}
</style>
