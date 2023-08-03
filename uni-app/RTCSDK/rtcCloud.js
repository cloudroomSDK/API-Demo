import Observer from "./observer.js";

const RtcPlugin = uni.requireNativePlugin("rtcsdk-plugin");
const globalEvent = uni.requireNativePlugin("globalEvent");
const version = "1.0.0";
const eventBus = new Observer();

const isAndroid = uni.getSystemInfoSync().platform == "android";
const isIos = uni.getSystemInfoSync().platform == "ios";
let devicePosition = {
	front: null,
	back: null,
};

let rtcCloud = null;
let firstEnterMeeting = true;
let firstOpenMic = false;

globalEvent.addEventListener("mgrCallback", (data) => {
	if (['micEnergyUpdate'].indexOf(data.method) == -1) {
		console.log(data.method, data);
	}
	if (data.method === 'enterMeetingRslt' && data.sdkErr === 0) {
		const myUserID = rtcCloud.getMyUserID();
		if (isAndroid) {
			rtcCloud.getAllVideoInfo(myUserID).forEach((videoInfo) => {
				devicePosition[videoInfo.videoName.indexOf('FRONT') > -1 ? 'front' : 'back'] = videoInfo.videoID;
			});
		}
		if (isIos) {
			const defaultId = rtcCloud.getDefaultVideo(myUserID);
			devicePosition.back = defaultId;
			rtcCloud.getAllVideoInfo(myUserID).some((videoInfo) => {
				if (videoInfo.videoID !== defaultId) {
					devicePosition.front = videoInfo.videoID;
					return true;
				}
			});
			setTimeout(() => {
				// ios默认听筒输出，将
				if (firstEnterMeeting) {
					if (firstOpenMic) {
						rtcCloud.setSpeakerOut(firstOpenMic);
					}
					firstOpenMic = null;
					firstEnterMeeting = null;
				}
			}, 150)
		}
	}
	eventBus.emits(data.method, data);
});

export default class RtcCloud {
	constructor() {}
	static getInstance() {
		if (rtcCloud) {
			return rtcCloud;
		}
		rtcCloud = new RtcCloud();
		return rtcCloud;
	}
	on(event, func) {
		eventBus.on(event, func);
		return this;
	}
	off(event, func) {
		eventBus.off(event, func);
		return this;
	}
	getCloudroomVideoSDKVer() {
		return RtcPlugin.GetCloudroomVideoSDKVer();
	}
	isNotificationPermissionOpen() {
		return RtcPlugin.isNotificationPermissionOpen();
	}
	openNotificationPermissionSetting() {
		return RtcPlugin.openNotificationPermissionSetting();
	}
	getSDKVersion() {
		return version;
	}
	addEventListener() {}
	init(option = {}, fn) {
		RtcPlugin.init(option, fn);
	}
	uninit() {
		RtcPlugin.uninit();
	}
	getServerAddr() {
		return RtcPlugin.getServerAddr();
	}
	//设置服务器地址
	setServerAddr(addr) {
		RtcPlugin.setServerAddr(addr);
	}
	//登录
	login({ appId, appSecret, nickName, userId, userAuthCode, cookie }) {
		const obj = {
			nickName: nickName,
			privAcnt: userId,
			authAcnt: appId,
			authPswd: appSecret,
			privAuthCode: userAuthCode
		}
		RtcPlugin.login(obj);
	}
	logout() {
		RtcPlugin.logout();
	}

	getMyUserID() {
		return RtcPlugin.getMyUserID();
	}
	//获取房间内所有成员信息
	getAllMembers() {
		return RtcPlugin.getAllMembers();
	}
	getMemberInfo(userId) {
		return RtcPlugin.getMemberInfo(userId);
	}
	getNickName() {
		const nickname = RtcPlugin.getNickName();
	}
	setNickName() {
		RtcPlugin.setNickName();
	}
	isUserInMeeting() {
		const isUserInMeet = RtcPlugin.isUserInMeeting();
	}
	createMeeting() {
		RtcPlugin.createMeeting();
	}
	// 进入会议
	enterMeeting(confId) {
		RtcPlugin.enterMeeting(confId);
	}
	destroyMeeting(meetID, cookie = '') {
		RtcPlugin.destroyMeeting(meetID, cookie);
	}
	// 离开会议
	exitMeeting() {
		RtcPlugin.exitMeeting();
	}
	// 打开麦克风
	openMic(userId) {
		RtcPlugin.openMic(userId);
	}
	// 关闭麦克风
	closeMic(userId) {
		RtcPlugin.closeMic(userId);
	}
	getAudioCfg() {
		const cfg = RtcPlugin.getAudioCfg();
		const res = {
			agc: !!cfg.agc,
			ans: !!cfg.ans,
			aec: !!cfg.aec,
			micName: isAndroid ? cfg._micName : cfg.micName,
			speakerName: isAndroid ? cfg._speakerName : cfg.speakerName
		};
		return res;
	}
	setAudioCfg(options) {
		const obj = {
			agc: options.agc,
			ans: options.ans,
			aec: options.aec
		};
		if (isAndroid) {
			obj._micName = options.micName;
			obj._speakerName = options.speakerName;
			obj.agc = options.agc;
			obj.ans = options.ans;
			obj.aec = options.aec
		}
		if (isIos) {
			obj.micName = options.micName;
			obj.speakerName = options.speakerName;
			obj.agc = Number(options.agc);
			obj.ans = Number(options.ans);
			obj.aec = Number(options.aec)
		}

		RtcPlugin.setAudioCfg(obj);
	}

	getAudioStatus() {
		const aStatus = RtcPlugin.getAudioStatus();
	}

	getMicVolume() {
		const volume = RtcPlugin.getMicVolume();
	}
	//获取声音是否从扬声器输出
	getSpeakerOut() {
		return RtcPlugin.getSpeakerOut();
	}
	//设置声音是否从扬声器输出
	setSpeakerOut(isSpeakerOut) {
		if (firstEnterMeeting) {
			firstOpenMic = isSpeakerOut;
		}
		return RtcPlugin.setSpeakerOut(isSpeakerOut);
	}

	getSpeakerVolume() {
		return RtcPlugin.getSpeakerVolume();
	}
	setSpeakerVolume(volume) {
		RtcPlugin.setSpeakerVolume(volume);
	}

	getSpeakerMute() {
		const isSpeakerMute = RtcPlugin.getSpeakerMute();
	}
	setSpeakerMute(isMute) {
		RtcPlugin.setSpeakerMute(isMute);
	}

	setAllAudioClose() {
		RtcPlugin.setAllAudioClose();
	}
	openVideo(userId) {
		RtcPlugin.openVideo(userId);
	}
	closeVideo(userId) {
		RtcPlugin.closeVideo(userId);
	}
	getVideoCfg() {
		return RtcPlugin.getVideoCfg();
	}
	setVideoCfg(options) {
		RtcPlugin.setVideoCfg(options);
	}
	getMyVideoPosition() {
		return devicePosition;
	}
	getVideoEffects() {
		return RtcPlugin.getVideoEffects();
	}
	setVideoEffects(option) {
		RtcPlugin.setVideoEffects(option);
	}
	getWatchableVideos() {
		const wvsJsonStr = RtcPlugin.getWatchableVideos();
	}

	getAllVideoInfo(userId) {
		return RtcPlugin.getAllVideoInfo(userId);
	}

	getDefaultVideo(userId) {
		return RtcPlugin.getDefaultVideo(userId);
	}
	setDefaultVideo(userID, videoID) {
		RtcPlugin.setDefaultVideo({
			userID,
			videoID,
		});
	}
	isScreenShareStarted() {
		return RtcPlugin.isScreenShareStarted();
	}
	getScreenShareCfg() {
		const cfg = RtcPlugin.getScreenShareCfg();
		const res = {};
		if (isIos) {
			res.maxFps = cfg.maxFPS;
			res.maxBps = cfg.maxKbps === -1 ? -1 : Math.floor(cfg.maxKbps / 1024);
		}
		if (isAndroid) {
			res.maxFps = cfg.maxFps;
			res.maxBps = cfg.maxBps;
		}
		return res;
	}
	setScreenShareCfg({ maxFps, maxBps }) {
		const obj = {};
		if (isIos) {
			obj.maxFPS = maxFps;
			obj.maxKbps = maxBps === -1 ? -1 : maxBps * 1024;
		}
		if (isAndroid) {
			obj.maxFps = maxFps;
			obj.maxBps = maxBps;
		}
		RtcPlugin.setScreenShareCfg(obj);
	}
	startScreenShare(options = { title: "通知标题文字", contentText: "通知内容" }) {
		RtcPlugin.startScreenShare(options);
	}
	stopScreenShare() {
		RtcPlugin.stopScreenShare();
	}
	startScreenMark() {
		RtcPlugin.startScreenMark();
	}
	stopScreenMark() {
		RtcPlugin.stopScreenMark();
	}
	getMediaCfg() {
		return RtcPlugin.getMediaCfg();
	}
	setMediaCfg(options) {
		RtcPlugin.setMediaCfg(options);
	}
	getMediaInfo(options) {
		return RtcPlugin.getMediaInfo(options);
	}
	getMediaVolume() {
		return RtcPlugin.getMediaVolume();
	}
	setMediaVolume(volume) {
		RtcPlugin.setMediaVolume(volume);
	}
	startPlayMedia(videoSrc, bLocPlay = 0) {
		RtcPlugin.startPlayMedia({
			videoSrc,
			bLocPlay,
		});
	}
	pausePlayMedia(pause) {
		RtcPlugin.pausePlayMedia(pause);
	}
	stopPlayMedia() {
		RtcPlugin.stopPlayMedia();
	}
	setMediaPlayPos(pos) {
		RtcPlugin.setMediaPlayPos(pos);
	}
	sendMeetingCustomMsg(text, cookie) {
		RtcPlugin.sendMeetingCustomMsg({
			text,
			cookie,
		});
	}
	getCloudMixerInfo(mixerId) {
		return RtcPlugin.getCloudMixerInfo(mixerId);
	}
	getAllCloudMixerInfo() {
		return RtcPlugin.getAllCloudMixerInfo();
	}
	createCloudMixer(cfg) {
		return RtcPlugin.createCloudMixer(cfg);
	}
	updateCloudMixerContent(mixerId, cfg) {
		return RtcPlugin.updateCloudMixerContent(mixerId, cfg);
	}
	destroyCloudMixer(mixerId) {
		RtcPlugin.destroyCloudMixer(mixerId);
	}
	createLocMixer(mixerID, mixerCfg, mixerContent) {
		return RtcPlugin.createLocMixer(mixerID, mixerCfg, mixerContent);
	}
	updateLocMixerContent(mixerID, mixerContent) {
		return RtcPlugin.updateLocMixerContent(mixerID, mixerContent);
	}
	destroyLocMixer(mixerID) {
		RtcPlugin.destroyLocMixer(mixerID);
	}
	setPicResource(resID, photo) {
		RtcPlugin.setPicResource(resID, photo);
	}
	getLocMixerState(mixerID) {
		return RtcPlugin.getLocMixerState(mixerID);
	}
	addLocMixerOutput(mixerID, mixerOutput) {
		return RtcPlugin.addLocMixerOutput(mixerID, mixerOutput);
	}
	rmLocMixerOutput(mixerID, nameOrUrls) {
		RtcPlugin.rmLocMixerOutput(mixerID, nameOrUrls);
	}
	getAllRecordFiles() {
		return RtcPlugin.getAllRecordFiles();
	}
	cancelUploadRecordFile(fileName) {
		RtcPlugin.cancelUploadRecordFile(fileName);
	}
	uploadRecordFile(fileName, svrPathFileName) {
		RtcPlugin.uploadRecordFile(fileName, svrPathFileName);
	}
	addFileToRecordMgr(fileName, filePath) {
		return RtcPlugin.addFileToRecordMgr(fileName, filePath);
	}
	removeFromFileMgr(fileName) {
		RtcPlugin.removeFromFileMgr(fileName);
	}
	// playbackRecordFile() {}
	// setMarkText() {}
	// removeMarkText() {}
	// getVideoMarkFile() {}
}