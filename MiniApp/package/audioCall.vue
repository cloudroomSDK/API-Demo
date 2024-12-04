<template>
	<page-meta>
		<navigation-bar :title="nbTitle" />
	</page-meta>
	<view class="page">
		<view class="audioValue">
			<view class="item">
				<view class="name">本地用户</view>
				<progress :percent="myAudioValue" border-radius="2" stroke-width="5" backgroundColor="#373F50" activeColor="#09DB00" />
			</view>
			<view class="item">
				<view class="name">{{otherUserID}}</view>
				<progress :percent="otherAudioValue*10" border-radius="2" stroke-width="5" backgroundColor="#373F50" activeColor="#09DB00" />
			</view>
		</view>
		<view class="video" v-if="renderVideo">
			<!-- 当不需要显示视频时，也需要渲染该组件，因为调用麦克风需要使用该组件 -->
			<rtc-video-pusher :config='{
				enableCamera: false,
			}' @audiovolumenotify='myAudioValue=$event.detail.detail.volume' />
		</view>
		<!-- 音频拉流组件 -->
		<rtc-audio-player :config="{ soundMode: isSpeaker ? 'speaker' : 'ear' }" />
		<view class="ctrl">
			<button class="btn primary" @click="toggleMic">
				{{ openMicStatus ? "关闭" : "打开" }}麦克风
			</button>
			<button class="btn primary" @click="isSpeaker = !isSpeaker">
				切换为{{ isSpeaker ? "听筒" : "扬声器" }}
			</button>
		</view>
	</view>
</template>

<script>
	import RTCSDK from "./CRSDK";
	import { getUserInfo } from "../store.js";
	export default {
		data() {
			return {
				nbTitle: "语音通话",
				myUserID: "",
				memberList: [],
				renderVideo: true,
				openMicStatus: false,
				isSpeaker: true, //扬声器
				myAudioValue: 0,
				otherUserID: '远端用户',
				otherAudioValue: 0,
			};
		},
		onLoad(option) {
			this.nbTitle = `房间号：${option.roomId}`;
			const { userID, nickname } = getUserInfo();
			this.myUserID = userID;
		},
		onUnload() {
			RTCSDK.ExitMeeting();
		},
		methods: {
			callback_AudioStatusChanged(UID, oldStatus, newStatus) {
				if (this.myUserID === UID) {
					this.openMicStatus = newStatus === 3;
				}
			},
			callback_EnterMeetingRslt(sdkErr) {
				if (sdkErr === 0) {
					this.renderVideo = false;
					this.$nextTick(() => {
						this.renderVideo = true;
					});
				}
			},
			callback_MicEnergyUpdate(UID, oldLevel, newLevel) {
				if (this.myUserID === UID) return;
				this.otherUserID = UID;
				this.otherAudioValue = newLevel;
			},
			toggleMic() {
				this.openMicStatus ?
					RTCSDK.CloseMic(this.myUserID) :
					RTCSDK.OpenMic(this.myUserID);
				this.openMicStatus = !this.openMicStatus;
			},
		},
	};
</script>

<style lang="scss" scoped>
	.page {
		background-color: #1d232f;

		.audioValue {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			width: 410rpx;
			padding: 40rpx;
			color: #fff;
			font-size: 24rpx;
			background-color: #000;
			border-radius: 10rpx;

			.item {
				margin-bottom: 30rpx;

				.name {
					margin-bottom: 12rpx;
				}
			}
		}

		.video {
			width: 0;
			height: 0;
		}

		.ctrl {
			position: absolute;
			bottom: 0;
			width: 100%;
			background-color: rgba(0, 0, 0, 0.7);
			padding: 50rpx 0 20rpx;
			display: flex;
			flex-wrap: wrap;

			.btn {
				width: 310rpx;
				height: 80rpx;
				line-height: 80rpx;
				font-size: 28rpx;
				margin-bottom: 30rpx;
			}
		}
	}
</style>