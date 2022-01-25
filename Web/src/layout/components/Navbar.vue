<template>
  <div class="navbar">
    <hamburger
      v-if="isSmallScreen"
      :is-active="sidebar.opened"
      class="hamburger-container"
      @toggleClick="toggleSideBar"
    />

    <breadcrumb class="breadcrumb-container" />

    <div class="right-menu">
      <el-dropdown class="avatar-container" trigger="click">
        <span class="el-dropdown-link">
          <i class="icon-menu" />
        </span>
        <el-dropdown-menu slot="dropdown" class="user-dropdown">
          <a target="_blank" href="https://sdk.cloudroom.com/">
            <el-dropdown-item><i class="icon icon-home" />官网</el-dropdown-item>
          </a>
          <a
            target="_blank"
            href="https://github.com/cloudroomSDK/API-Demo/tree/main/Web"
          >
            <el-dropdown-item><i class="icon icon-github" />Github</el-dropdown-item>
          </a>
          <a target="_blank" href="https://sdk.cloudroom.com/sdkdoc/H5/">
            <el-dropdown-item><i class="icon icon-word" />文档</el-dropdown-item>
          </a>
          <el-dropdown-item @click.native="logout">
            <span
              style="display: block" class="logout"
            ><i class="icon icon-logout" />注销</span>
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Breadcrumb from '@/components/Breadcrumb'
import Hamburger from '@/components/Hamburger'

export default {
  components: {
    Breadcrumb,
    Hamburger
  },
  computed: {
    ...mapGetters(['sidebar', 'meetingState', 'isSmallScreen'])
  },
  methods: {
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    logout() {
      if (this.meetingState) {
        this.$confirm('您正在房间中,继续操作将退出房间,是否继续?', '提示', {
          type: 'warning'
        })
          .then(() => {
            CRVideo_ExitMeeting()
            this.$store.commit('state/RESET_STATE')
            this.$store.dispatch('user/logout')
            this.$router.push(`/login`)
          })
          .catch(() => {})
      } else {
        this.$store.dispatch('user/logout')
        this.$router.push(`/login`)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/styles/mixin.scss';

.icon {
  float: left;
  margin-top: 6px;
  margin-right: 12px;
  width: 24px;
  height: 24px;
  background-repeat: no-repeat;
  &.icon-home {
    background-image: url('~@/assets/image/icon/home.png');
    @include pic2x {
      background-image: url('~@/assets/image/icon/home@2x.png');
    }
  }
  &.icon-github {
    background-image: url('~@/assets/image/icon/github.png');
    @include pic2x {
      background-image: url('~@/assets/image/icon/github@2x.png');
    }
  }
  &.icon-word {
    background-image: url('~@/assets/image/icon/word.png');
    @include pic2x {
      background-image: url('~@/assets/image/icon/word@2x.png');
    }
  }
  &.icon-logout {
    background-image: url('~@/assets/image/icon/logout.png');
    @include pic2x {
      background-image: url('~@/assets/image/icon/logout@2x.png');
    }
  }
}
.icon-menu {
  display: inline-block;
  width: 32px;
  height: 32px;
  background-size: cover;
  margin-top: 9px;
  background-image: url('~@/assets/image/icon/menu.png');
  @include pic2x {
    background-image: url('~@/assets/image/icon/menu@2x.png');
  }
}
.navbar {
  height: 50px;
  line-height: 50px;
  overflow: hidden;
  position: relative;
  background: #fff;
  z-index: 1;
  box-shadow: 0 1px 4px rgb(0 14 27 / 26%);

  .hamburger-container {
    height: 100%;
    float: left;
    cursor: pointer;
    transition: background 0.3s;
    -webkit-tap-highlight-color: transparent;

    &:hover {
      background: rgba(0, 0, 0, 0.025);
    }
  }

  .breadcrumb-container {
    float: left;
  }

  .right-menu {
    float: right;
    height: 100%;
    line-height: 50px;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #5a5e66;
      vertical-align: text-bottom;

      &.hover-effect {
        cursor: pointer;
        transition: background 0.3s;

        &:hover {
          background: rgba(0, 0, 0, 0.025);
        }
      }
    }

    .avatar-container {
      cursor: pointer;
      margin-right: 23px;
      height: 100%;
    }
  }
}
</style>
