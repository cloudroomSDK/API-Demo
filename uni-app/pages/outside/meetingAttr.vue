<template>
	<view>
		<view class="title">
			<text class="text" v-if="userId">{{userId}}的成员属性</text>
			<text class="text" v-else>房间属性</text>
		</view>
		<view class="list">
			<list v-if="Object.keys(attrObj).length">
				<cell v-for="(item, key) in attrObj" :key="key">
					<view class="item">
						<view class="l">
							<text class='text'>key：{{key}}</text>
							<text class='text'>value：{{item.value}}</text>
							<text class='text'>修改者：{{item.lastModifyUserID}}</text>
							<text class='text'>修改时间：{{item.lastModifyTs | formatTime}}</text>
						</view>
						<view class="r">
							<button class="btn primary" @click="edit(key)">
								<text class="btn-text">修改</text>
							</button>
							<button class="btn danger" @click="del(key)">
								<text class="btn-text">删除</text>
							</button>
						</view>
					</view>
				</cell>
			</list>
			<text class="text" v-else>暂无属性</text>
		</view>

		<view class="btn-group">
			<button class="btn primary" @click="add">
				<text class="btn-text">新增</text>
			</button>
			<button class="btn danger" @click="clear">
				<text class="btn-text">清除列表</text>
			</button>

			<button class="btn primary" @click="close">
				<text class="btn-text">关闭</text>
			</button>
		</view>
	</view>

</template>

<script>
	import { formatTime } from '@/util'
	export default {
		props: ["userId"],
		data() {
			return {
				attrObj: null,
			}
		},
		created() {
			this.RTCSDK = getApp().globalData.RTCSDK.getInstance();
			this.handleEvents(true)
			if (this.userId) {
				this.RTCSDK.getUserAttrs([this.userId])
			} else {
				this.RTCSDK.getMeetingAllAttrs()
			}
		},
		destroyed() {
			this.handleEvents(false)
		},
		filters: {
			formatTime,
		},
		methods: {
			handleEvents(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("getMeetingAllAttrsSuccess", this._getMeetingAllAttrsSuccess);
				handle("notifyMeetingAttrsChanged", this._notifyMeetingAttrsChanged);
				handle("getUserAttrsSuccess", this._getUserAttrsSuccess);
				handle("notifyUserAttrsChanged", this._notifyUserAttrsChanged);
			},
			close() {
				this.$emit('close')
			},
			add() {
				uni.showModal({
					title: '添加属性',
					placeholderText: '请输入key',
					editable: true,
					success: (res) => {
						const key = res.content.trim();
						if (res.confirm && key) {
							uni.showModal({
								title: '添加属性',
								content: `请输入${key}的value`,
								placeholderText: '请输入value',
								editable: true,
								success: (res) => {
									const value = res.content.trim();
									if (res.confirm && value) {
										if (this.userId) {
											this.RTCSDK.addOrUpdateUserAttrs(this.userId, {
												[key]: value,
											}, {
												notifyAll: 1,
											})
										} else {
											this.RTCSDK.addOrUpdateMeetingAttrs({
												[key]: value,
											}, {
												notifyAll: 1,
											})
										}
									}
								}
							})
						}
					}
				})
			},
			del(key) {
				uni.showModal({
					title: '删除',
					content: `确定要删除"${key}"?`,
					success: (res) => {
						if (res.confirm) {
							if (this.userId) {
								this.RTCSDK.delUserAttrs(this.userId, [key], {
									notifyAll: 1,
								});
							} else {
								this.RTCSDK.delMeetingAttrs([key], {
									notifyAll: 1,
								});
							}
						}
					}
				})
			},
			clear() {
				uni.showModal({
					title: '清空列表',
					content: '确定要清空所有属性？',
					success: (res) => {
						if (res.confirm) {
							if (this.userId) {
								this.RTCSDK.clearUserAttrs(this.userId, {
									notifyAll: 1,
								});
							} else {
								this.RTCSDK.clearMeetingAttrs({
									notifyAll: 1,
								});
							}
						}
					}
				})
			},
			edit(key) {
				uni.showModal({
					title: '修改属性',
					content: `修改${key}的value`,
					placeholderText: '请输入新的value',
					editable: true,
					success: (res) => {
						const value = res.content.trim();
						if (res.confirm && value) {
							if (this.userId) {
								this.RTCSDK.addOrUpdateUserAttrs(this.userId, {
									[key]: value,
								}, {
									notifyAll: 1,
								})
							} else {
								this.RTCSDK.addOrUpdateMeetingAttrs({
									[key]: value,
								}, {
									notifyAll: 1,
								})
							}
						}
					}
				})
			},
			_getMeetingAllAttrsSuccess({ attrSeq }) {
				this.attrObj = attrSeq;
			},
			_notifyMeetingAttrsChanged({ add, updates, delKeys }) {
				const newObj = { ...add, ...updates };
				Object.keys(newObj).forEach(item => {
					this.$set(this.attrObj, item, newObj[item])
				})

				if (delKeys.length) {
					delKeys.forEach((item) => {
						this.attrObj[item] && this.$delete(this.attrObj, item)
					});
				}
			},
			_getUserAttrsSuccess({ attrMap }) {
				console.log(attrMap)
				this.attrObj = attrMap[this.userId];
			},
			_notifyUserAttrsChanged({ userID, add, updates, delKeys }) {
				if (userID !== this.userId) return;
				const newObj = { ...add, ...updates };
				Object.keys(newObj).forEach(item => {
					this.$set(this.attrObj, item, newObj[item])
				})

				if (delKeys.length) {
					delKeys.forEach((item) => {
						this.attrObj[item] && this.$delete(this.attrObj, item)
					});
				}
			},
		}
	}
</script>

<style lang="scss" scoped>
	.title {
		border-bottom: 1px solid #ccc;
		padding: 20rpx;

		.text {
			font-size: 40rpx;
		}
	}

	.list {
		flex: 1;
		justify-content: center;
		align-items: center;

		.item {
			width: 600rpx;
			padding: 20rpx;
			border-bottom: 1rpx solid #ccc;
			flex-direction: row;

			.l {
				flex: 1;
				justify-content: space-around;

				.text {
					flex: 1;
					font-size: 28rpx;
					color: #333;
				}
			}

			.r {
				margin-left: 10rpx;

				.btn {
					height: 50rpx !important;
					padding: 30rpx;
					margin: 10rpx 0;
				}
			}
		}
	}

	.btn-group {
		flex-direction: row;
		justify-content: space-around;
		margin: 20rpx 0;

		.btn {
			height: 50rpx !important;
			padding: 30rpx;
		}
	}
</style>