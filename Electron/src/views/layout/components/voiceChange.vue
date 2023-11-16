<template>
    <div>
        <div v-for="member in memberList" :key="member.userId" class="list-item">
            <span>{{ member.userId }}<span v-if="appStore.myUserId === member.userId">(我)</span></span>
            <el-select v-model="member.type" class="select" @change="selectChange($event, member.userId)">
                <el-option label="原声" :value="0" />
                <el-option label="低沉" :value="1" />
                <el-option label="尖锐" :value="2" />
            </el-select>
        </div>
    </div>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
export default {
    data() {
        return {
            memberList: [],
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        this.memberList = Object.keys(this.appStore.memberList).map((key) => {
            return {
                userId: key,
                type: this.$rtcsdk.getVoiceChangeType(key),
            };
        });
    },
    methods: {
        openMemberAttr(userId) {
            this.$emit("openMamberAttr", userId);
            this.$emit("close");
        },
        selectChange(type, userId) {
            this.$rtcsdk.setVoiceChange(userId, type);
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
    .select {
        width: 100px;
    }

    &:hover {
        background-color: #e5f3ff;
    }
}
</style>
