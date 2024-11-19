<template>
    <div class="container">
        <div v-for="member in memberList" :key="member.userId">
            <div class="list-item">
                <span>{{ member.userId }}<span v-if="appStore.myUserId === member.userId">(我)</span></span>
                <el-select v-model="member.type" class="select" @change="selectChange($event, member.userId)">
                    <el-option label="原声" :value="0" />
                    <el-option label="中性女声(适合女用)" :value="1"></el-option>
                    <el-option label="中性男声(适合男用)" :value="2"></el-option>
                    <el-option label="甜美女声(适合女用)" :value="3"></el-option>
                    <el-option label="低沉男声(适合男用)" :value="4"></el-option>
                    <el-option label="娃娃音(适合女用)" :value="5"></el-option>
                    <el-option label="娃娃音(适合男用)" :value="6"></el-option>
                    <el-option label="自定义值" :value="-1"></el-option>
                </el-select>
            </div>
            <div v-if="member.type === -1" class="slider">
                <el-slider :min="-50" :max="50" v-model="member.value" @change="selectChange($event + 150, member.userId)" />
            </div>
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
            const value = this.$rtcsdk.getVoiceChangeType(key);
            return {
                userId: key,
                type: value >= 100 ? -1 : value, //如果值大于100，则表示自定义取值
                value: value >= 100 ? value - 150 : 0, //如果值大于100，demo上把值减去150再显示
            };
        });
        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifySetVoiceChange", this.notifySetVoiceChange);
        },
        openMemberAttr(userId) {
            this.$emit("openMamberAttr", userId);
            this.$emit("close");
        },
        selectChange(type, userId) {
            console.log(type, userId);
            if (type === -1) {
                type = 150; //自定义取值范围，100~200。150为原声
            }
            this.$rtcsdk.setVoiceChange(userId, type);
        },
        notifySetVoiceChange(userID, type, oprUserID) {
            if (oprUserID === this.appStore.myUserId) return;
            const user = this.memberList.find((item) => item.userId === userID);
            if (user) {
                user.type = type >= 100 ? -1 : type;
                user.value = type >= 100 ? type - 150 : 0;
            }
        },
    },
};
</script>

<style lang="scss" scoped>
.container {
    padding-bottom: 4px;
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
    .slider {
        padding: 0 20px;
    }
}
</style>
