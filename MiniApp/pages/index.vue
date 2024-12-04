<template>
	<view class="content">
		<view class="desc">所有功能
			<image class="setting" src="/static/setting.svg" @click="gotoSetting"></image>
		</view>
		<view class="card">
			<view class="item">
				<button class="btn primary" @click="gotoJoin('audioCall')">语音通话</button>
			</view>
			<view class="item">
				<button class="btn primary" @click="gotoJoin('videoCall')">视频通话</button>
			</view>
			<view class="item">
				<button class="btn primary" @click="gotoJoin('videoSetting')">视频设置</button>
			</view>
			<view class="item">
				<button class="btn primary" @click="gotoJoin('cloudMixer')">云端录制</button>
			</view>
			<view class="item">
				<button class="btn primary" @click="gotoJoin('chat')">聊天</button>
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {

			}
		},
		onLoad() {

		},
		methods: {
			gotoSetting() {
				uni.navigateTo({
					url: '/pages/setting'
				});
			},
			gotoJoin(type) {
				uni.navigateTo({
					url: `/package/join?type=${type}`
				});
			}
		}
	}
</script>

<style scoped lang="scss">
	.content {
		.desc {
			background-color: $uni-bg-color-grey;
			line-height: 70rpx;
			color: #666;
			font-size: 28rpx;
			padding-left: 34rpx;
			position: relative;

			.setting {
				position: absolute;
				top: 50%;
				right: 10px;
				transform: translateY(-50%);
				width: 40rpx;
				height: 40rpx;
			}
		}

		.card {
			background-color: #fff;
			padding: 50rpx 72rpx;

			.item {
				margin-bottom: 20rpx;

				.btn {
					font-size: 28rpx;
					height: 90rpx;
					line-height: 90rpx;
				}
			}
		}
	}
</style>