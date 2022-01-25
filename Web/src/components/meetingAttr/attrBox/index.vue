<template>
  <div>
    <el-dialog
      :title="otherId ? '成员属性' : '房间属性'"
      :visible.sync="outerVisible"
      width="540px"
      custom-class="attr-box"
      @closed="$emit('closed')"
    >
      <el-dialog
        width="300px"
        title="新增"
        custom-class="attr-box attr-add-box"
        :visible.sync="innerVisible"
        append-to-body
      >
        <div class="form">
          <el-form label-width="80px" :model="addForm" label-position="left">
            <el-form-item label="Key:">
              <el-input v-model="addForm.key" />
            </el-form-item>
            <el-form-item label="Value:">
              <el-input v-model="addForm.value" />
            </el-form-item>
          </el-form>
        </div>

        <div class="btn-group">
          <el-button size="small" type="primary" @click="clickInsideAddBtn">{{
            addForm.edit ? '修改' : '新增'
          }}</el-button>
          <el-button
            size="small" type="primary" @click="innerVisible = false"
          >取消</el-button>
        </div>
      </el-dialog>
      <div class="table">
        <el-table
          ref="singleTable"
          :data="tableData"
          highlight-current-row
          style="width: 100%"
          height="250"
          @current-change="handleCurrentChange"
        >
          <el-table-column property="key" label="键" width="90" />
          <el-table-column property="value" label="值" width="150" />
          <el-table-column property="menderId" label="修改者" width="126" />
          <el-table-column label="修改时间" width="150">
            <template slot-scope="scope">
              {{ scope.row.time | parseTime('YYYY/MM/DD HH:mm:ss') }}
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="btn-group">
        <el-button
          size="small"
          type="primary"
          :loading="adding"
          @click="clickOutsideAddBtn"
        >新增</el-button>
        <el-button
          size="small"
          type="primary"
          :disabled="!currentRow"
          :loading="deleting"
          @click="clickDelBtn"
        >删除</el-button>
        <el-button
          size="small"
          type="primary"
          :disabled="!currentRow"
          :loading="updating"
          @click="clickUpdateBtn"
        >修改</el-button>
        <el-button
          size="small" type="primary" @click="clickClearList"
        >清除列表</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
const attrOption = '{"notifyAll":1}' // 调用SDK接口时添加此参数，将会通知房间内所有成员
import SDKError from '@/SDK/Code'
export default {
  props: {
    otherId: {
      type: [String, null],
      default: null
    }
  },
  data() {
    return {
      outerVisible: true,
      innerVisible: false,
      adding: false, // 增加中
      updating: false, // 更新中
      deleting: false, // 删除中
      addForm: {
        key: '',
        value: '',
        edit: false
      },
      tableData: [],
      currentRow: null
    }
  },
  created() {
    if (this.otherId) {
      // 用户属性回调注册
      CRVideo_GetUserAttrsSuccess.callback = this.GetUserAttrsSuccess // SDK回调接口：获取用户属性成功的通知
      CRVideo_GetUserAttrsFail.callback = this.GetUserAttrsFail // SDK回调接口：获取用户属性失败的通知
      CRVideo_AddOrUpdateUserAttrsRslt.callback = this.AddOrUpdatAttrsRslt // SDK回调接口：新增或修改用户属性的结果通知
      CRVideo_DelUserAttrsRslt.callback = this.DelAttrsRslt // SDK回调接口：删除用户属性的结果通知
      CRVideo_ClearUserAttrsRslt.callback = this.ClearAttrsRslt // SDK回调接口：清除用户属性的结果通知
      CRVideo_NotifyUserAttrsChanged.callback = this.NotifyUserAttrsChanged // SDK通知接口：有用户属性更新通知

      CRVideo_GetUserAttrs([this.otherId]) // SDK主调接口：查询用户属性
    } else {
      CRVideo_GetMeetingAllAttrsSuccess.callback =
        this.GetMeetingAllAttrsSuccess // SDK回调接口：获取房间属性成功的通知
      CRVideo_GetMeetingAllAttrsFail.callback = this.GetMeetingAllAttrsFail // SDK回调接口：获取房间属性失败的通知
      CRVideo_AddOrUpdateMeetingAttrsRslt.callback = this.AddOrUpdatAttrsRslt // SDK回调接口：新增或修改房间属性的结果通知
      CRVideo_DelMeetingAttrsRslt.callback = this.DelAttrsRslt // SDK回调接口：删除房间属性的结果通知
      CRVideo_ClearMeetingAttrsRslt.callback = this.ClearAttrsRslt // SDK回调接口：清除房间属性的结果通知
      CRVideo_NotifyMeetingAttrsChanged.callback =
        this.NotifyMeetingAttrsChanged // SDK通知接口：有房间属性更新通知

      CRVideo_GetMeetingAllAttrs() // SDK主调接口：查询房间属性
    }
  },
  destroyed() {
    if (this.otherId) {
      // 解绑用户属性
      CRVideo_GetUserAttrsSuccess.callback = null
      CRVideo_GetUserAttrsFail.callback = null
      CRVideo_AddOrUpdateUserAttrsRslt.callback = null
      CRVideo_DelUserAttrsRslt.callback = null
      CRVideo_ClearUserAttrsRslt.callback = null
      CRVideo_NotifyUserAttrsChanged.callback = null
    } else {
      // 解绑房间属性
      CRVideo_GetMeetingAllAttrsSuccess.callback = null
      CRVideo_GetMeetingAllAttrsFail.callback = null
      CRVideo_AddOrUpdateMeetingAttrsRslt.callback = null
      CRVideo_DelMeetingAttrsRslt.callback = null
      CRVideo_ClearMeetingAttrsRslt.callback = null
      CRVideo_NotifyMeetingAttrsChanged.callback = null
    }
  },
  methods: {
    // 选中了表格中的某一项
    handleCurrentChange(val) {
      this.currentRow = val
    },
    // 点击了内部弹窗的新增按钮
    clickInsideAddBtn() {
      const { key, value } = this.addForm
      if (!key.length || !value.length) {
        return this.$message.warning(`请输入key和value`)
      }
      const json = {
        [key]: value
      }
      this.innerVisible = false
      if (this.addForm.edit) {
        this.updating = true
      } else {
        this.adding = true
      }
      if (this.otherId) {
        // SDK主调接口：新增或修改用户属性
        CRVideo_AddOrUpdateUserAttrs(
          this.otherId,
          JSON.stringify(json),
          attrOption
        )
      } else {
        CRVideo_AddOrUpdateMeetingAttrs(JSON.stringify(json), attrOption)// SDK主调接口：新增或修改房间属性
      }
    },
    // 房间和用户属性新增或更新的结果回调
    AddOrUpdatAttrsRslt(code) {
      this.updating = false
      this.adding = false
      if (code !== 0) {
        this.$message.error(
          `增加或修改属性失败，错误码: ${code},${SDKError[code]}`
        )
      }
    },
    // 点击了外部的新增
    clickOutsideAddBtn() {
      this.addForm = { key: '', value: '', edit: false }
      this.innerVisible = true
    },
    // 点击了删除
    clickDelBtn() {
      this.$confirm(
        `此操作将删除选中的${this.otherId ? '成员' : '房间'}属性, 是否继续?`,
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        this.deleting = true
        if (this.otherId) {
          // SDK主调接口：删除用户属性
          CRVideo_DelUserAttrs(this.otherId, [this.currentRow.key], attrOption)
        } else {
          // SDK主调接口：删除房间属性
          CRVideo_DelMeetingAttrs([this.currentRow.key], attrOption)
        }
      })
    },
    // 删除操作的结果回调
    DelAttrsRslt(code) {
      this.deleting = false
      if (code !== 0) {
        this.$message.error(`删除失败，错误码: ${code},${SDKError[code]}`)
      }
    },
    // 点击了修改
    clickUpdateBtn() {
      const { key, value } = this.currentRow
      this.addForm = { key, value, edit: true }
      this.innerVisible = true
    },
    // 查询房间属性成功的回调
    GetMeetingAllAttrsSuccess(attrs) {
      this.setTabel(attrs)
    },
    // 查询房间属性失败的回调
    GetMeetingAllAttrsFail(code) {
      if (code !== 0) {
        this.$message.error(
          `获取房间属性失败，错误码: ${code},${SDKError[code]}`
        )
      }
    },
    // 查询用户属性成功的回调
    GetUserAttrsSuccess(attrs) {
      if (attrs[this.otherId]) this.setTabel(attrs[this.otherId])
    },
    // 查询用户属性失败的回调
    GetUserAttrsFail(code) {
      if (code !== 0) {
        this.$message.error(
          `获取房间属性失败，错误码: ${code},${SDKError[code]}`
        )
      }
    },
    // 重置表格数据
    setTabel(data) {
      const tableData = []
      Object.keys(data).forEach((item) => {
        tableData.push({
          key: item,
          value: data[item].value,
          time: data[item].lastModifyTs,
          menderId: data[item].lastModifyUserID
        })
      })
      this.tableData = tableData
    },
    // 点击了清除列表
    clickClearList() {
      this.$confirm(
        `此操作将清除${
          this.otherId ? '该用户所有的成员' : '所有的房间'
        }属性, 是否继续?`,
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        this.adding = true
        this.updating = true
        this.deleting = true
        if (this.otherId) {
          CRVideo_ClearUserAttrs(this.otherId, attrOption) // SDK主调接口：清除用户的所有属性
        } else {
          CRVideo_ClearMeetingAttrs(attrOption) // SDK主调接口：清除房间的所有属性
        }
      })
    },
    // 清除属性的回调结果
    ClearAttrsRslt(code) {
      this.adding = false
      this.updating = false
      this.deleting = false
      if (code !== 0) {
        this.$message.error(`清除属性失败，错误码: ${code},${SDKError[code]}`)
      }
    },
    // 房间属性变化通知
    NotifyMeetingAttrsChanged(adds, updates, delKeys) {
      this.tabelUpdate(adds, updates, delKeys)
    },
    // 用户属性变化通知
    NotifyUserAttrsChanged(UID, adds, updates, delKeys) {
      if (UID === this.otherId) {
        this.tabelUpdate(adds, updates, delKeys)
      }
    },
    // 更新表格
    tabelUpdate(adds, updates, delKeys) {
      // 添加新增的属性
      Object.keys(adds).forEach((key) => {
        this.tableData.push({
          key: key,
          value: adds[key].value,
          time: adds[key].lastModifyTs,
          menderId: adds[key].lastModifyUserID
        })
      })
      // 更新修改的属性
      Object.keys(updates).forEach((key) => {
        const data = this.tableData.find((item) => item.key === key)
        if (data) {
          data.value = updates[key].value
          data.time = updates[key].lastModifyTs
          data.menderId = updates[key].lastModifyUserID
        }
      })
      // 删除属性
      this.tableData = this.tableData.filter(
        (item) => delKeys.indexOf(item.key) === -1
      )
    }
  }
}
</script>

<style lang="scss"></style>

<style lang="scss" scoped>
@import '~@/styles/mixin.scss';

::v-deep .el-table__body-wrapper {
  @include scrollBar;
}
::v-deep .attr-box {
  .el-dialog__header {
    border-bottom: 1px solid #ebeef5;
  }
  .el-dialog__body {
    padding: 0px 12px;
    .form {
      .el-form-item:last-of-type {
        margin-bottom: 0;
      }
    }
    .btn-group {
      padding: 10px 0;
      display: flex;
      justify-content: space-around;
      align-items: center;
      .el-button {
        width: 76px;
      }
    }
  }
  &.attr-add-box .el-dialog__body {
    padding: 20px 30px 0;
  }
}
</style>
