import RTCSDK from './CRSDK';
import { getDesc } from './sdkErrDesc.js';
import { getUserInfo, getLastRoomId } from '../store.js'

/**
 * 触发vue实例中callback_开头的函数
 * @param {string} callback SDK回调函数名
 * @param {boolean} isAllPage 是否触发所有页面栈，否则只触发当前页面
 * @param {Array} arg 回调函数参数
 */
const sendPage = (callback, isAllPage = true, arg) => {
	let allpage = getCurrentPages();

	if (!isAllPage) {
		allpage = [allpage[allpage.length - 1]];
	}

	allpage.forEach(page => {
		try {
			const fn = page.$vm['callback_' + callback];
			fn && fn(...arg)
		} catch (e) {
			//TODO handle the exception
			console.error(e);
		}
	});
}

// 批量注册回调函数
[
	'LoginSuccess',
	'LoginFail'
].forEach(key => {
	RTCSDK[key].callback = (...arg) => {
		sendPage(key, true, arg)
	}
});

// 批量注册回调函数
[
	'CreateMeetingSuccess',
	'CreateMeetingFail',
	"UserEnterMeeting",
	"UserLeftMeeting",
	"VideoStatusChanged",
	"AudioStatusChanged",
	"MicEnergyUpdate",
	"NotifyMeetingCustomMsg",
	"CloudMixerStateChanged",
	"CloudMixerOutputInfoChanged",
].forEach(key => {
	RTCSDK[key].callback = (...arg) => {
		sendPage(key, false, arg)
	}
});

// 房间结束通知
RTCSDK.MeetingStopped.callback = () => {
	uni.showModal({
		title: '提示',
		content: '当前房间已结束，请重新进入正在进行中的房间或创建新的房间！',
		showCancel: false,
		success(res) {
			uni.navigateBack();
		}
	});
}

//token即将失效通知
RTCSDK.NotifyTokenWillExpire.callback = () => {
	uni.showToast({
		title: 'token即将失效',
		icon: 'none',
		duration: 3000
	});
}

//SDK掉线通知
RTCSDK.LineOff.callback = (sdkErr) => {
	uni.showModal({
		title: '提示',
		content: `登录掉线,错误码: ${sdkErr},${getDesc(sdkErr)}`,
		showCancel: false,
		success(res) {
			uni.reLaunch({
				url: '/pages/index'
			})
		}
	});
}
// 房间掉线通知
RTCSDK.MeetingDropped.callback = () => {
	uni.showModal({
		title: '提示',
		content: '房间掉线，是否重新进入房间?',
		success(res) {
			if (res.confirm) {
				uni.showLoading({ title: '请稍后' });

				RTCSDK.EnterMeeting3(getLastRoomId());
			} else if (res.cancel) {
				uni.navigateBack();
			}
		}
	});
}
// 进入房间的结果通知
RTCSDK.EnterMeetingRslt.callback = (...arg) => {
	uni.hideLoading()
	sendPage('EnterMeetingRslt', false, arg)
}