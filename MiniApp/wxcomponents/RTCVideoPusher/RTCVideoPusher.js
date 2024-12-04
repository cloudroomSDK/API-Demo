let RTCSDK;

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
		config: Object, //组件调试开关
		userInfo: Object, //用户信息
	},

	/**
	 * 组件的初始数据
	 */
	data: {
		url: '', // 推流地址。目前仅支持 flv, rtmp 格式
		mode: 'RTC', // SD（标清）, HD（高清）, FHD（超清）, RTC（实时通话）
		autopush: false, // 是否自动推流
		muted: false, // 是否静音
		enableCamera: false, // 是否开启摄像头
		autoFocus: true, // 自动聚集
		orientation: 'vertical', // vertical，horizontal
		beauty: 5, // 美颜，取值范围 0-9 ，0 表示关闭
		whiteness: 5, // 美白，取值范围 0-9 ，0 表示关闭
		aspect: '3:4', // 宽高比，可选值有 3:4, 9:16
		minBitrate: 100, //	最小码率
		maxBitrate: 800, // 最大码率
		waitingImage: '', // 进入后台时推流的等待画面
		zoom: false, // 调整焦距	2.1.0
		devicePosition: 'front', // 前置或后置，值为front, back	2.3.0
		backgroundMute: false, // 进入后台时是否静音
		audioVolumeType: 'voicecall',   //通话音量： media(媒体音量)、voicecall(通话音量)
		localMirror: 'auto',	//控制本地预览画面是否镜像	,auto/enable/disable
		remoteMirror: false,	//设置推流画面是否镜像，产生的效果在 live-player 反应到,支持动态
		enableAgc: false, //是否开启音频自动增益
		enableAnc: false,	//是否开启音频噪声抑制
		beautyStyle: 'smooth',	//设置美颜类型,'smooth'(默认)/'nature'
		filter: 'standard',	//滤镜
		defaultOpenVideo: true, //默认打开摄像头
		defaultOpenMic: true, //默认打开摄像头
		showComponent: true,
	},

	lifetimes: {
		created() {
			RTCSDK = wx.RTCSDK || getApp().globalData.RTCSDK;
			this.init = false;

		},
		// 生命周期函数，可以为函数，或一个在methods段中定义的方法名
		attached() {
			console.crlog(`[VideoPusherComponent] attached()`);
			this.permissions = {
				camera: undefined,
				record: undefined
			}
			this.permissionsToDetect().then(res => {
				console.crlog('[VideoPusherComponent] permissions:' + JSON.stringify(res));
				this.permissions = {
					camera: res.camera,
					record: res.record
				}
				this.ComponentInit();
			}).catch(err => {
				console.crlog(err);
				this.ComponentInit();
			})
			this.init = true;
		},
		detached() {
			RTCSDK.DestoryVideoPusherContext();
		},
	},

	/**
	 * 组件的方法列表
	 */
	methods: {
		reset() {
			console.crlog(`[VideoPusherComponent] reset()`);
			this.setData({
				showComponent: false,
				defaultOpenVideo: this.data.enableCamera,
				defaultOpenMic: !this.data.muted
			}, () => {
				this.setData({ showComponent: true }, () => {
					this.ComponentInit();
				})
			})
		},
		//检测麦克风摄像头权限
		permissionsToDetect() {
			return new Promise((resolve, reject) => {
				const authorize = {};
				let i = 0;

				function g() {
					if (i === 2) {
						resolve(authorize)
					}
				}
				wx.authorize({
					scope: 'scope.record',
					success() {
						authorize.record = true;
					},
					fail() {
						authorize.record = false;
					},
					complete() {
						i++;
						g();
					}
				});
				wx.authorize({
					scope: 'scope.camera',
					success() {
						authorize.camera = true;
					},
					fail() {
						authorize.camera = false;
					},
					complete() {
						i++;
						g();
					}
				});
			})
		},
		//通知业务层视频组件初始化完毕,返回uuid
		ComponentInit() {
			if (this.data.defaultOpenMic && this.data.defaultOpenMic !== this.permissions.record) {
				//默认打开麦克风但是权限不足
				this.setData({
					defaultOpenMic: false
				});
				RTCSDK.OpenMicFailRslt.callback(RTCSDK.Constant['CRVideo_MIC_FAIL_WX_NO_PERMISSIONS']);	//业务层可以接收麦克风打开失败回调
			}
			if (this.data.defaultOpenVideo && this.data.defaultOpenVideo !== this.permissions.camera) {
				//默认打开摄像头但是权限不足
				this.setData({
					defaultOpenVideo: false
				})
				RTCSDK.OpenVideoFailRslt.callback(RTCSDK.Constant['CRVideo_CAM_FAIL_WX_NO_PERMISSIONS']);	//业务层可以接收摄像头打开失败回调
			}

			this.context = RTCSDK.CreateVideoPusherContext(
				this, //组件实例
				this.data.defaultOpenVideo, //默认打开摄像头
				this.data.defaultOpenMic, //默认打开麦克风
			);
		},
		statechange(e) {
			RTCSDK.BroadcastLivePusher(e);
			this.triggerEvent('statechange', e);
		},
		netstatus(e) {
			RTCSDK.BroadcastLivePusherNet(e);
			this.triggerEvent('netstatus', e);
		},
		error(e) {
			this.triggerEvent('error', e);
		},
		audiovolumenotify(e) {
			this.triggerEvent('audiovolumenotify', e);
		},
		setLivePusherOptions(key, value) { //SDK调用方法
			return new Promise((resolve, reject) => {
				if (key === 'enableCamera') {
					this.customCameraState = true;
				} else if (key === 'muted') {
					this.customMutedState = true;
				}

				if (key === 'enableCamera' && value === true && RTCSDK.systemInfo.cameraAuthorized === false) {
					console.crlog('[VideoPusherComponent] app camera is not permissions');
					RTCSDK.OpenVideoFailRslt.callback(RTCSDK.Constant['CRVideo_CAM_FAIL_APP_NO_PERMISSIONS']);	//业务层可以接收摄像头打开失败回调
					return reject('noTpermissions');
				} else if (key === 'enableCamera' && value === true && this.permissions.camera === false) {
					console.crlog('[VideoPusherComponent] wxmini camera is not permissions');
					RTCSDK.OpenVideoFailRslt.callback(RTCSDK.Constant['CRVideo_CAM_FAIL_WX_NO_PERMISSIONS']);	//业务层可以接收摄像头打开失败回调
					return reject('noTpermissions');
				} else if (key === 'muted' && value === false && RTCSDK.systemInfo.microphoneAuthorized === false) {
					console.crlog('[VideoPusherComponent] app record is not permissions');
					RTCSDK.OpenMicFailRslt.callback(RTCSDK.Constant['CRVideo_MIC_FAIL_APP_NO_PERMISSIONS']);	//业务层可以接收麦克风打开失败回调
					return reject('noTpermissions');
				} else if (key === 'muted' && value === false && this.permissions.record === false) {
					console.crlog('[VideoPusherComponent] wxmini record is not permissions');
					RTCSDK.OpenMicFailRslt.callback(RTCSDK.Constant['CRVideo_MIC_FAIL_WX_NO_PERMISSIONS']);	//业务层可以接收麦克风打开失败回调
					return reject('noTpermissions');
				}
				if (this.data[key] === value) {
					resolve();
					return;
				};

				this.setData({
					[key]: value
				}, () => {
					console.crlog(`[VideoPusherComponent] Set livepusher options: ${key}-${value}`);
					resolve();
				})
			})
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
		}
	},

	/**
	 * 组件的事件监听器
	 */
	observers: {
		config(config) {
			if (Object.prototype.toString.call(config) !== "[object Object]") return;
			const obj = Object.keys(config).reduce((previousValue, currentValue) => {
				if (currentValue === 'enableCamera' && !this.customCameraState) {
					if (this.data.defaultOpenVideo !== config[currentValue]) previousValue.defaultOpenVideo = config[currentValue];
				} else if (currentValue === 'muted' && !this.customMutedState) {
					if (this.data.defaultOpenMic === config[currentValue]) previousValue.defaultOpenMic = !config[currentValue]
				} else if (config[currentValue] !== this.data[currentValue]) {
					previousValue[currentValue] = config[currentValue];
				}
				return previousValue;
			}, {})

			if (Object.keys(obj).length) {
				console.crlog(`[VideoPusherComponent] config change: ${JSON.stringify(obj)}`);
				this.setData(obj);
			}
		},
	}
})
