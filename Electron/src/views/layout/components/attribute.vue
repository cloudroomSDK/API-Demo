<template>
    <div>
        <el-table :data="tableFormat" height="250" style="width: 100%" highlight-current-row @current-change="currentChange" border empty-text="没有数据">
            <el-table-column prop="key" label="键" />
            <el-table-column prop="value" label="值" />
            <el-table-column prop="lastModifyUserID" label="修改者" />
            <el-table-column label="修改时间" width="170px">
                <template #default="scope">
                    <span>{{ parseTime(scope.row.lastModifyTs) }}</span>
                </template>
            </el-table-column>
        </el-table>
        <div class="btn-group">
            <el-button type="primary" @click="add">新增</el-button>
            <el-button type="primary" :disabled="!selectRow" @click="delAttr">删除</el-button>
            <el-button type="primary" @click="clearAll">清除列表</el-button>
            <el-button type="primary" :disabled="!selectRow" @click="edit">修改</el-button>
        </div>

        <el-dialog v-model="dialogVisible" width="30%" :title="dialogIsEdit ? '修改' : '新增'" append-to-body>
            <el-form :model="form" label-width="60px">
                <el-form-item label="Key: ">
                    <el-input v-model="form.key" :disabled="dialogIsEdit" />
                </el-form-item>
                <el-form-item label="Value: ">
                    <el-input v-model="form.value" />
                </el-form-item>
                <el-form-item class="edit-btn-group">
                    <el-button type="primary" plain @click="dialogVisible = false">取消</el-button>
                    <el-button type="primary" @click="onSubmit">{{ dialogIsEdit ? "修改" : "新增" }}</el-button>
                </el-form-item>
            </el-form>
        </el-dialog>
    </div>
</template>

<script>
import { ElMessage } from "element-plus";
import { errDesc } from "@/rtcsdk/sdkErr";
export default {
    props: ["extend"],
    computed: {
        userId() {
            return this.extend;
        },
        tableFormat() {
            return Object.keys(this.tableData).map((key) => {
                return {
                    key,
                    value: this.tableData[key].value,
                    lastModifyUserID: this.tableData[key].lastModifyUserID,
                    lastModifyTs: this.tableData[key].lastModifyTs,
                };
            });
        },
    },
    data() {
        return {
            tableData: [],
            selectRow: null,
            dialogIsEdit: false,
            dialogVisible: false,
            form: {
                key: "",
                value: "",
            },
        };
    },
    created() {
        console.log("--------", this.userId);
        if (this.userId) {
            this.$rtcsdk.getUserAttrs(JSON.stringify([this.userId]));
        } else {
            this.$rtcsdk.getMeetingAllAttrs();
        }
        this.callbackHanle(true);
    },
    unmounted() {
        this.callbackHanle(false);
    },
    methods: {
        //注册SDK回调
        callbackHanle(bool) {
            if (this.userId) {
                this.$rtcsdk[bool ? "on" : "off"]("getUserAttrsSuccess", this.getUserAttrsSuccess);
                this.$rtcsdk[bool ? "on" : "off"]("getUserAttrsFail", this.getUserAttrsFail);
                this.$rtcsdk[bool ? "on" : "off"]("notifyUserAttrsChanged", this.notifyUserAttrsChanged);
                this.$rtcsdk[bool ? "on" : "off"]("addOrUpdateUserAttrsRslt", this.addOrUpdateAttrsRslt);
                this.$rtcsdk[bool ? "on" : "off"]("delUserAttrsRslt", this.delAttrsRslt);
            } else {
                this.$rtcsdk[bool ? "on" : "off"]("getMeetingAllAttrsSuccess", this.getMeetingAllAttrsSuccess);
                this.$rtcsdk[bool ? "on" : "off"]("getMeetingAllAttrsFail", this.getMeetingAllAttrsFail);
                this.$rtcsdk[bool ? "on" : "off"]("notifyMeetingAttrsChanged", this.notifyMeetingAttrsChanged);
                this.$rtcsdk[bool ? "on" : "off"]("addOrUpdateMeetingAttrsRslt", this.addOrUpdateAttrsRslt);
                this.$rtcsdk[bool ? "on" : "off"]("delMeetingAttrsRslt", this.delAttrsRslt);
                this.$rtcsdk[bool ? "on" : "off"]("clearMeetingAttrsRslt", this.clearMeetingAttrsRslt);
            }
        },
        getUserAttrsSuccess(attrs, cookie) {
            console.log("getUserAttrsSuccess", attrs);
            this.tableData = JSON.parse(attrs)[this.userId];
        },
        getUserAttrsFail(sdkErr) {
            ElMessage.error(`获取用户属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
        },
        notifyUserAttrsChanged(uid, adds, updates, delKeys) {
            console.log("notifyUserAttrsChanged", uid, adds, updates, delKeys);
            if (uid !== this.userId) return;

            const addObj = JSON.parse(adds);
            const updateObj = JSON.parse(updates);
            const delArr = JSON.parse(delKeys);

            const newObj = Object.assign(addObj, updateObj);

            if (Object.keys(newObj).length) {
                this.tableData = Object.assign(this.tableData, newObj);
            }

            if (delArr.length) {
                delArr.forEach((item) => {
                    delete this.tableData[item];
                });
            }
        },
        getMeetingAllAttrsSuccess(json) {
            this.tableData = JSON.parse(json);
        },
        getMeetingAllAttrsFail(sdkErr) {
            ElMessage.error(`获取房间属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
        },
        delAttrsRslt(sdkErr) {
            if (sdkErr != 0) {
                ElMessage.error(`删除属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        clearMeetingAttrsRslt(sdkErr) {
            if (sdkErr != 0) {
                ElMessage.error(`清空房间属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        addOrUpdateAttrsRslt(sdkErr) {
            if (sdkErr != 0) {
                ElMessage.error(`添加属性失败，错误码: ${sdkErr},${errDesc[sdkErr]}`);
            }
        },
        notifyMeetingAttrsChanged(adds, updates, delKeys) {
            const addObj = JSON.parse(adds);
            const updateObj = JSON.parse(updates);
            const delArr = JSON.parse(delKeys);

            const newObj = Object.assign(addObj, updateObj);

            if (Object.keys(newObj).length) {
                this.tableData = Object.assign(this.tableData, newObj);
            }

            if (delArr.length) {
                delArr.forEach((item) => {
                    delete this.tableData[item];
                });
            }
        },
        currentChange(currentRow) {
            this.selectRow = currentRow;
        },
        delAttr() {
            if (this.userId) {
                this.$rtcsdk.delUserAttrs(this.userId, JSON.stringify([this.selectRow.key]), JSON.stringify({ notifyAll: 1 }));
            } else {
                this.$rtcsdk.delMeetingAttrs(JSON.stringify([this.selectRow.key]), JSON.stringify({ notifyAll: 1 }));
            }
        },
        clearAll() {
            if (this.userId) {
                this.$rtcsdk.clearUserAttrs(this.userId, JSON.stringify({ notifyAll: 1 }));
            } else {
                this.$rtcsdk.clearMeetingAttrs(JSON.stringify({ notifyAll: 1 }));
            }
        },
        add() {
            this.dialogIsEdit = false;
            this.form.key = "";
            this.form.value = "";
            this.dialogVisible = true;
        },
        edit() {
            this.dialogIsEdit = true;
            this.form.key = this.selectRow.key;
            this.form.value = this.selectRow.value;
            this.dialogVisible = true;
        },
        onSubmit() {
            const { key, value } = this.form;
            if (this.userId) {
                this.$rtcsdk.addOrUpdateUserAttrs(
                    this.userId,
                    JSON.stringify({
                        [key]: value,
                    }),
                    JSON.stringify({ notifyAll: 1 })
                );
            } else {
                this.$rtcsdk.addOrUpdateMeetingAttrs(
                    JSON.stringify({
                        [key]: value,
                    }),
                    JSON.stringify({ notifyAll: 1 })
                );
            }
            this.dialogVisible = false;
        },
    },
};
</script>

<style lang="scss" scoped>
.btn-group {
    text-align: center;
    margin-top: 20px;

    button {
        width: 100px;
    }
}

.edit-btn-group {
    margin-bottom: 0;

    :deep .el-form-item__content {
        justify-content: right;
    }
}
</style>
