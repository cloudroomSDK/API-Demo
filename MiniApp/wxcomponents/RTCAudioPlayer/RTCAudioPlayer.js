let RTCSDK;

let mode = null;
try {
	const res = wx.getSystemInfoSync()
	//ios使用live模式，安卓使用rtc模式
	mode = res.system.indexOf('iOS') > -1 ? 'live' : 'RTC';
} catch (e) {
	mode = 'RTC';
}

Component({
	/**
	 * 组件的属性列表
	 */
	properties: {
		//组件调试开关
		debug: {
			type: Boolean,
			value: false,
		},
		config: Object,
		extend: Object, //用户扩展，将传入 video-custom 组件
	},
	/**
	 * 组件的初始数据
	 */
	data: {
		useFirst: false,
		useSecond: false,
		RTCAudioPlayer: {
			src: '', // 音视频地址。目前仅支持 flv, rtmp 格式
			src2: '', // 音视频地址。目前仅支持 flv, rtmp 格式
			mode: mode, // live（直播），RTC（实时通话，该模式时延更低）
			autoplay: true, // 是否自动播放
			muted: false, // 是否静音
			orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal
			objectFit: 'contain', // 填充模式，可选值有 contain，fillCrop
			soundMode: 'speaker', // 声音输出方式，有效值为 speaker（扬声器）、ear（听筒）	1.9.90
			autoPauseIfNavigate: false, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放	2.5.0
			autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放	2.5.0
			minCache: 0.1, //最小缓存区
			maxCache: 0.5, //最大缓存区
		},
	},

	lifetimes: {
		created: function() {
			RTCSDK = wx.RTCSDK || getApp().globalData.RTCSDK;
			this.init = false;
		},
		// 生命周期函数，可以为函数，或一个在methods段中定义的方法名
		attached: function() {
			const soundMode = this.properties.soundMode == undefined ? this.data.RTCAudioPlayer.soundMode : this.properties.soundMode;
			const autoPauseIfNavigate = this.properties.autoPauseIfNavigate == undefined ? this.data.RTCAudioPlayer.autoPauseIfNavigate : this.properties.autoPauseIfNavigate;
			const autoPauseIfOpenNative = this.properties.autoPauseIfOpenNative == undefined ? this.data.RTCAudioPlayer.autoPauseIfOpenNative : this.properties.autoPauseIfOpenNative;

			const componentId = RTCSDK.generateUUID();

			this.setData({
				'RTCAudioPlayer.id': componentId,
				'RTCAudioPlayer.soundMode': soundMode,
				'RTCAudioPlayer.autoPauseIfNavigate': autoPauseIfNavigate,
				'RTCAudioPlayer.autoPauseIfOpenNative': autoPauseIfOpenNative
			});
			this.init = true;
			this.ComponentInit();
		},
		moved: function() {},
		detached: function() {
			RTCSDK.DestoryAudioPlayerContext();
		},
	},
	pageLifetimes: {
		// 组件所在页面的生命周期函数
		show: function() {},
		hide: function() {},
		resize: function() {},
	},

	/**
	 * 组件的方法列表
	 */
	methods: {
		//通知业务层视频组件初始化完毕,返回uuid
		ComponentInit: function() {
			this.context = RTCSDK.CreateAudioPlayerContext(
				this, //组件实例
				this.data.RTCAudioPlayer.id //组件唯一ID
			);
		},
		notifyPullSrcInfo: function(src) {
			const { useFirst, useSecond } = this.data;

			if (useFirst && useSecond) {
				if (this.changeAudio === 2) {
					this.setData({
						useSecond: false,
						['RTCAudioPlayer.src2']: '',
					})
					this.changeAudio = 1;
				} else {
					this.setData({
						useFirst: false,
						['RTCAudioPlayer.src']: '',
					})
					this.changeAudio = 2;
				}

			} else if (!useFirst) {
				this.setData({
					useFirst: true,
					['RTCAudioPlayer.src']: src,
				})
				this.changeAudio = 1;
			} else if (!useSecond) {
				this.setData({
					useSecond: true,
					['RTCAudioPlayer.src2']: src,
				})
				this.changeAudio = 2;
			}
		},
		statechange: function(e) {
			RTCSDK.BroadcastAudioPlayer(e, this.data.RTCAudioPlayer.id); //通知SDK播放器状态
			this.triggerEvent('statechange', e);
			if (e.detail.code == 2002 && this.changeAudio) {
				if (this.changeAudio === 1) {
					this.setData({
						useSecond: false,
						['RTCAudioPlayer.src2']: '',
					});
				} else {
					this.setData({
						useFirst: false,
						['RTCAudioPlayer.src']: ''
					});
				}

				this.isChange = null;
			}
		},
		netstatus: function(e) {
			this.triggerEvent('netstatus', e);
		},
		error: function(e) {
			this.triggerEvent('error', e);
		},
	},

	/**
	 * 组件的事件监听器
	 */
	observers: {
		config(config) {
			if (Object.prototype.toString.call(config) !== "[object Object]") return;
			const soundMode = config.soundMode === undefined ? this.data.RTCAudioPlayer.soundMode : config.soundMode;
			const autoPauseIfNavigate = config.autoPauseIfNavigate === undefined ? this.data.RTCAudioPlayer.autoPauseIfNavigate : config.autoPauseIfNavigate;
			const autoPauseIfOpenNative = config.autoPauseIfOpenNative === undefined ? this.data.RTCAudioPlayer.autoPauseIfOpenNative : config.autoPauseIfOpenNative;
			console.crlog(`[AUDIOCOMPONENT] config change: ${JSON.stringify({soundMode,autoPauseIfNavigate,autoPauseIfOpenNative})}`);
			this.setData({
				'RTCAudioPlayer.soundMode': soundMode,
				'RTCAudioPlayer.autoPauseIfNavigate': autoPauseIfNavigate,
				'RTCAudioPlayer.autoPauseIfOpenNative': autoPauseIfOpenNative
			})
		}
	}
})