<template>
  <div class="login-container">
    <el-form
      class="login-form"
      auto-complete="on"
      label-position="left"
      :class="{ mobile: isMobile }"
    >
      <div class="title-container">
        <h3 class="title">RTC Web API Demo</h3>
      </div>
      <div class="w">
        <el-form-item>
          <el-input
            ref="addr"
            v-model="loginForm.addr"
            name="addr"
            type="text"
            tabindex="1"
            auto-complete="on"
          >
            <span slot="prefix" class="text">服务器：</span>
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-input
            ref="appId"
            v-model="loginForm.appId"
            placeholder=""
            name="appId"
            type="text"
            tabindex="2"
            auto-complete="on"
          >
            <span slot="prefix" class="text">AppID：</span>
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-input
            :key="passwordType"
            ref="appSecret"
            v-model="loginForm.appSecret"
            :type="passwordType"
            name="appSecret"
            tabindex="3"
            auto-complete="on"
            @keyup.enter.native="handleLogin"
          >
            <span slot="prefix" class="text">AppSecret：</span>
          </el-input>
          <span class="show-pwd" @click="showPwd">
            <svg-icon
              :icon-class="passwordType === 'password' ? 'eye' : 'eye-open'"
            />
          </span>
        </el-form-item>

        <el-button
          class="loginBtn"
          :loading="loading"
          type="primary"
          @click.native.prevent="handleLogin"
        >登录</el-button>
       <div class="version">
          <span>Ver：{{ demoVer }}</span>
          <span>SDKVer：{{ sdkVer }}</span>
        </div>
      </div>
    </el-form>
  </div>
</template>

<script>
import packageJson from '../../../package.json'
import SDKError from '@/SDK/Code'
import config from '@/config/sdk'
import MD5 from 'crypto-js/md5'
import { mapGetters } from 'vuex'
import Cookies from 'js-cookie'

export default {
  name: 'Login',
  data() {
    return {
      loginForm: {
        addr: Cookies.get('addr') || config.addr || window.location.host,
        appId: '默认',
        appSecret: config.appSecret
      },
      loading: false,
      passwordType: 'password',
      redirect: undefined
    }
  },
  computed: {
    ...mapGetters(['isMobile']),
    sdkVer() {
      return CRVideo_GetSDKVersion()
    },
    demoVer() {
      return packageJson.version
    }
  },
  watch: {
    $route: {
      handler: function (route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  methods: {
    showPwd() {
      this.passwordType = this.passwordType === 'password' ? '' : 'password'
      this.$nextTick(() => {
        this.$refs.appSecret.focus()
      })
    },
    handleLogin() {
      let { appId, appSecret, addr } = this.loginForm

      if (appId === '') {
        appId = config.appId
        appSecret = config.appSecret
      }

      if (!appSecret) {
        return this.$message.error('请输入AppSecret')
      }

      this.loading = true
      this.$store
        .dispatch('user/login', {
          addr,
          AppId: appId,
          MD5_AppSecret: appId != '默认' ? MD5(appSecret).toString() : '默认'
        })
        .then(() => {
          this.loading = false
          this.$router.push({ path: this.redirect || '/' })
        })
        .catch((code) => {
          this.loading = false
          this.$message.error(`错误码: ${code},${SDKError[code]}`)
        })
    }
  }
}
</script>

<style lang="scss" scoped>
$mainColor: #3981fc;
$dark_gray: #999;

.login-container {
  min-height: 100%;
  width: 100%;
  background: url('~@/assets/image/bg.jpg') center center no-repeat;
  overflow: hidden;

  .login-form {
    position: absolute;
    background-color: #fff;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    width: 416px;
    height: 452px;
    border-radius: 7px;
    padding-top: 70px;
    overflow: hidden;
    &.mobile {
      transform: translate(-50%, -50%) scale(0.8);
    }
    .title-container {
      position: relative;

      .title {
        font-size: 32px;
        color: $mainColor;
        margin: 0px auto 56px auto;
        text-align: center;
        font-weight: bold;
      }
    }
    .w {
      width: 310px;
      margin: 0 auto;
      ::v-deep .el-form-item {
        border-radius: 5px;
        height: 44px;
        line-height: 44px;
        .el-input {
          height: 100%;
          .text {
            display: inline-block;
            width: 100px;
            text-align: right;
            color: $dark_gray;
          }
          input {
            padding-left: 110px;
            &::-webkit-input-placeholder {
              color: #666;
            }
            &::-moz-input-placeholder {
              color: #666;
            }
            &::-ms-input-placeholder {
              color: #666;
            }
          }
        }
        .show-pwd {
          position: absolute;
          right: 10px;
          font-size: 16px;
          color: $dark_gray;
          cursor: pointer;
          user-select: none;
        }
      }
      .loginBtn {
        height: 44px;
        width: 100%;
        margin-bottom: 16px;
      }

      .version {
        padding: 0 10px;
        display: flex;
        justify-content: space-between;
        text-align: center;
        font-size: 14px;
      }
    }
    .link {
      text-align: center;
      a {
        position: relative;
        color: $mainColor;
        font-size: 14px;
        &:hover::before {
          position: absolute;
          bottom: -4px;
          left: 0;
          width: 100%;
          height: 0px;
          content: '';
          border-bottom: 1px solid $mainColor;
        }
      }
    }
  }
}
</style>
