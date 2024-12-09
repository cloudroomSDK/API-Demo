<script>
	import constantDesc from '@/util/constantDesc';
	import { createEnum } from '@/util';
	const loginEnum = createEnum(['logout', 'logging', 'loged']);
	export default {
		data() {
			return {
				userInfo: null,
				RTCSDK: null,
			}
		},
		onLoad({ roomId }) {
			uni.setNavigationBarTitle({ title: `房间号：${roomId}` });
			uni.setKeepScreenOn({ keepScreenOn: true }); // 保持屏幕常亮

			this.RTCSDK = getApp().globalData.RTCSDK.getInstance();
			this.userInfo = getApp().globalData.userInfo;
			this.handleEventsMixin(true);
			this.handleEventsPage(true);
		},
		destroyed() {
			uni.setKeepScreenOn({ keepScreenOn: false });
			this.handleEventsMixin(false);
			this.handleEventsPage(false);
			this.RTCSDK.exitMeeting();
		},
		methods: {
			handleEventsMixin(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("lineOff", this._lineOff);
				handle("meetingDropped", this._meetingDropped);
				handle("meetingStopped", this._meetingStopped);
			},
			_lineOff({ sdkErr }) {
				uni.showModal({
					title: '掉线通知',
					content: `已掉线，错误码: ${sdkErr}, ${constantDesc[sdkErr]}`,
					showCancel: false,
					success: (res) => {
						// uni.navigateBack()
					}
				})
			},
			_meetingDropped({ reason }) {
				uni.showModal({
					title: '掉线通知',
					content: ['网络通信超时', '被他人请出会议', '余额不足', 'Token鉴权方式下，token无效或过期'][reason],
					showCancel: false,
					success: (res) => {
						uni.navigateBack()
					}
				})
			},
			_meetingStopped() {
				uni.showModal({
					title: '提示',
					content: '房间已结束',
					showCancel: false,
					success: (res) => {
						uni.navigateBack()
					}
				})
			}
		}
	}
</script>