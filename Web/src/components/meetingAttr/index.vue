<template>
  <div>
    <el-collapse v-model="activeNames">
      <el-collapse-item title="成员列表" name="1">
        <div v-if="meetingState === 2" class="memberList">
          <div v-for="item in memberList" :key="item.userID" class="member">
            <span
              class="name text-overflow"
            >{{ item.nickname }}
              <template v-if="item.userID === UID">(我)</template>
            </span>
            <div class="right">
              <el-button
                class="btn"
                type="primary"
                plain
                @click="$emit('clickMemberAttr',item.userID)"
              >成员属性</el-button>
            </div>
          </div>
        </div>
        <div v-else>请先进入房间</div>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import AttrBox from './attrBox'
export default {
  data() {
    return {
      activeNames: ''
    }
  },
  computed: {
    ...mapGetters(['UID', 'meetingState', 'memberList'])
  },
  watch: {
    meetingState(value) {
      this.activeNames = value === 2 ? '1' : ''
    }
  },
  methods: {
    openMeetingAttr(UID) {
      this.$msgbox({
        title: '成员属性',
        showConfirmButton: false,
        customClass: 'attr-box',
        message: this.$createElement(AttrBox, {
          key: Math.random(), // 给key赋值是为了让element-ui弹出层每次都重新渲染
          props: {
            UID
          }
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.el-collapse {
  border: 0 none;
  ::v-deep {
    .el-collapse-item__wrap,
    .el-collapse-item__header {
      border: 0 none;
      font-size: 20px;
    }
  }
  .memberList {
    font-size: 16px;
    .member {
      height: 40px;
      line-height: 40px;
      .name {
        display: inline-block;
        max-width: 200px;
      }
      .right {
        float: right;
        height: 100%;
        .btn {
          padding: 2px 5px;
          font-size: 16px;
          background-color: transparent;
          border-color: #3981fc;
          color: #3981fc;
          border-radius: 3px;
          &:hover {
            background-color: #3981fc;
            border-color: #3981fc;
            color: #fff;
          }
          &:focus {
            background-color: #3981fc;
            border-color: #3981fc;
            color: #fff;
          }
        }
      }
    }
  }
}
</style>
