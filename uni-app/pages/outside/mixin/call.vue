<script>
	import constantDesc from '@/util/constantDesc.js'
	import { openPopup, closePopup } from '@/util'
	const app = getApp()
	export default {
		data() {
			return {};
		},
		onReady() {
			this.handleEventsCall(true)
		},
		destroyed() {
			this.handleEventsCall(false)
		},
		onShow() {
			// 自定义弹窗点击确定或取消后，会进入onshow回调
			if (this.callID && !app.globalData.popupConfig) {
				this.RTCSDK.hangupCall(this.callID)
				this.msgPush(`挂断呼叫,呼叫ID:${this.callID}`)
				this.callID = null;
			}
		},
		methods: {
			//mixins调用到此方法
			handleEventsCall(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("callRslt", this._callRslt);
				handle("acceptCallRslt", this._acceptCallRslt);
				handle("rejectCallRslt", this._rejectCallRslt);
				handle("notifyCallAccepted", this._notifyCallAccepted);
				handle("notifyCallRejected", this._notifyCallRejected);
				handle("notifyCallIn", this._notifyCallIn);
				handle("notifyCallHungup", this._notifyCallHungup);
			},
			call() {
				uni.showModal({
					title: '发起呼叫',
					content: '该功能需要和呼叫Demo的直呼功能联调',
					placeholderText: '请输入被呼端userID',
					editable: true,
					success: async (res) => {
						if (res.confirm) {
							await this.permissionHandle()
							this.msgPush(`正在创建房间...`)
							// 呼叫之前必须有房间号，呼叫的逻辑参见创建房间的回调
							this.RTCSDK.createMeeting(JSON.stringify({
								type: 'call',
								calledUserID: res.content
							}));
						}
					}
				})
			},
			_callRslt({ callID, sdkErr }) {
				if (sdkErr === 0) {
					this.msgPush(`呼叫发起成功，等待被呼端响应...`)
				} else {
					this.callID = null;
					this.msgPush(`呼叫失败，错误码:${sdkErr},${constantDesc[sdkErr]}`)
				}
			},
			_acceptCallRslt({ callID, sdkErr }) {
				if (sdkErr === 0) {
					this.msgPush(`接受呼叫成功`)
				} else {
					this.msgPush(`接受呼叫失败，错误码:${sdkErr},${constantDesc[sdkErr]}`)
				}
			},
			_rejectCallRslt({ callID, sdkErr }) {
				if (sdkErr === 0) {
					this.msgPush(`拒绝呼叫成功`)
				} else {
					this.msgPush(`拒绝呼叫失败，错误码:${sdkErr},${constantDesc[sdkErr]}`)
				}
			},
			async _notifyCallAccepted({ ID, callID }) {
				this.msgPush(`被呼端已接受，正在进入房间...`);
				await this.permissionHandle()
				this.roomId = ID;
				this.RTCSDK.enterMeeting(ID);
			},
			_notifyCallRejected({ sdkErr }) {
				this.msgPush(`呼叫失败，错误码:${sdkErr},${constantDesc[sdkErr]}`)
				this.callID = null;
			},
			_notifyCallIn({ callID, ID, callerID, usrExtDat }) {
				if (app.globalData.popupConfig) {
					// 如果此时存在弹框，说明此呼叫是坐席发来的呼叫，由客户排队的mixin处理
					return;
				}

				//因为openPopup里面给app.globalData.popupConfig赋值了
				//加个延迟可以避免其他订阅_notifyCallIn的地方判断app.globalData.popupConfig的值异常
				setTimeout(() => {
					this.callID = callID;
					this.msgPush(`收到呼叫，呼叫端UserID: ${callerID}，呼叫ID: ${callID}`)

					openPopup({
						title: '呼叫请求',
						content: `是否接受来自${callerID}的呼叫?`,
						cancelText: '拒绝',
						confirmText: '接受',
						confirm: async (res) => {
							this.msgPush(`已接受，准备进入房间，呼叫ID: ${callID}`)
							this.RTCSDK.acceptCall(callID, ID)
							await this.permissionHandle()
							this.roomId = ID;
							this.RTCSDK.enterMeeting(ID);
						},
						cancel: (res) => {
							this.msgPush(`已拒绝，呼叫ID: ${callID}`)
							this.RTCSDK.rejectCall(callID)
						}
					})
				})
			},
			_notifyCallHungup({ callID }) {
				if (this.callID === callID) {
					this.msgPush(`收到呼叫挂断通知，呼叫ID: ${callID}`)
					this.callID = null;
					closePopup()
				}
			},
		}
	}
</script>