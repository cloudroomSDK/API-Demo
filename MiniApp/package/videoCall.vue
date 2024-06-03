<template>
	<page-meta>
		<navigation-bar :title="nbTitle" />
	</page-meta>
	<view class="page">
		<view class="video" v-if="renderVideo">
			<!-- 组件宽高会根据父元素宽高继承 -->
			<!-- 音视频推流组件 config传入配置信息，debug是否开启调式，详细请参考组件文档 -->
			<rtc-video-pusher />

			<view class="otherVideo">
				<view class="video-item" v-for="item in memberList" :key="item.userID">
					<rtc-video-player :config="{
					  userId: item.userID,
					}">
						<view class="solt">
							<view class="nickname">{{ item.nickname }}</view>
							<view class="placeholder" v-if="item.videoStatus !== 3">
								<view class="text">摄像头<br>未开启</view>
							</view>
						</view>
					</rtc-video-player>
				</view>
			</view>
		</view>
		<!-- 音频拉流组件 -->
		<rtc-audio-player :config="{ soundMode: isSpeaker ? 'speaker' : 'ear' }" />
		<view class="ctrl">
			<button class="btn primary" @click="toggleDevices">
				{{ isFrontCam ? "后置" : "前置" }}摄像头
			</button>
			<button class="btn primary" @click="toggleCam">
				{{ openCamStatus ? "关闭" : "开启" }}摄像头
			</button>
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
				nbTitle: "视频通话",
				myUserID: "",
				memberList: [],
				renderVideo: true,
				openCamStatus: false,
				openMicStatus: false,
				isFrontCam: true, //前置摄像头
				isSpeaker: true, //扬声器
			};
		},
		onLoad(option) {
			this.nbTitle = `房间号：${option.roomId}`;
			const { userID, nickname } = getUserInfo();
			this.myUserID = userID;
			this.memberList = RTCSDK.GetAllMembers().filter(
				(member) => member.userID !== userID
			);
		},
		onUnload() {
			RTCSDK.ExitMeeting();
		},
		methods: {
			callback_UserEnterMeeting(UID) {
				const userInfo = RTCSDK.GetMemberInfo(UID);
				this.memberList.push(userInfo);
			},
			callback_UserLeftMeeting(UID) {
				const idx = this.memberList.findIndex((item) => item.userID === UID);
				if (idx > -1) {
					this.memberList.splice(idx, 1);
				}
			},
			callback_VideoStatusChanged(UID, oldStatus, newStatus) {
				if (this.myUserID === UID) {
					this.openCamStatus = newStatus === 3;
				} else {
					const idx = this.memberList.findIndex((item) => item.userID === UID);
					if (idx > -1) {
						this.memberList[idx].videoStatus = newStatus;
					}
				}
			},
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
			toggleDevices() {
				RTCSDK.SetDefaultVideo(this.myUserID);
				this.isFrontCam = !this.isFrontCam;
			},
			toggleCam() {
				this.openCamStatus ?
					RTCSDK.CloseVideo(this.myUserID) :
					RTCSDK.OpenVideo(this.myUserID);
				this.openCamStatus = !this.openCamStatus;
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

		.video {
			width: 100%;
			height: 100%;
			position: relative;

			.otherVideo {
				width: 100%;
				height: 100%;
				max-height: 1050rpx;
				padding: 10rpx;
				position: absolute;
				box-sizing: border-box;
				top: 0;
				left: 0;
				display: flex;
				flex-direction: column;
				flex-wrap: wrap-reverse;
				justify-content: flex-start;
				align-content: space-between;

				.video-item {
					width: 180rpx;
					height: 320rpx;
					margin-bottom: 20rpx;
					border-radius: 10rpx;
					overflow: hidden;
					position: relative;

					.solt {
						position: absolute;
						width: 100%;
						height: 100%;
						z-index: 2;
						color: #fff;
						line-height: 20rpx;
						font-size: 20rpx;

						.nickname {
							position: absolute;
							z-index: 4;
							padding: 6rpx;
							background-color: rgba(0, 0, 0, 0.3);
							top: 6rpx;
							right: 6rpx;
							border-radius: 4rpx;
						}

						.placeholder {
							background-color: #000;
							position: absolute;
							width: 100%;
							height: 100%;
							z-index: 3;

							.text {
								position: absolute;
								top: 50%;
								left: 50%;
								transform: translate(-50%, -50%);
								border-radius: 4rpx;
								padding: 6rpx;
								line-height: 30rpx;
								background-color: rgba(0, 0, 0, 0.3);
							}
						}
					}
				}
			}
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