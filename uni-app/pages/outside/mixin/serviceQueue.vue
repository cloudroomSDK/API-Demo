<script>
	import constantDesc from '@/util/constantDesc.js'
	import { openPopup, closePopup } from '@/util'
	export default {
		data() {
			return {
				queuing: false,
			};
		},
		onReady() {
			this.handleEventsServiceQueue(true)
			// this.RTCSDK.initQueue(); //此处不需要初始化了，因为在index中已经初始化了
		},
		destroyed() {
			this.handleEventsServiceQueue(false)
		},
		methods: {
			//注册SDK回调函数
			handleEventsServiceQueue(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("autoAssignUser", this._autoAssignUser);
				handle("cancelAssignUser", this._cancelAssignUser);
				handle("responseAssignUserRslt", this._responseAssignUserRslt);
				handle("queueStatusChanged", this._queueStatusChanged);
				handle("reqAssignUserRslt", this._reqAssignUserRslt);
			},
			getServiceQueues() {
				const serviceQueues = this.RTCSDK.getServiceQueues();
				if (serviceQueues.length) {
					this.msgPush(`正在服务的队列ID: ${serviceQueues}`)
				} else {
					this.msgPush(`没有正在服务的队列`)
				}
			},
			startService() {
				const allQueueInfo = this.RTCSDK.getAllQueueInfo();
				if (allQueueInfo.length === 0) {
					uni.showToast({
						title: '此AppId没有队列，可在SDK后台创建队列',
						icon: 'none',
						duration: 4000
					});
					return;
				}

				const serviceQueues = this.RTCSDK.getServiceQueues();
				const notServiceQueuesInfo = allQueueInfo.filter(queueinfo => {
					return serviceQueues.indexOf(queueinfo.queID) === -1
				})

				uni.showActionSheet({
					itemList: notServiceQueuesInfo.map(item => item.name),
					success: (res) => {
						const selectItem = notServiceQueuesInfo[res.tapIndex];
						this.RTCSDK.startService(selectItem.queID);
						this.msgPush(`开始服务队列，队列ID: ${selectItem.queID},队列名称：${selectItem.name}`)
					}
				});
			},
			stopService() {
				const serviceQueues = this.RTCSDK.getServiceQueues();
				if (!serviceQueues.length) {
					uni.showToast({
						title: '当前没有服务队列',
						icon: 'none',
						duration: 2000
					});
					return
				}
				const allQueueInfo = this.RTCSDK.getAllQueueInfo();

				// 检索正在服务的队列的信息
				const servicingQueuesInfo = serviceQueues.map(queID => {
					return allQueueInfo.find(queueInfo => queueInfo.queID === queID)
				})

				uni.showActionSheet({
					itemList: servicingQueuesInfo.map(item => item.name),
					success: (res) => {
						const selectItem = servicingQueuesInfo[res.tapIndex];
						this.RTCSDK.stopService(selectItem.queID)
						this.msgPush(`停止服务队列，队列ID: ${selectItem.queID},队列名称：${selectItem.name}`)
					}
				});
			},
			getQueueStatus() {
				const serviceQueues = this.RTCSDK.getServiceQueues();
				if (!serviceQueues.length) {
					uni.showToast({
						title: '当前没有服务队列',
						icon: 'none',
						duration: 2000
					});
					return
				}

				const allQueueInfo = this.RTCSDK.getAllQueueInfo();
				// 检索正在服务的队列的信息
				const servicingQueuesInfo = serviceQueues.map(queID => {
					return allQueueInfo.find(queueInfo => queueInfo.queID === queID)
				})

				uni.showActionSheet({
					itemList: servicingQueuesInfo.map(item => item.name),
					success: (res) => {
						const selectItem = servicingQueuesInfo[res.tapIndex];
						const status = this.RTCSDK.getQueueStatus(selectItem.queID);
						this.msgPush(`队列状态：${JSON.stringify(status)}`)
					}
				});
			},
			reqAssignUser() {
				if (!this.isOpenNotDisturb) {
					uni.showToast({
						title: `请先开启免打扰功能`,
						icon: 'none'
					})
					return;
				}
				this.RTCSDK.reqAssignUser();
			},
			_autoAssignUser({ usr }) {
				this.msgPush(`系统自动分配了客户，队列ID: ${usr.queID},userID：${usr.usrID},昵称： ${usr.name},排队时长： ${usr.queuingTime}秒`)

				openPopup({
					title: '用户分配',
					content: `系统为您分配【${usr.usrID}】`,
					cancelText: '拒绝',
					confirmText: '接受',
					confirm: (res) => {
						this.msgPush(`已接受本次分配`)
						this.RTCSDK.acceptAssignUser(usr.queID, usr.usrID);
						// 这里需要注意，创建房间后，还有呼叫相关的逻辑。参见创建房间的回调
						this.RTCSDK.createMeeting(JSON.stringify({
							type: 'call',
							calledUserID: usr.usrID
						}));
					},
					cancel: (res) => {
						this.msgPush(`已拒绝本次分配`)
						this.RTCSDK.rejectAssignUser(usr.queID, usr.usrID)
					}
				})
			},
			_cancelAssignUser({ queID, userID }) {
				this.msgPush(`系统取消本次分配，queID: ${queID},userID: ${userID}`)
				closePopup()
			},
			_responseAssignUserRslt({ sdkErr, cookie }) {
				if (sdkErr !== 0) {
					this.msgPush(`响应分配客户操作失败，错误码: ${sdkErr}, ${constantDesc[sdkErr]}`)
				}
			},
			_queueStatusChanged({ queStatus }) {
				this.msgPush(`队列状态变化: ${JSON.stringify(queStatus)}`)
			},
			_reqAssignUserRslt({ sdkErr, usr }) {
				if (sdkErr !== 0) {
					this.msgPush(`手动分配失败，错误码:${sdkErr},${constantDesc[sdkErr]}`)
					return;
				}

				this.msgPush(`手动分配成功，用户数据：${JSON.stringify(usr)}`)
				openPopup({
					title: '用户分配',
					content: `为您分配下一位客户【${usr.usrID}】`,
					cancelText: '拒绝',
					confirmText: '接受',
					confirm: (res) => {
						this.msgPush(`已接受本次分配`)
						this.RTCSDK.acceptAssignUser(usr.queID, usr.usrID);
						// 这里需要注意，创建房间后，还有呼叫相关的逻辑。参见创建房间的回调
						this.RTCSDK.createMeeting(JSON.stringify({
							type: 'call',
							calledUserID: usr.usrID
						}));
					},
					cancel: (res) => {
						this.msgPush(`已拒绝本次分配`)
						this.RTCSDK.rejectAssignUser(usr.queID, usr.usrID)
					}
				})
			}
		}
	}
</script>