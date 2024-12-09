<script>
	import { openPopup, closePopup } from '@/util'
	export default {
		data() {
			return {
				inviteID: null, //保存邀请ID
			};
		},
		onReady() {
			this.handleEventsInvite(true)
		},
		destroyed() {
			this.handleEventsInvite(false)
		},
		methods: {
			//mixins调用到此方法
			handleEventsInvite(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("notifyInviteIn", this._notifyInviteIn);
				handle("notifyInviteCanceled", this._notifyInviteCanceled);
			},
			_notifyInviteIn({ inviteID, inviterUsrID, usrExtDat }) {
				this.msgPush(`收到来自${inviterUsrID}的邀请，邀请ID: ${inviteID}`)
				this.inviteID = inviteID;
				const data = JSON.parse(usrExtDat);
				const ID = +data.meeting?.ID;
				if (ID) {
					openPopup({
						title: '邀请',
						content: `是否接受来自${inviterUsrID}的邀请?`,
						cancelText: '拒绝',
						confirmText: '接受',
						confirm: async (res) => {
							this.msgPush(`已接受，准备进入房间，邀请ID: ${this.inviteID}`)
							this.RTCSDK.acceptInvite(this.inviteID)
							await this.permissionHandle()
							this.roomId = ID;
							this.RTCSDK.enterMeeting(ID);
						},
						cancel: (res) => {
							this.msgPush(`已拒绝，邀请ID: ${this.inviteID}`)
							this.RTCSDK.rejectInvite(this.inviteID)
						}
					})
				}
			},
			_notifyInviteCanceled({ inviteID, sdkErr, usrExtDat }) {
				if (this.inviteID === inviteID) {
					this.msgPush(`邀请被取消，邀请ID: ${inviteID}`)
					this.inviteID = null;
					closePopup()
				}
			},
		}
	}
</script>