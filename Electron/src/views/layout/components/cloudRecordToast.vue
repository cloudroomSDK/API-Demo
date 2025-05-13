<template>
    <div>
        <p>文件: {{ info.fileName }}</p>
        <p>大小: {{ keepTwoDecimal(info.fileSize / 1000000) }}MB</p>
        <p>视频时长: {{ parseInt(info.duration / 1000) }}秒</p>
        <p>
            状态:
            <span v-if="info.state === 2">正在进行...</span>
            <span v-if="info.state === 4">正在上传...进度: {{ info.progress }}%</span>
            <span v-if="info.state === 5">完成</span>
            <span v-if="info.state === 6">上传出错...</span>
        </p>
        <p v-if="info.state === 6">错误码: {{ info.errCode }},{{ info.errDesc }}</p>
        <p v-if="info.state === 5">您可以登录SDK后台查看录像</p>
    </div>
</template>

<script>
export default {
    props: {
        info: {
            type: Object,
            required: true,
        },
    },
    methods: {
        // 四舍五入保留两位小数
        keepTwoDecimal(num) {
            return Math.round(num * 100) / 100;
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
