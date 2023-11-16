<template>
    <div>
        <p>文件: {{ info.fileName }}</p>
        <p>大小: {{ keepTwoDecimal(info.fileSize / 1000000) }}MB</p>
        <p>视频时长: {{ parseInt(info.duration / 1000) }}秒</p>
        <p>
            状态:
            <span v-if="info.state === 0">开始</span>
            <span v-if="info.state === 1">录制中</span>
            <span v-if="info.state === 2">录制完成</span>
            <span v-if="info.state === 3">录制出错</span>
        </p>
        <p v-if="info.state === 3">错误码: {{ info.errCode }}</p>
        <p v-if="info.state === 2 && info.filePath"><el-link type="primary" @click="open">点击打开</el-link></p>
    </div>
</template>

<script>
import { ipcRenderer } from "electron";

export default {
    data() {
        return {
            webUrl: null,
        };
    },
    props: {
        info: {
            type: Object,
            required: true,
        },
    },
    created() {},
    methods: {
        // 四舍五入保留两位小数
        keepTwoDecimal(num) {
            return Math.round(num * 100) / 100;
        },
        open() {
            ipcRenderer.send("electron-open-localMixer", this.info.filePath); //通知主进程弹出文件选择框
        },
    },
};
</script>

<style lang="scss" scoped>
p {
    word-break: break-all;
    a {
        color: #3981fc;
        &:hover {
            text-decoration: underline;
        }
    }
}
</style>
