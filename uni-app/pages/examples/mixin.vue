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
			uni.setNavigationBarTitle({
				title: `房间号：${roomId}`
			});
			this.RTCSDK = getApp().globalData.RTCSDK.getInstance();
			this.userInfo = getApp().globalData.userInfo;
			// this.handleEventsMixin(true);
			this.handleEventsPage(true);
		},
		destroyed() {
			// this.handleEventsMixin(false);
			this.handleEventsPage(false);
			this.RTCSDK.exitMeeting();
		},
		methods: {
			handleEventsMixin(bool) {
				const handle = this.RTCSDK[bool ? 'on' : 'off'];
				handle("lineOff", this._lineOff);
			},
			_lineOff({ sdkErr }) {
				
			}
		}
	}
</script>