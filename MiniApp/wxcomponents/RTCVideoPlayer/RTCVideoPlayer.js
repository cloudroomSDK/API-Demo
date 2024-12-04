let RTCSDK;
Component({
	/**
	 * 组件的属性列表
	 */
	properties: {
		userInfo: Object, //用户信息
		config: Object,
		debug: {	//组件调试开关
			type: Boolean,
			value: false,
		}
	},

	/**
	 * 组件的初始数据
	 */
	data: {
		type: 'video', //媒体类型,可取值 video,screen,media
		userId: '',	//用户userId
		camId: -1, //摄像头ID，type=video时有效
		id: '', //组件唯一ID
		src: '', // 音视频地址。目前仅支持 flv, rtmp 格式
		mode: 'RTC', // live（直播），RTC（实时通话，该模式时延更低）
		autoplay: true, // 是否自动播放
		muted: true, // 是否静音
		orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal
		objectFit: 'fillCrop', // 填充模式，可选值有 contain，fillCrop
		autoPauseIfNavigate: false, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放	2.5.0
		autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放	2.5.0
		soundMode: 'ear',
		definition: 'VIDEO_SS_1M',	//该项请勿修改
	},

	lifetimes: {
		created() {
			RTCSDK = wx.RTCSDK || getApp().globalData.RTCSDK;
			this.init = false;
		},
		// 生命周期函数，可以为函数，或一个在methods段中定义的方法名
		attached() {
			const soundMode = RTCSDK.GetAudioPlayType();
			const componentId = RTCSDK.generateUUID();
			this.setData({
				id: componentId,
				soundMode: soundMode,
			});

			console.crlog(`[VideoPlayComponent] attached id: ${componentId}`);
			this.ComponentInit();
			this.init = true;
		},
		detached() {
			console.crlog(`[VideoPlayComponent] detached id: ${this.data.id}`);
			if (this.data.type === 'screen') RTCSDK.Publish.removeAllEvent('getScreenInfo');
			this.fullScreenStatus && this.exitFullScreen();
			this.ComponentUninit();
		},
	},

	/**
	 * 组件的方法列表
	 */
	methods: {
		//通知业务层视频组件初始化完毕,返回uuid
		ComponentInit() {
			this.context = RTCSDK.CreateVideoPlayerContext(
				this, //组件实例
				this.data.type, //媒体类型
				this.data.id, //组件唯一ID
				this.data.userId,
				this.data.camId,
				this.data.definition
			);

			if (this.data.type === 'screen') RTCSDK.Publish.addEventListener('getScreenInfo', this._sendScreenInfo.bind(this));
		},
		//反初始化
		ComponentUninit() {
			RTCSDK.DestoryVideoPlayerContext(this.data.id, this.data.type, this.data.userId);	//销毁组件
		},
		notifyPullSrcInfo(src, callback) {
			console.crlog(`[VideoPlayComponent] notifyPullSrc userId: ${this.data.userId},type: ${this.data.type},src: ${src}`);
			this.setData({
				src: src
			}, callback);
		},
		statechange(e) {
			RTCSDK.BroadcastLivePlayer(this.data.userId, e, this.data.type, this.data.id);
			if (e.detail.code === 2003) {
				this.playing = true;
			}
			this.triggerEvent('statechange', {
				userId: this.data.userId,
				type: this.data.type,
				e
			});
		},
		netstatus(e) {
			if (this.data.type === 'screen') {
				this.videoWidth = e.detail.info.videoWidth;
				this.videoHeight = e.detail.info.videoHeight;
			};
			this.triggerEvent('netstatus', {
				userId: this.data.userId,
				type: this.data.type,
				e
			});
		},
		error(e) {
			this.triggerEvent('error', {
				userId: this.data.userId,
				type: this.data.type,
				e
			});
		},
		//全屏，父组件调用
		fullScreen(e) {
			RTCSDK.VideoRequestFullscreen(this.context, e || this.data.orientation);
			this.fullScreenStatus = true;
		},
		//退出全屏，父组件调用
		exitFullScreen() {
			RTCSDK.VideoExitFullscreen(this.context);
			this.fullScreenStatus = false;
		},
		//快照
		snapshot(quality, returnBase64) {
			return new Promise((resolve, reject) => {
				this.context && this.context.snapshot(quality || 'raw').then(res => {
					if (!returnBase64) return resolve(res);

					const fileSystemManager = wx.getFileSystemManager();
					const base64 = 'data:image/jpeg;base64,' + fileSystemManager.readFileSync(res.tempImagePath, "base64");
					res.base64 = base64;
					resolve(res);

				}).catch(err => {
					throw err;
				})
			})
		},
		//发送屏幕共享信息
		_sendScreenInfo() {
			if (!this.videoWidth || !this.videoHeight || !this.playing) {
				RTCSDK.Publish.emitEventListener('sendScreenInfo', {
					code: 1,	//未开始推流
				});
				return;
			};
			this.snapshot('raw').then(res => {
				RTCSDK.Publish.emitEventListener('sendScreenInfo', Object.assign(res, {
					code: 0,
					videoWidth: this.videoWidth || res.width,
					videoHeight: this.videoHeight || res.height
				}));
			}).catch(error => {
				console.crlog(error);
				RTCSDK.Publish.emitEventListener('sendScreenInfo', {
					code: 2,	//截图失败
				});
			})
		}
	},

	/**
	 * 组件的事件监听器
	 */
	observers: {
		//userInfo已废弃，请使用config中的userId参数
		userInfo(userInfo) {
			if (Object.prototype.toString.call(userInfo) !== "[object Object]") return;
			if (userInfo && userInfo.userID && (userInfo.userID !== this.data.userId)) {
				this.setData({ userId: userInfo.userID });
				console.crlog(`[VideoPlayComponent] userInfo change,userId: ${userInfo.userID},type: ${this.data.type}`);
				console.warn(`userInfo参数已废弃，请查阅最新的文档`);
			}
		},
		config(config) {
			if (Object.prototype.toString.call(config) !== "[object Object]") return;
			const obj = Object.keys(config).reduce((previousValue, currentValue) => {
				if (config[currentValue] !== this.data[currentValue]) {
					previousValue[currentValue] = config[currentValue];
				}
				if (currentValue === 'definition' && this.init) {
					RTCSDK.UpdateCamDefinition(this.data.userId, this.data.camId, config[currentValue]);
				}
				return previousValue;
			}, {})

			if (Object.keys(obj).length) {
				const shouldComponentInit = obj.userId || obj.camId || obj.type;
				if (shouldComponentInit) {
					this.ComponentUninit();
				}

				this.setData(obj);
				
				if (shouldComponentInit && this.init) {
					this.ComponentInit();
				}

				console.crlog(`[VideoPlayComponent] config change,userId: ${this.data.userId},type: ${this.data.type},config: ${JSON.stringify(obj)}`);
			}
		}
	}
})
