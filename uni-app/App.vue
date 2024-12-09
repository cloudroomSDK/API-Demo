<script>
	import { defaultLoginInfo } from './config';
	import RTCSDK from './RTCSDK/index.js'
	export default {
		globalData: {
			RTCSDK: RTCSDK,
			popupConfig: null, //全局弹窗配置
		},
		onLaunch: function() {
			console.log('App Launch')
			//热更新不会退出原生层，反初始化使原生层重置
			this.globalData.RTCSDK.getInstance().uninit();
			this.globalData.version = plus.runtime.version;
			//读取登录服务器、账号、密码
			try {
				const value = uni.getStorageSync('loginInfo');
				if (value) {
					this.globalData.loginInfo = value;
				} else {
					throw '';
				}
			} catch (e) {
				this.globalData.loginInfo = defaultLoginInfo;
			}

			//生成userId和nickname
			try {
				const value = uni.getStorageSync('userInfo');
				if (value) {
					const obj = JSON.parse(value);
					this.globalData.userInfo = obj;
				} else {
					throw '';
				}
			} catch (e) {
				const userId = `Uniapp_${parseInt(Math.random() * 9000) + 1000}`;
				const userInfo = {
					userId: userId,
					nickname: userId,
				}
				this.globalData.userInfo = userInfo;
				uni.setStorageSync('userInfo', JSON.stringify(userInfo));
			}
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		}
	}
</script>

<style lang="scss">
	.btn {
		border-radius: 4rpx;
		text-align: center;

		.btn-text {
			height: 80rpx;
			line-height: 80rpx;
			font-size: 32rpx;
		}

		&.plain {
			background: rgba(0, 0, 0, 0);
			height: 88rpx;
			line-height: 88rpx;
			border: 1px solid $uni-bg-color;

			.btn-text {
				color: $uni-bg-color;
			}
		}

		&.primary {
			border: 0;
			height: 90rpx;
			line-height: 90rpx;
			background-color: $uni-text-color;

			.btn-text {
				height: 80rpx;
				line-height: 80rpx;
				font-size: 32rpx;
				color: $uni-text-color-primary;
			}

			&.disabled {
				background-color: #aaa;
			}

			&.plain {
				height: 88rpx;
				background: rgba(0, 0, 0, 0);
				border: 1px solid $uni-text-color;

				.btn-text {
					color: $uni-text-color;
				}
			}
		}

		&.danger {
			background-color: #ff6969;
			border: 0;
			height: 90rpx;
			line-height: 90rpx;
			text-align: center;
			border-radius: 4rpx;

			.btn-text {
				height: 80rpx;
				line-height: 80rpx;
				font-size: 32rpx;
				color: $uni-text-color-primary;
			}

			&.plain {
				height: 88rpx;
				background: #FFFFFF;
				border: 1px solid $uni-text-color;

				.btn-text {
					color: $uni-text-color;
				}
			}
		}
	}
</style>