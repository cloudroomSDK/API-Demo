<template>
	<page-meta>
		<navigation-bar :title="nbTitle" />
	</page-meta>
	<view class="page">
		<view class="video" v-if="renderVideo">
			<!-- 组件宽高会根据父元素宽高继承 -->
			<!-- 音视频推流组件 config传入配置信息，debug是否开启调式，详细请参考组件文档 -->
			<rtc-video-pusher :config="{
			  beauty: isBeautify ? 5 : 0,
			  whiteness: isBeautify ? 5 : 0,
			  localMirror: localMirror,
			  remoteMirror: remoteMirror,
			  beautyStyle: beautyStyle,
			  filter: filter,
			  minBitrate: minBitrate,
			  maxBitrate: maxBitrate
			}" />

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
		<rtc-audio-player />
		<scroll-view class="ctrl" scroll-y="true">
			<view class="section">
				<text>前置摄像头</text>
				<switch class="switch" color="#39abfb" checked @change="toggleCam" />
			</view>
			<view class="section">
				<text>美颜</text>
				<switch class="switch" color="#39abfb" :checked="isBeautify" @change="isBeautify = !isBeautify" />
			</view>
			<view class="section radio">
				<view class="key">美颜类型(打开美颜才生效)</view>
				<view class="value">
					<radio-group class="radio-group" @change="beautyStyle = $event.detail.value">
						<radio color="#39abfb" v-for="item in beautyStyleList" :key="item.name" :value="item.name" :checked="item.checked" class="radio">
							<text>{{ item.value }}</text>
						</radio>
					</radio-group>
				</view>
			</view>
			<view class="section">
				<view class="key">滤镜</view>
				<view class="value">
					<radio-group class="radio-group" @change="filter = $event.detail.value">
						<radio color="#39abfb" v-for="item in filterList" :key="item.name" :value="item.name" :checked="item.checked" class="radio">
							<text>{{ item.value }}</text>
						</radio>
					</radio-group>
				</view>
			</view>
			<view class="section">
				<view class="key">最小码率</view>
				<view class="value">
					<slider activeColor="#39abfb" @change="minBitrate = $event.detail.value" min="100" :max="maxBitrate" :value="minBitrate" step="100" show-value />
				</view>
			</view>
			<view class="section">
				<view class="key">最大码率</view>
				<view class="value">
					<slider activeColor="#39abfb" @change="maxBitrate = $event.detail.value" :min="minBitrate" max="1500" step="100" :value="maxBitrate" show-value />
				</view>
			</view>
			<view class="section">
				<text>远端显示镜像</text>
				<switch class="switch" color="#39abfb" @change="remoteMirror = $event.detail.value" />
			</view>
			<view class="section">
				<view>
					<text>本地镜像</text>
					<radio-group @change="localMirror = $event.detail.value">
						<label class="" v-for="item in localMirrorList" :key="item.value">
							<view class="">
								<radio color="#39abfb" :value="item.value" :checked="item.checked" />
								<text class="">{{ item.name }}</text>
							</view>
						</label>
					</radio-group>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script>
	import RTCSDK from "./CRSDK";
	import { getUserInfo } from "../store.js";
	export default {
		data() {
			return {
				nbTitle: "视频设置",
				myUserID: "",
				memberList: [],
				renderVideo: true,
				minBitrate: 200,
				maxBitrate: 800,
				isBeautify: false,
				remoteMirror: false,
				localMirror: "auto",
				beautyStyle: "smooth",
				filter: "standard",
				localMirrorList: [{
						value: "auto",
						name: "前置摄像头镜像，后置摄像头不镜像",
						checked: "true",
					},
					{
						value: "enable",
						name: "前后置摄像头均镜像",
					},
					{
						value: "disable",
						name: "前后置摄像头均不镜像",
					},
				],
				beautyStyleList: [{
						name: "smooth",
						value: "光滑美颜",
						checked: true,
					},
					{
						name: "nature",
						value: "自然美颜",
					},
				],
				filterList: [{
						name: "standard",
						value: "标准",
						checked: true,
					},
					{
						name: "pink",
						value: "粉嫩",
					},
					{
						name: "nostalgia",
						value: "怀旧",
					},
					{
						name: "blues",
						value: "蓝调",
					},
					{
						name: "romantic",
						value: "浪漫",
					},
					{
						name: "cool",
						value: "清凉",
					},
					{
						name: "fresher",
						value: "清新",
					},
					{
						name: "solor",
						value: "日系",
					},
					{
						name: "aestheticism",
						value: "唯美",
					},
					{
						name: "whitening",
						value: "美白",
					},
					{
						name: "cerisered",
						value: "樱红",
					},
				],
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
			toggleCam(e) {
				RTCSDK.SetDefaultVideo(this.myUserID);
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
			padding: 20rpx 30rpx;
			box-sizing: border-box;
			height: 500rpx;
			color: #fff;

			.section {
				margin-bottom: 40rpx;

				.switch {
					float: right;
					transform: scale(0.8);
				}

				.radio {
					margin-right: 20rpx;
				}
			}
		}
	}
</style>