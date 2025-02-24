import Observer from "./observer.js";

const RtcPlugin = uni.requireNativePlugin("rtcsdk-plugin");
const globalEvent = uni.requireNativePlugin("globalEvent");
const version = "1.2.8";
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
	if (['micEnergyUpdate', 'notifyAudioPCMData'].indexOf(data.method) == -1) {
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
	getRTCSDKVer() {
		return RtcPlugin.GetRTCSDKVer();
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
	login({ appId, appSecret, token, nickName, userId, userAuthCode }, cookie) {
		if (token) {
			RtcPlugin.loginByToken(token, nickName, userId, userAuthCode, cookie)
		} else {
			const obj = {
				token: token,
				nickName: nickName,
				privAcnt: userId,
				authAcnt: appId,
				authPswd: appSecret,
				privAuthCode: userAuthCode
			}
			RtcPlugin.login(obj, cookie);
		}
	}
	//更新token
	updateToken(token) {
		RtcPlugin.updateToken(token);
	}
	//注销
	logout() {
		RtcPlugin.logout();
	}
	//获取第三方鉴权失败码
	getUserAuthErrCode() {
		return RtcPlugin.getUserAuthErrCode();
	}
	//获取第三方鉴权失败描述
	getUserAuthErrDesc() {
		return RtcPlugin.getUserAuthErrDesc();
	}
	setDNDStatus(DNDStatus, cookie) {
		RtcPlugin.setDNDStatus(DNDStatus, cookie);
	}
	//获取用户状态
	getUserStatus(userID = '', cookie) {
		RtcPlugin.getUserStatus(userID, cookie);
	}
	//开启用户的状态推送
	startUserStatusNotify(cookie) {
		RtcPlugin.startUserStatusNotify(cookie);
	}
	//关闭用户的状态推送
	stopUserStatusNotify(cookie) {
		RtcPlugin.stopUserStatusNotify(cookie);
	}
	//发送点对点消息
	sendCmd(targetUserId, data) {
		return RtcPlugin.sendCmd(targetUserId, data);
	}
	//发送点对点大数据
	sendBuffer(targetUserId, data) {
		return RtcPlugin.sendBuffer(targetUserId, data);
	}
	//发送点对点文件
	sendFile(targetUserId, fileName) {
		return RtcPlugin.sendFile(targetUserId, fileName);
	}
	//取消大数据、文件的发送
	cancelSend(taskID) {
		RtcPlugin.cancelSend(taskID);
	}
	//发起呼叫
	call(calledUserID, ID, userExtDat, cookie) {
		return RtcPlugin.call(calledUserID, ID, userExtDat, cookie);
	}
	//接受他人的呼叫
	acceptCall(callID, ID, usrExtDat, cookie) {
		RtcPlugin.acceptCall(callID, ID, usrExtDat, cookie);
	}
	//拒接他人的呼叫
	rejectCall(callID, usrExtDat, cookie) {
		RtcPlugin.rejectCall(callID, usrExtDat, cookie);
	}
	//挂断通话
	hangupCall(callID, usrExtDat, cookie) {
		RtcPlugin.hangupCall(callID, usrExtDat, cookie);
	}
	//发起多方呼叫（或呼转）
	callMoreParty(calledUserID, ID, usrExtDat, cookie) {
		return RtcPlugin.callMoreParty(calledUserID, ID, usrExtDat, cookie);
	}
	//取消多方呼叫
	cancelCallMoreParty(callID, usrExtDat, cookie) {
		RtcPlugin.cancelCallMoreParty(callID, usrExtDat, cookie);
	}

	//发送邀请
	invite(invitedUserID, usrExtDat, cookie) {
		return RtcPlugin.invite(invitedUserID, usrExtDat, cookie);
	}
	//接受邀请
	acceptInvite(inviteID, usrExtDat, cookie) {
		RtcPlugin.acceptInvite(inviteID, usrExtDat, cookie);
	}
	//拒接邀请
	rejectInvite(inviteID, usrExtDat, cookie) {
		RtcPlugin.rejectInvite(inviteID, usrExtDat, cookie);
	}
	//取消邀请
	cancelInvite(inviteID, usrExtDat, cookie) {
		RtcPlugin.cancelInvite(inviteID, usrExtDat, cookie);
	}

	//初始化用户队列功能数据
	initQueue(cookie) {
		RtcPlugin.initQueue(cookie);
	}
	//获取AppID下的所有队列基础信息
	getAllQueueInfo() {
		return RtcPlugin.getAllQueueInfo();
	}
	//获取指定队列的排队状况
	getQueueStatus(queID) {
		return RtcPlugin.getQueueStatus(queID);
	}
	//获取我的排队信息
	getQueuingInfo() {
		return RtcPlugin.getQueuingInfo();
	}
	//获取我服务的所有队列
	getServiceQueues() {
		return RtcPlugin.getServiceQueues();
	}
	//获取我的会话信息
	getSessionInfo() {
		return RtcPlugin.getSessionInfo();
	}
	//客户开始排队
	startQueuing(queID, usrExtDat, cookie) {
		RtcPlugin.startQueuing(queID, usrExtDat, cookie);
	}
	//客户停止排队
	stopQueuing(cookie) {
		RtcPlugin.stopQueuing(cookie);
	}
	//座席开始服务某队列
	startService(queID, priority, cookie) {
		RtcPlugin.startService(queID, priority, cookie);
	}
	//座席停止服务某队列
	stopService(queID, cookie) {
		RtcPlugin.stopService(queID, cookie);
	}
	//座席手动分配客户
	reqAssignUser(cookie) {
		RtcPlugin.reqAssignUser(cookie);
	}
	//接受系统自动分配的客户
	acceptAssignUser(queID, userID, cookie) {
		RtcPlugin.acceptAssignUser(queID, userID, cookie);
	}
	//拒绝系统自动分配的客户
	rejectAssignUser(queID, userID, cookie) {
		RtcPlugin.rejectAssignUser(queID, userID, cookie);
	}

	getMyUserID() {
		return RtcPlugin.getMyUserID();
	}
	//获取房间内所有成员信息
	getAllMembers() {
		return RtcPlugin.getAllMembers();
	}
	getMemberInfo(userID) {
		return RtcPlugin.getMemberInfo(userID);
	}
	setNickName(userID, nickName) {
		RtcPlugin.setNickName(userID, nickName);
	}
	isUserInMeeting() {
		const isUserInMeet = RtcPlugin.isUserInMeeting();
	}
	createMeeting(cookie) {
		RtcPlugin.createMeeting(cookie);
	}
	// 进入会议
	enterMeeting(ID) {
		RtcPlugin.enterMeeting(ID);
	}
	//销毁房间
	destroyMeeting(meetID, cookie) {
		RtcPlugin.destroyMeeting(meetID, cookie);
	}
	//离开会议
	exitMeeting() {
		RtcPlugin.exitMeeting();
	}
	//把某个成员踢出房间
	kickout(userID) {
		RtcPlugin.kickout(userID);
	}
	//打开麦克风
	openMic(userID) {
		RtcPlugin.openMic(userID);
	}
	//关闭麦克风
	closeMic(userID) {
		RtcPlugin.closeMic(userID);
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

	// 开始获取语音pcm数据
	startGetAudioPCM(aSide, getType, jsonParam) {
		RtcPlugin.startGetAudioPCM(aSide, getType, jsonParam);
	}
	// 停止获取语音pcm数据
	stopGetAudioPCM(aSide) {
		RtcPlugin.stopGetAudioPCM(aSide);
	}

	openVideo(userID) {
		RtcPlugin.openVideo(userID);
	}
	closeVideo(userID) {
		RtcPlugin.closeVideo(userID);
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
	// 设置某个摄像头私有参数
	setLocVideoAttributes(videoID, attributes) {
		RtcPlugin.setLocVideoAttributes(videoID, attributes);
	}
	// 获取某个摄像头私有参数
	getLocVideoAttributes(videoID) {
		return RtcPlugin.getLocVideoAttributes(videoID);
	}
	//获取房间内所有可观看的摄像头
	getWatchableVideos() {
		return RtcPlugin.getWatchableVideos();
	}
	//获取用户所有的摄像头信息
	getAllVideoInfo(userID) {
		return RtcPlugin.getAllVideoInfo(userID);
	}
	//获取指定用户的默认摄像头 ，如果用户没有摄像头，返回0
	getDefaultVideo(userID) {
		return RtcPlugin.getDefaultVideo(userID);
	}
	//设置默认的摄像头 ，videoID 应该从getAllVideoInfo返回值中获取
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
	getMediaInfo() {
		return RtcPlugin.getMediaInfo();
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
		RtcPlugin.sendMeetingCustomMsg(text, cookie);
	}
	//获取房间所有属性
	getMeetingAllAttrs(cookie) {
		RtcPlugin.getMeetingAllAttrs(cookie);
	}
	//获取房间部份属性
	getMeetingAttrs(keys, cookie) {
		RtcPlugin.getMeetingAttrs(keys, cookie);
	}
	//重置房间属性
	setMeetingAttrs(attrs, options, cookie) {
		RtcPlugin.setMeetingAttrs(attrs, options, cookie);
	}
	//增加或者更新房间属性
	addOrUpdateMeetingAttrs(attrs, options, cookie) {
		RtcPlugin.addOrUpdateMeetingAttrs(attrs, options, cookie);
	}
	//删除特定房间属性
	delMeetingAttrs(keys, options, cookie) {
		RtcPlugin.delMeetingAttrs(keys, options, cookie);
	}
	//清除房间属性
	clearMeetingAttrs(options, cookie) {
		RtcPlugin.clearMeetingAttrs(options, cookie);
	}
	//获取指定用户的所有属性
	getUserAttrs(userIDs, keys = [], cookie) {
		RtcPlugin.getUserAttrs(userIDs, keys, cookie);
	}
	//重置指定用户的属性
	setUserAttrs(userID, attrs, options, cookie) {
		RtcPlugin.setUserAttrs(userID, attrs, options, cookie);
	}
	//添加或更新指定用户的属性
	addOrUpdateUserAttrs(userID, attrs, options, cookie) {
		RtcPlugin.addOrUpdateUserAttrs(userID, attrs, options, cookie);
	}
	//删除指定用户的属性
	delUserAttrs(userID, keys, options, cookie) {
		RtcPlugin.delUserAttrs(userID, keys, options, cookie);
	}
	//清空所有用户的属性
	clearAllUserAttrs(options, cookie) {
		RtcPlugin.clearAllUserAttrs(options, cookie);
	}
	//清空指定用户的属性
	clearUserAttrs(userID, options, cookie) {
		RtcPlugin.clearUserAttrs(userID, options, cookie);
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
}