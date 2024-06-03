<template>
	<view class="setting">
		<form class="form" @submit="formSubmit">
			<view class="uni-form-item input-item">
				<view class="title">服务器：</view>
				<input name="server" v-model="server" class="uni-input" />
			</view>
			<view v-if="useToken" class="uni-form-item">
				<view class="title">令牌：</view>
				<view class="uni-textarea">
					<textarea :maxlength="-1" class="textarea" name="token" v-model="token" />
				</view>
			</view>
			<template v-else>
				<view class="uni-form-item input-item">
					<view class="title">App ID：</view>
					<input name="appId" v-model="appId" class="uni-input" />
				</view>
				<view class="uni-form-item input-item">
					<view class="title">App Secret：</view>
					<input name="appSecret" password v-model="appSecret" class="uni-input" />
				</view>
			</template>
			<view class="uni-form-item input-item">
				<view class="title">第三方鉴权：</view>
				<input name="auth" v-model="auth" class="uni-input" placeholder="非必填" />
			</view>
			<view class="uni-form-item">
				<view class="title">
					动态令牌鉴权：
					<switch color="#3980fc" name="useToken" :checked="useToken" @change="model($event, 'useToken')" />
				</view>
			</view>
			<view class="uni-btn">
				<button class="btn primary" form-type="submit">保存</button>
				<button class="btn primary" plain @click="formReset">恢复默认</button>
			</view>
		</form>
	</view>
</template>

<script>
	import { getConfig, changeConfig, resetConfig } from "../store.js";
	export default {
		data() {
			return {
				server: "",
				token: "",
				appId: "",
				appSecret: "",
				auth: "",
				useToken: true,
			};
		},
		onLoad() {
			const config = getConfig();
			this.server = config.server;
			this.useToken = config.useToken;
			this.appId = config.appId;
			this.appSecret = config.appSecret;
			this.token = config.token;
			this.auth = config.auth || "";
		},
		methods: {
			model(event, key) {
				this[key] = event.detail.value;
			},
			formSubmit: function(e) {
				console.log(
					"form发生了submit事件，携带数据为：" + JSON.stringify(e.detail.value)
				);
				const { value } = e.detail;
				changeConfig(value);
			},
			formReset() {
				const config = resetConfig();
				this.server = config.server;
				this.useToken = config.useToken;
				this.token = config.token;
				this.appId = config.appId;
				this.appSecret = config.appSecret;
				this.auth = "";
			},
		},
	};
</script>

<style lang="scss" scoped>
	.setting {
		padding: 60rpx 30rpx 0;

		.form {
			.uni-form-item {
				margin-bottom: 20rpx;
				font-size: 26rpx;

				.textarea {
					border: 1rpx solid $uni-border-color;
					border-radius: 10rpx;
					width: 100%;
					padding: 4rpx 10rpx;
					box-sizing: border-box;
				}

				&.input-item {
					display: flex;
					align-items: center;
					height: 100rpx;
					padding: 0 25rpx;
					border-radius: 50rpx;
					border: 1rpx solid $uni-border-color;

					.title {
						color: #aeaeae;
						width: 200rpx;
						text-align-last: justify;
					}

					.uni-input {
						flex: 1;
					}
				}
			}

			.uni-btn {
				.btn {
					margin-bottom: 30rpx;
				}
			}
		}
	}
</style>