<template>
    <div class="setting">
        <div class="text-input bg">
            <span>服务器:</span>
            <div class="right">
                <input type="text" v-model="addr" />
            </div>
        </div>
        <div class="text-input">
            <span>通讯安全:</span>
            <div class="right">
                <label> <input type="radio" name="com" :value="0" v-model="protocol" />http </label>
                <label> <input type="radio" name="com" :value="1" v-model="protocol" />标准https </label>
            </div>
        </div>
        <div class="text-input">
            <span>鉴权方式:</span>
            <div class="right">
                <label> <input type="radio" name="auth" :value="false" v-model="isTokenAuth" />密码 </label>
                <label> <input type="radio" name="auth" :value="true" v-model="isTokenAuth" />动态Token </label>
            </div>
        </div>
        <div v-if="isTokenAuth" class="text-input">
            <span>动态Token:</span>
            <div class="right">
                <textarea v-model="token"></textarea>
            </div>
        </div>
        <template v-else>
            <div class="text-input">
                <span>APP ID:</span>
                <div class="right">
                    <input type="text" v-model="appId" />
                </div>
            </div>
            <div class="text-input">
                <span>APP Secret:</span>
                <div class="right">
                    <input type="password" v-model="appSecret" />
                </div>
            </div>
        </template>
        <div class="btn-grounp">
            <div class="btn">
                <el-button type="primary" round plain @click="reset">重置</el-button>
            </div>
            <div class="btn">
                <el-button type="primary" round @click="sava">保存</el-button>
            </div>
        </div>
    </div>
</template>
<script>
import electronStore from "@/store/electron";
import store from "@/store";
import { mapStores } from "pinia";
export default {
    name: "Setting",
    data() {
        return {
            addr: "",
            appId: "",
            appSecret: "",
            token: "",
            protocol: 1,
            isTokenAuth: false,
        };
    },
    computed: {
        ...mapStores(store), //使用选项试api，该方法会在vue实例里添加appStore属性
    },
    created() {
        this.init();
    },
    methods: {
        init() {
            const [addr, appId, appSecret, isTokenAuth, token, protocol] = electronStore.get(["addr", "appId", "appSecret", "isTokenAuth", "token", "protocol"]);
            this.addr = addr;
            this.appId = appId;
            this.appSecret = appSecret;
            this.isTokenAuth = isTokenAuth;
            this.token = token;
            this.protocol = protocol;
        },
        reset() {
            electronStore.del(["addr", "appId", "appSecret", "isTokenAuth", "token", "protocol"]);
            this.init();
        },
        sava() {
            const obj = Object.assign(
                {
                    addr: this.addr,
                    protocol: this.protocol,
                    isTokenAuth: this.isTokenAuth,
                },
                this.isTokenAuth
                    ? {
                          token: this.token,
                      }
                    : {
                          appId: this.appId,
                          appSecret: this.appSecret,
                      }
            );
            electronStore.set(obj);

            if(this.appStore.isLogin) {
              this.$rtcsdk.logout();
              this.appStore.isLogin = false;
            }
            this.$emit("close");
        },
    },
};
</script>

<style lang="scss" scoped>
.setting {
    padding: 8px;

    .text-input {
        font-size: 14px;
        line-height: 20px;
        margin-bottom: 10px;
        display: flex;
        justify-content: right;
        align-items: center;
        flex-wrap: nowrap;

        &.bg {
            font-size: 18px;
            line-height: 28px;
        }

        span {
            flex: 1;
        }

        .right {
            width: 210px;

            input[type="text"],
            input[type="password"] {
                height: 28px;
                border-radius: 14px;
                width: 100%;
                border: 1px solid #bbb;
                padding: 0 10px;
            }

            label {
                cursor: pointer;
                margin-right: 10px;

                input[type="radio"] {
                    margin-right: 4px;
                }
            }

            textarea {
                resize: none;
                border-color: #bbb;
                border-radius: 6px;
                height: 120px;
                width: 100%;
                padding: 4px;
            }
        }
    }

    .btn-grounp {
        // position: absolute;
        // bottom: 0;
        // width: 300px;

        .btn {
            height: 30px;
            margin-bottom: 10px;

            button {
                display: block;
                width: 100%;
                height: 100%;
            }
        }
    }
}
</style>
