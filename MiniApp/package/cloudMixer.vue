<template>
	<page-meta>
		<navigation-bar :title="nbTitle" />
	</page-meta>
	<view class="page">
		<view class="video" v-if="renderVideo">
			<!-- 组件宽高会根据父元素宽高继承 -->
			<!-- 音视频推流组件 config传入配置信息，debug是否开启调式，详细请参考组件文档 -->
			<!-- 这里传入9比16是为了保持与录制画布的比列一致 -->
			<rtc-video-pusher :config="{aspect:'9:16'}" />

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
		<view class="ctrl">
			<button class="btn primary" v-if="mixerStarting" loading disabled>启动中</button>
			<button class="btn danger" @click="end" v-else-if="mixerID">结束录制</button>
			<button class="btn primary" @click="start" v-else>云端录制</button>
		</view>
	</view>
</template>

<script>
	import RTCSDK from "./CRSDK";
	import { getUserInfo } from "../store.js";
	import { parseTime } from "./utils";
	export default {
		data() {
			return {
				nbTitle: "云端录制",
				myUserID: "",
				memberList: [],
				renderVideo: true,
				mixerID: null,
				lastMixerID: null,
				isSvrRecording: false,
			};
		},
		onLoad(option) {
			this.nbTitle = `房间号：${option.roomId}`;
			const { userID, nickname } = getUserInfo();
			this.myUserID = userID;
			this.memberList = RTCSDK.GetAllMembers().filter(
				(member) => member.userID !== userID
			);
			const mixerList = RTCSDK.GetAllCloudMixerInfo();
			mixerList.some(item => {
				if (item.owner === userID) {
					this.mixerID = item.ID;
					return true;
				}
			})
		},
		computed: {
			mixerStarting() {
				return !!(this.mixerID && !this.isSvrRecording)
			}
		},
		onUnload() {
			RTCSDK.ExitMeeting();
		},
		methods: {
			callback_UserEnterMeeting(UID) {
				const userInfo = RTCSDK.GetMemberInfo(UID);
				this.memberList.push(userInfo);
				this.updateRecordLayout();
			},
			callback_UserLeftMeeting(UID) {
				const idx = this.memberList.findIndex((item) => item.userID === UID);
				if (idx > -1) {
					this.memberList.splice(idx, 1);
					this.updateRecordLayout();
				}
			},
			callback_VideoStatusChanged(UID, oldStatus, newStatus) {
				if (this.myUserID === UID) {
					this.openCamStatus = newStatus === 3;
				} else {
					const idx = this.memberList.findIndex((item) => item.userID === UID);
					if (idx > -1) {
						this.memberList[idx].videoStatus = newStatus;
						this.updateRecordLayout();
					}
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
			callback_CloudMixerStateChanged(mixerID, state, exParam, operUserID) {
				if (this.mixerID !== mixerID) return;
				if (state == 1) {
					uni.showToast({
						title: '录制启动中',
						icon: 'none',
						duration: 2000
					});
				} else if (state == 2) {
					this.isSvrRecording = true;
				} else if (state == 0) {
					this.isSvrRecording = false;
				}
			},
			callback_CloudMixerOutputInfoChanged(mixerID, outputInfo) {
				if (this.lastMixerID !== mixerID) return;
				if (outputInfo.state === 5) {
					uni.showToast({
						title: '录制已生成，请前往SDK后台查看',
						icon: 'none',
						duration: 4000
					});
				} else if (outputInfo.state === 6) {
					uni.showToast({
						title: '上传失败',
						icon: 'none',
						duration: 2000
					});
				}
			},
			start() {
				const fileName = parseTime(new Date(), `/YYYY-MM-DD/YYYY-MM-DD_HH_mm_ss`) + `_WX_${this.$scope.options.roomId}.mp4`;
				const [W, H, B] = [720, 1280, 1200]; //录制分辨率1280*720，码率1200kbps

				const mixerCfg = {
					mode: 0,
					videoFileCfg: {
						svrPathName: fileName,
						vWidth: W,
						vHeight: H,
						vBps: B * 1000,
						vFps: 12,
						layoutConfig: this.createMixerLayout()
					},
				}

				this.mixerID = RTCSDK.CreateCloudMixer(mixerCfg);
			},
			createMixerLayout() {
				const [W, H] = [720, 1280];
				const w = 144, //单个成员视频宽度
					h = 256; //单个成员视频高度

				const layout = [];
				//先将自己的摄像头添加进数组
				layout.push({
					type: 0, // 录视频
					left: 0,
					top: 0,
					width: W,
					height: H,
					param: {
						camid: `${this.myUserID}.-1`
					},
					keepAspectRatio: 1
				});

				for (let i = 0; i < this.memberList.length && i < 9; i++) {
					const left = [W - w - 10, (W - w) / 2, 10][parseInt(i / 3)],
						top = (i % 3) * (h + 20) + 20;

					/* 
						这里在每个成员前添加了自己的0号摄像头
						0号摄像头是无效的，只会添加一层背景色
						这里是为了让在其他成员的视频后面一层灰色的背景色
					*/
					layout.push({
						type: 0,
						left: left,
						top: top,
						width: w,
						height: h,
						param: {
							camid: `${this.myUserID}.0`
						},
						keepAspectRatio: 1
					});

					if (this.memberList[i].videoStatus === 3) {
						// 录制其他成员的摄像头
						layout.push({
							type: 0, // 录视频
							left: left,
							top: top,
							width: w,
							height: h,
							param: {
								camid: `${this.memberList[i].userID}.-1`
							},
							keepAspectRatio: 1, //保持比例，视频将不被拉伸
						});
					} else {
						// 录制其他成员的名称
						layout.push({
							type: 10,
							left: left + w / 2 - 30,
							top: top + h / 2 - 5,
							param: {
								text: `摄像头未开启`,
								"font-size": 10,
							},
						});
					}

					// 录制其他成员的名称
					layout.push({
						type: 10,
						left: left + 5,
						top: top + 5,
						param: {
							text: `${this.memberList[i].nickname}`,
							"font-size": 10,
						},
					});
				}

				// 加时间戳
				layout.push({
					type: 10,
					left: W - 250,
					top: H - 50,
					param: {
						"font-size": 14,
						text: "%timestamp%"
					}
				});
				return layout;
			},
			// 停止云端录制
			end() {
				RTCSDK.DestroyCloudMixer(this.mixerID);
				this.lastMixerID = this.mixerID;
				this.isSvrRecording = false;
				this.mixerID = null;
			},
			//更新录制参数
			updateRecordLayout() {
				if (!this.mixerID || !this.isSvrRecording) return;

				const cfg = {
					videoFileCfg: {
						layoutConfig: this.createMixerLayout()
					}
				}

				RTCSDK.UpdateCloudMixerContent(this.mixerID, cfg);
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
			color: #fff;

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