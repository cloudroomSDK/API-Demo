<template>
    <el-button class="btn" plain @click="start"
        >开始
        <i v-if="hasUnreadMessage" class="hot"></i>
        <el-drawer v-model="drawer" title="房间消息" append-to-body direction="rtl" size="400px">
            <div class="container">
                <el-scrollbar class="scrollbar" height="100%" ref="scrollbar" always>
                    <ul>
                        <li v-for="(item, idx) in list" :key="idx" class="clearfix">
                            <div
                                class="chat"
                                :class="{
                                    isMe: appStore.myUserId === item.userId,
                                }"
                            >
                                <span class="time">{{ parseTime(item.time, "HH:mm") }}</span>
                                <span v-if="appStore.myUserId !== item.userId" class="userId">{{ item.userId }}:</span>
                                <p>{{ item.msg }}</p>
                            </div>
                        </li>
                    </ul>
                </el-scrollbar>
                <div class="send-box">
                    <el-input v-model="textarea" :rows="6" type="textarea" resize="none" placeholder="聊天消息" @keyup.ctrl.enter="send"></el-input>
                    <el-tooltip class="box-item" effect="light" content="按Ctrl+Enter键发送消息" placement="top-start">
                        <el-button type="primary" plain class="btn" :disabled="!textarea.length" @click="send">发送</el-button>
                    </el-tooltip>
                </div>
            </div>
        </el-drawer>
    </el-button>
</template>

<script>
import store from "@/store";
import { mapStores } from "pinia";
import { errDesc } from "@/rtcsdk/sdkErr";
export default {
    data() {
        return {
            hasUnreadMessage: false,
            drawer: false,
            textarea: "",
            list: [], // {"CmdType":"IM","IMMsg":"2222",time: xxx}
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        this.callbackHanle(true);
        this.list = [];
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("notifyMeetingCustomMsg", this.notifyMeetingCustomMsg);
            this.$rtcsdk[bool ? "on" : "off"]("sendMeetingCustomMsgRslt", this.sendMeetingCustomMsgRslt);
        },
        start() {
            this.hasUnreadMessage = false;
            this.drawer = true;
            this.$nextTick(() => {
                this.$refs.scrollbar?.setScrollTop(9999);
            });
        },
        sendMeetingCustomMsgRslt(sdkErr, cookie) {
            if (sdkErr != 0) {
                ElMessage.error(`删除属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        notifyMeetingCustomMsg(fromUserID, msg) {
            /* 约定的消息的格式为：
        {
            "CmdType": "IM",
            "IMMsg": "312312"
        }
      */
            msg = JSON.parse(msg);
            if (msg.CmdType !== "IM") return;

            this.list.push({
                userId: fromUserID,
                msg: msg.IMMsg,
                time: new Date(),
            });
            this.$nextTick(() => {
                this.$refs.scrollbar.setScrollTop(9999);
            });

            if (!this.drawer) {
                this.hasUnreadMessage = true; //显示按钮上的小红点
            }
        },
        send() {
            if (!this.textarea.trim().length) {
                return;
            }

            /* 约定的消息的格式为：
        {
            "CmdType": "IM",
            "IMMsg": "312312"
        }
      */
            const json = JSON.stringify({
                CmdType: "IM",
                IMMsg: this.textarea,
            });
            this.$rtcsdk.sendMeetingCustomMsg(json);
            this.textarea = "";
        },
    },
};
</script>

<style lang="scss" scoped>
.hot {
    position: absolute;
    right: -5px;
    top: -5px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background-color: #f56c6c;
}

.container {
    display: flex;
    flex-direction: column;
    height: 100%;

    .scrollbar {
        flex: 1;
        margin-bottom: 10px;
        margin-top: 10px;
        padding: 0 20px;

        * {
            user-select: text;
        }
        li {
            margin-bottom: 20px;
            .chat {
                max-width: 80%;
                float: left;
                &.isMe {
                    float: right;
                    text-align: right;
                    .time {
                        margin-right: 0;
                    }
                    p {
                        text-align: left;
                    }
                }
                .time {
                    color: #666666;
                    margin-right: 10px;
                }
            }
        }
    }

    .send-box {
        position: relative;
        margin: 10px;
        .btn {
            position: absolute;
            bottom: 10px;
            right: 10px;
        }
    }
}
</style>
