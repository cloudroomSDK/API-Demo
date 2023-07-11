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
	login(options) {
		RtcPlugin.login(options);
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
	destroyMeeting(meetID, cookie) {
		RtcPlugin.destroyMeeting({
			meetID,
			cookie,
		});
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
		const cfgJsonStr = RtcPlugin.getAudioCfg();
	}
	setAudioCfg(options) {
		RtcPlugin.setAudioCfg(options);
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
		RtcPlugin.setSpeakerOut(isSpeakerOut);
	}

	getSpeakerVolume() {
		const volume = RtcPlugin.getSpeakerVolume();
	}
	setSpeakerVolume(volume) {
		const isSetSpeakerVolumeSuccess = RtcPlugin.setSpeakerVolume(volume);
	}

	getSpeakerMute() {
		const isSpeakerMute = RtcPlugin.getSpeakerMute();
	}
	setSpeakerMute(isMute) {
		RtcPlugin.setSpeakerMute(isMute);
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
		return RtcPlugin.getScreenShareCfg();
	}
	setScreenShareCfg(options) {
		RtcPlugin.setScreenShareCfg(options);
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
	setMediaCfg() {
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
	startPlayMedia(videoSrc, bLocPlay) {
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