<template>
    <div class="container">
        <div class="box" v-loading="loading">
            <div class="title">API Demo</div>
            <p class="desc">创建一个新房间或输入房间号加入已有房间</p>
            <div class="input-box">
                <el-input class="input" v-model.number="meetId" placeholder="请输入房间号" />
            </div>
            <div class="input-box">
                <el-input class="input" v-model="nickname" placeholder="请输入昵称" @change="nicknameChange" />
            </div>
            <div class="btn">
                <el-button type="primary" round @click="enterMeetingBtn">进入房间</el-button>
            </div>
            <p class="or tc">或者</p>
            <div class="btn">
                <el-button type="primary" plain round @click="createMeetingBtn">创建房间</el-button>
            </div>
            <p class="loginset tc">
                <a href="javascript:void(0);" @click="dialogVisible = true">登录设置</a>
                <el-dialog class="dialog" v-model="dialogVisible" title="设置" width="360" append-to-body>
                    <Setting @close="dialogVisible = false"></Setting>
                </el-dialog>
            </p>
            <div class="version tc">
                <p>Demo Version: V{{ AppVersion }}</p>
                <p>SDK Version: V{{ SdkVersion }}</p>
            </div>
        </div>
    </div>
</template>

<script>
import electronStore from "@/store/electron";
import Setting from "@/components/setting";
import MD5 from "md5";
import store from "@/store";
import { mapStores } from "pinia";
import { ElMessage } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
import { version } from "../../package.json";
export default {
    data() {
        return {
            loading: false,
            AppVersion: "",
            SdkVersion: "",
            meetId: "",
            nickname: "",
            dialogVisible: false,
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    components: {
        Setting,
    },
    created() {
        this.SdkVersion = this.$rtcsdk.getVersion();
        this.AppVersion = version;

        const [meetId, nickname] = electronStore.get(["meetId", "nickname"]);
        this.nickname = nickname;
        this.meetId = meetId;

        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            this.$rtcsdk[bool ? "on" : "off"]("loginRslt", this.loginRslt);
            this.$rtcsdk[bool ? "on" : "off"]("enterMeetingRslt", this.enterMeetingRslt);
            this.$rtcsdk[bool ? "on" : "off"]("createMeetingSuccess", this.createMeetingSuccess);
            this.$rtcsdk[bool ? "on" : "off"]("createMeetingFail", this.createMeetingFail);
        },
        loginRslt(sdkErr, cookie) {
            if (sdkErr !== 0) {
                this.loading = false;
                return ElMessage.error(`登录失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }

            const json = JSON.parse(cookie);
            this.appStore.myUserId = json.data.userId;

            electronStore.set("userId", json.data.userId);
            electronStore.set("nickname", json.data.nickname);
            this.appStore.isLogin = true;

            if (json.cmd === "enterMeeting") {
                console.log(this.meetId);
                this.enterMeeting(this.meetId);
            } else {
                // 创建房间的逻辑
                this.createMeeting();
            }
        },
        enterMeetingRslt(sdkErr) {
            this.loading = false;
            if (sdkErr !== 0) {
                return ElMessage.error(`进入房间失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
            electronStore.set("meetId", this.meetId);
            this.appStore.meetId = this.meetId;
            this.$router.push("/layout");
        },
        enterMeeting() {
            this.$rtcsdk.enterMeeting(this.meetId);
        },
        createMeeting() {
            this.$rtcsdk.createMeeting();
        },
        createMeetingSuccess(meetId) {
            console.log("创建房间成功,会议号:", meetId);
            this.meetId = meetId;
            this.enterMeeting();
        },
        createMeetingFail(sdkErr) {
            this.loading = false;
            ElMessage.error(`创建房间失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
        },
        enterMeetingBtn() {
            if (!this.meetId) {
                return ElMessage({
                    message: "请输入房间号",
                    type: "warning",
                });
            } else if (String(this.meetId).length !== 8) {
                return ElMessage({
                    message: "请输入8位房间号",
                    type: "warning",
                });
            }

            this.loading = true;
            if (this.appStore.isLogin) {
                this.enterMeeting();
            } else {
                this.login("enterMeeting");
            }
        },
        createMeetingBtn() {
            this.loading = true;
            if (this.appStore.isLogin) {
                this.createMeeting();
            } else {
                this.login("createMeeting");
            }
        },
        login(cmd) {
            const [addr, appId, appSecret, token, isTokenAuth, protocol] = electronStore.get(["addr", "appId", "appSecret", "token", "isTokenAuth", "protocol"]);

            const loginObj = Object.assign(
                {
                    _serverAddr: addr,
                    _sdkAuthType: Number(!isTokenAuth), //0：token鉴权方式,	1：appID + appSecret鉴权方式
                    _userID: this.nickname,
                    _nickName: this.nickname,
                    _webProtocol: protocol, // 0：http 1：标准https 2:不验证服务器SSL证书，支持自签证书
                },
                isTokenAuth ? { _token: token } : { _appID: appId, _md5_appSecret: MD5(appSecret) }
            );

            const cookie = JSON.stringify({
                data: {
                    userId: this.nickname,
                    nickname: this.nickname,
                },
                cmd,
            });
            console.log("loginObj:", loginObj, "cookie: ", cookie);

            this.$rtcsdk.login(loginObj, cookie);
        },
        nicknameChange() {
            if (this.appStore.isLogin) {
                this.$rtcsdk.logout();
                this.appStore.isLogin = false;
            }
        },
    },
};
</script>
<style lang="scss" scoped>
.container {
    padding: 32px;
    height: 100vh;
    position: relative;
    background: url("@/assets/bg.jpg") center;

    .box {
        background-color: #fff;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 400px;
        height: 400px;
        padding: 30px;

        .title {
            color: #3981fc;
            font-size: 20px;
        }

        .desc {
            line-height: 30px;
        }

        .input-box {
            width: 100%;
            height: 40px;
            font-size: 16px;
            border-radius: 20px;
            margin-bottom: 10px;

            .input {
                width: 100%;
                height: 100%;

                :deep .el-input__wrapper {
                    border-radius: 20px;
                    padding: 15px;
                }
            }
        }

        .or {
            margin: 8px 0;
            position: relative;
            color: #999;

            &::after,
            &::before {
                position: absolute;
                content: "";
                top: 50%;
                width: 120px;
                height: 1px;
                background-color: #999;
            }

            &::before {
                left: 0px;
            }

            &::after {
                right: 0px;
            }
        }

        .btn {
            width: 100%;
            height: 40px;

            button {
                display: block;
                width: 100%;
                height: 100%;
            }
        }

        .loginset {
            margin-top: 12px;
            // font-size: 14px;
        }

        .version {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 12px;
            color: #999;
        }
    }
}
</style>
