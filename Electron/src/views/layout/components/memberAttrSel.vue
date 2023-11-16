<template>
    <div>
        <div v-for="(userInfo, userId) in appStore.memberList" :key="userId" class="list-item">
            <span>{{ userId }}<span v-if="appStore.myUserId === userId">(我)</span></span>
            <el-button class="button" type="primary" plain @click="openMemberAttr(userId)">成员属性</el-button>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
export default {
    data() {
        return {};
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    methods: {
        openMemberAttr(userId) {
            this.$emit("openMamberAttr", userId);
            this.$emit("close");
        },
    },
};
</script>

<style lang="scss" scoped>
.list-item {
    height: 50px;
    line-height: 50px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 10px;

    &:hover {
        background-color: #e5f3ff;
    }
}
</style>
