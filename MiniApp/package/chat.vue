<template>
	<page-meta>
		<navigation-bar :title="nbTitle" />
	</page-meta>
	<view class="page">
		<scroll-view class="chatList" scroll-y="true" :scroll-top="scrollTop" @scroll="oldScrollTop = $event.detail.scrollTop">
			<view class="chat" :class="myUserID === item.userID?'isMe':''" v-for="(item,idx) in chatList" :key="idx">
				<view class="header">
					<text class="time">{{item.time}}</text>
					<text class="name" v-if="myUserID !== item.userID">{{item.userID}}</text>
				</view>
				<view class="message">{{item.message}}</view>
			</view>
		</scroll-view>
		<view class="ctrl">
			<input class='input' :value="input" @input="input = $event.target.value" />
			<button class="btn primary" :disabled="!this.input.trim()" @click="send">发送</button>
		</view>
	</view>
</template>

<script>
	import RTCSDK from "./CRSDK";
	import { getUserInfo } from "../store.js";
	import { parseTime } from "./utils"
	export default {
		data() {
			return {
				nbTitle: "聊天",
				myUserID: "",
				input: '',
				chatList: [],
				scrollTop: 0,
				oldScrollTop: 0
			};
		},
		onLoad(option) {
			this.nbTitle = `房间号：${option.roomId}`;
			const { userID } = getUserInfo();
			this.myUserID = userID;
		},
		onUnload() {
			RTCSDK.ExitMeeting();
		},
		methods: {
			callback_EnterMeetingRslt(sdkErr) {
				if (sdkErr === 0) {
					this.renderVideo = false;
					this.$nextTick(() => {
						this.renderVideo = true;
					});
				}
			},
			callback_NotifyMeetingCustomMsg(UID, jsonDat) {
				console.log(jsonDat)
				const { CmdType, IMMsg } = JSON.parse(jsonDat);
				if (CmdType !== "IM") return;
				this.chatList.push({
					userID: UID,
					message: IMMsg,
					time: parseTime(Date.now(), 'HH:mm')
				})

				// 解决view层不同步的问题
				this.scrollTop = this.oldScrollTop;
				this.$nextTick(() => {
					this.scrollTop = 99999999
				});
			},
			send() {
				const text = this.input.trim();
				RTCSDK.SendMeetingCustomMsg(JSON.stringify({
					CmdType: "IM",
					IMMsg: text
				}))
				this.input = '';
			},
		},
	};
</script>

<style lang="scss" scoped>
	.page {
		display: flex;
		flex-direction: column;

		.chatList {
			flex: 1;
			height: 100%;
			overflow: hidden;

			.chat {
				padding: 12rpx 46rpx;
				color: #333;
				font-size: 28rpx;

				&:last-of-type {
					padding-bottom: 60rpx;
				}

				&.isMe {
					text-align: right;
				}

				.header {
					margin-bottom: 10rpx;
					overflow: hidden;
					text-overflow: ellipsis;

					.time {
						color: #999;
						margin-right: 12rpx;
					}
				}

				.message {
					word-break: break-all;
				}
			}
		}

		.ctrl {
			height: 124rpx;
			background-color: #f0f0f0;
			padding: 22rpx 18rpx;
			display: flex;
			align-items: center;

			.input {
				flex: 1;
				background-color: #fff;
				height: 80rpx;
				border-radius: 10rpx;
				margin-right: 14rpx;
				padding: 0 10rpx;
			}

			.btn {
				width: 112rpx;
				height: 80rpx;
				line-height: 80rpx;
				font-size: 28rpx;
			}
		}
	}
</style>