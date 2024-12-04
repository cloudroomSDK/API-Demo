<template>
	<view class="page">
		<view class="box">
			<view class="title">请输入房间号：</view>
			<input class="input" type="number" :value="roomId" @input="roomInput" placeholder="roomId" />
			<button class="btn primary" @click="joinMeeting" :disabled="!canEnter">进入房间</button>
			<view class="jg">
				<view class="line"></view>
				<text>或者</text>
				<view class="line"></view>
			</view>
			<button class="btn primary" @click="createMeeting" plain :disabled="!canCreate">创建房间</button>
		</view>
		<div class="version">
			<view>Demo: v1.0.3</view>
			<view>SDK: v{{sdkVersion}}</view>
		</div>
	</view>
</template>

<script>
	import RTCSDK from './CRSDK';
	import { getConfig, getUserInfo, getLastRoomId, setLastRoomId } from "../store.js"
	import './sdkCallback.js'
	import { getDesc } from './sdkErrDesc.js'
	export default {
		data() {
			return {
				sdkVersion: '',
				roomId: '',
				sdkStatus: 0, //SDK状态，0未初始化，1初始化成功，2，初始化失败
				loginStatus: 0, //SDK登录状态，0未登录，1，登录中，2登录成功，3登录失败
			}
		},
		computed: {
			canCreate() {
				return this.sdkStatus === 1 && this.loginStatus === 2;
			},
			canEnter() {
				return this.canCreate && /^\d{8}$/.test(this.roomId);
			}
		},
		onLoad(option) {
			console.log(option.type);
			this.roomId = getLastRoomId();
			this.sdkVersion = RTCSDK.sdkver;
			const sdkErr = RTCSDK.Init({ //初始化SDK,返回状态码
				isCallSer: false
			});
			this.sdkStatus = sdkErr === 0 ? 1 : 2;
			if (sdkErr !== 0) {
				this.sdkStatus = 2;
				console.log(`初始化失败,错误码：${sdkErr}}`);
				return;
			}
			this.sdkStatus = 1;
			this.login();
		},
		onUnload() {
			RTCSDK.UnInit()
		},
		methods: {
			callback_LoginSuccess(UID, cookie) {
				this.loginStatus = 2;
			},
			callback_LoginFail(sdkErr, cookie) {
				const desc = `登录失败,错误码:${sdkErr},${getDesc(sdkErr)}`;
				this.loginStatus = 3;
				console.log(desc);
				if ([7, 17, 18, 19, 20, 21, 22].indexOf(sdkErr) > -1) {
					uni.showModal({
						title: '登录失败',
						content: desc,
						showCancel: false,
						success(res) {
							uni.redirectTo({
								url: '/pages/setting'
							})
						}
					});
					return;
				}

				uni.showToast({
					title: desc,
					icon: 'none',
					duration: 3000
				});
				setTimeout(this.login, 10e3);
			},
			callback_CreateMeetingSuccess({ ID: roomId }, cookie) {
				this.roomId = roomId;

				this.joinMeeting();
			},
			callback_CreateMeetingFail(sdkErr, cookie) {
				uni.hideLoading()
				const desc = `创建房间失败,错误码:${sdkErr},${getDesc(sdkErr)}`;
				uni.showToast({
					title: desc,
					icon: 'none',
					duration: 2000
				});
			},
			callback_EnterMeetingRslt(sdkErr, cookie) {
				if (sdkErr !== 0) {
					const desc = `进入房间失败,错误码:${sdkErr},${getDesc(sdkErr)}`;
					uni.showToast({
						title: desc,
						icon: 'none',
						duration: 2000
					});
					return;
				}
				setLastRoomId(this.roomId)

				uni.navigateTo({ url: `./${this.$scope.options.type}?roomId=${this.roomId}` });
			},
			login() {
				const config = getConfig();
				RTCSDK.SetServerAddr(config.server); //设置服务器地址
				const { nickname, userID } = getUserInfo();
				if (config.useToken) {
					RTCSDK.LoginByToken(config.token, nickname, userID, config.auth)
				} else {
					RTCSDK.Login(config.appId, RTCSDK.MD5(config.appSecret), nickname, userID, config.auth)
				}
				this.loginStatus = 1;
			},
			joinMeeting() {
				uni.showLoading({
					mask: true,
					title: '进入房间'
				})
				const { nickname, userID } = getUserInfo();
				RTCSDK.EnterMeeting3(this.roomId);
			},
			createMeeting() {
				uni.showLoading({
					mask: true,
					title: '创建房间'
				})
				RTCSDK.CreateMeeting()
			},
			roomInput(event) {
				const { value } = event.target;
				this.roomId = value;
				const flag = /^\d{8}$/.test(value); //检验房间号格式
				if (flag) {
					uni.hideKeyboard(); //收起键盘
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		background-color: $uni-bg-color-grey;
		height: 100vh;
		padding-top: 22rpx;
		position: relative;

		.box {
			background-color: #fff;
			padding: 56rpx 80rpx 56rpx;

			.title {
				color: #666;
				font-size: 28rpx;
				margin-bottom: 24rpx;
			}

			.input {
				border: 1rpx solid #D2D2D2;
				padding: 10rpx;
				margin-bottom: 46rpx;
				border-radius: 2rpx;
			}

			.jg {
				display: flex;
				color: #888;
				align-items: center;
				justify-content: space-between;
				font-size: 24rpx;
				margin: 42rpx 0;

				.line {
					width: 250rpx;
					height: 1rpx;
					background-color: #D0D0D0;
				}
			}
		}

		.version {
			position: absolute;
			bottom: 100rpx;
			width: 100%;
			text-align: center;
			color: #999;
		}
	}
</style>