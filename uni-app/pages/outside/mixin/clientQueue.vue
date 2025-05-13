<script>
	import constantDesc from '@/util/constantDesc.js'
	import { closePopup, openPopup } from '@/util'

	const app = getApp();
	export default {
		data() {
			return {
				queuing: false,
			};
		},
		onReady() {
			this.handleEventsClientQueqe(true)
			// this.RTCSDK.initQueue(); //此处不需要初始化了，因为在index中已经初始化了
		},
		destroyed() {
			this.handleEventsClientQueqe(false)
		},
		methods: {
			//注册SDK回调函数
			handleEventsClientQueqe(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("initQueueDatRslt", this._clientInitQueueDatRslt);
				handle("queuingInfoChanged", this._queuingInfoChanged);
				handle("startQueuingRslt", this._startQueuingRslt);
				handle("stopQueuingRslt", this._stopQueuingRslt);
				handle("notifyCallIn", this._clientNotifyCallIn);
			},
			startQueuing() {
				const allQueueInfo = this.RTCSDK.getAllQueueInfo();
				if (allQueueInfo.length === 0) {
					uni.showToast({
						title: '此AppId没有队列，可在SDK后台创建队列',
						icon: 'none',
						duration: 4000
					});
					return;
				}

				if (this.isOpenNotDisturb) {
					uni.showToast({
						title: '请先关闭免打扰功能',
						icon: 'none',
						duration: 4000
					});
					return;
				}

				const serviceQueues = this.RTCSDK.getServiceQueues();
				if (serviceQueues.length) {
					uni.showToast({
						title: '请先停止所有服务的队列',
						icon: 'none',
						duration: 4000
					});
					return;
				}

				uni.showActionSheet({
					itemList: allQueueInfo.map(item => item.name),
					success: (res) => {
						const selectItem = allQueueInfo[res.tapIndex];
						this.RTCSDK.startQueuing(selectItem.queID);
						this.msgPush(`开始排队，队列ID: ${selectItem.queID},队列名称：${selectItem.name}`)
						this.queuing = true;
					}
				});
			},
			getAllQueueInfo() {
				const allQueueInfo = this.RTCSDK.getAllQueueInfo();
				this.msgPush(`所有队列信息: ${JSON.stringify(allQueueInfo)}`, )
				return allQueueInfo;
			},
			_clientInitQueueDatRslt() {
				const queuingInfo = this.RTCSDK.getQueuingInfo();
				if (queuingInfo.queID > -1) {
					//进入这里说明是重登的状态，需要把状态重置一下
					this.queuing = true;
					this.msgPush(`已恢复排队状态，当前排队信息：队列ID：${queuingInfo.queID},前方${queuingInfo.position-1}人排队，已排${queuingInfo.queuingTime}秒`)

					openPopup({
						title: '排队中',
						maskClick: false,
						content: `排队信息可关注信息面板`,
						showCancel: false,
						confirmText: '停止排队',
						confirmColor: "#f10211",
						confirm: (res) => {
							this.queuing = false; //uniapp的bug，点击后按钮要延时才能置灰
							this.msgPush(`停止排队`)
							this.RTCSDK.stopQueuing();
						}
					})
				}
			},
			_queuingInfoChanged({ queuingInfo }) {
				if (queuingInfo.queID > 0) {
					this.msgPush(`排队信息变化：${JSON.stringify(queuingInfo)}`);
				}
			},
			_startQueuingRslt({ sdkErr }) {
				if (sdkErr !== 0) {
					this.queuing = false;
					this.msgPush(`开始排队失败，没这种可能`);
					return;
				}

				const queuingInfo = this.RTCSDK.getQueuingInfo();
				this.msgPush(`排队信息: ${JSON.stringify(queuingInfo)}`, )

				openPopup({
					title: '排队中',
					maskClick: false,
					content: `排队信息可关注信息面板`,
					showCancel: false,
					confirmText: '停止排队',
					confirmColor: "#f10211",
					confirm: (res) => {
						this.queuing = false; //uniapp的bug，点击后按钮要延时才能置灰
						this.RTCSDK.stopQueuing();
					}
				})
			},
			_stopQueuingRslt({ sdkErr }) {
				if (sdkErr !== 0) {
					this.queuing = true;
					this.msgPush(`停止排队失败，没这种可能`);
					return;
				}
				this.msgPush(`停止排队成功`);
			},
			_clientNotifyCallIn({ callID, ID, callerID, usrExtDat }) {
				if (!app.globalData.popupConfig) {
					// 如果此时界面上不存在弹框，说明是别的的直接呼叫，由呼叫的mixin处理
					return;
				}
				this.msgPush(`收到坐席呼叫，坐席端UserID: ${callerID}，呼叫ID: ${callID}`)

				//因为openPopup里面给app.globalData.popupConfig赋值了
				//加个延迟可以避免其他订阅_notifyCallIn的地方判断app.globalData.popupConfig的值异常
				setTimeout(async () => {
					closePopup();
					this.callID = callID;
					this.queuing = false;
					this.RTCSDK.acceptCall(callID, ID)
					await this.permissionHandle()
					this.roomId = ID;
					const { nickname } = getApp().globalData.userInfo;
					this.RTCSDK.enterMeeting(ID, nickname);
				})
			},
		}
	}
</script>