<script>
	import constantDesc from '@/util/constantDesc.js'
	import { openPopup, closePopup } from '@/util'
	const app = getApp()
	export default {
		data() {
			return {};
		},
		onReady() {
			this.handleEventsCmd(true)
		},
		destroyed() {
			this.handleEventsCmd(false)
		},
		methods: {
			//mixins调用到此方法
			handleEventsCmd(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("sendCmdRslt", this._sendCmdRslt)
				handle("sendBufferRslt", this._sendBufferRslt)
				handle("notifySendProgress", this._notifySendProgress)
				handle("notifyCmdData", this._notifyCmdData)
				handle("notifyBufferData", this._notifyBufferData)
			},
			sendCmd() {
				uni.showModal({
					title: '发送点对点消息',
					content: '该功能将发送固定的数据',
					placeholderText: '请输入接收端userID',
					editable: true,
					success: async (res) => {
						if (res.confirm) {
							const data = `来自${this.userInfo.userId}的点对点消息`;
							const sendId = this.RTCSDK.sendCmd(res.content, data)
							this.msgPush(`发送点对点消息，sendId: ${sendId}`)
						}
					}
				})
			},
			sendBuffer() {
				uni.showModal({
					title: '发送点对点大数据',
					content: '该功能将发送固定的数据',
					placeholderText: '请输入接收端userID',
					editable: true,
					success: async (res) => {
						if (res.confirm) {
							let data = `来自${this.userInfo.userId}的点对点大数据`
							var i = 0;
							while (i < 2500) {
								data += `\n\r来自${this.userInfo.userId}的点对点大数据${i}`;
								i++
							}
							const sendId = this.RTCSDK.sendBuffer(res.content, data)
							this.msgPush(`发送点对点大数据，sendId: ${sendId}`)
						}
					}
				})
			},
			_sendCmdRslt({ sendId, sdkErr }) {
				if (sdkErr !== 0) {
					this.msgPush(`发送失败，sendId: ${sendId}，错误码:${sdkErr},${constantDesc[sdkErr]}`)
					return;
				}
				this.msgPush(`发送成功，sendId: ${sendId}`)
			},
			_sendBufferRslt({ sendId, sdkErr }) {
				if (sdkErr !== 0) {
					this.msgPush(`发送失败，sendId: ${sendId}，错误码:${sdkErr},${constantDesc[sdkErr]}`)
					return;
				}
				this.msgPush(`发送成功，sendId: ${sendId}`)
			},
			_notifySendProgress({ sendId, totalLen, sendedLen }) {
				this.msgPush(`发送进度通知，sendId: ${sendId},进度: ${parseInt(sendedLen/totalLen*100)}%,总数据量: ${totalLen},已发送: ${sendedLen}`);
			},
			_notifyCmdData({ sourceUserId, data }) {
				this.msgPush(`收到来自${sourceUserId}的点对点消息，data：${data}`);
			},
			_notifyBufferData({ sourceUserId, data }) {
				this.msgPush(`收到来自${sourceUserId}的点对点大数据，data：${data}`)
			},
		}
	}
</script>