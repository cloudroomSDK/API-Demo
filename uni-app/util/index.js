export function showToast(title, duration) {
	uni.showToast({
		title,
		icon: 'none',
		duration: duration || 2000
	});
}

export function showLoading(title, mask = false) {
	uni.showLoading({
		title,
		mask
	})
}

export function hideLoading(title, duration) {
	uni.hideLoading()
}

export function createEnum(array) {
	const obj = {};
	for (let i = 0; i < array.length; i++) {
		obj[obj[array[i]] = i] = array[i];
	}
	return obj;
}

// 读取文件目录
export function readAppDir(type = plus.io.PUBLIC_DOCUMENTS) {
	return new Promise((resolve, reject) => {
		plus.io.requestFileSystem(type, function(fs) {
			resolve(fs.root.fullPath);
		}, function(e) {
			console.log("Request file system failed: " + e.message);
			reject(e)
		});
	})
}

// 时间格式化
export function formatTime(timeStr = null, fromatStr = 'YYYY/MM/DD hh:mm') {
	if (typeof timeStr === "number" && timeStr.toString().length === 10) {
		timeStr *= 1000;
	}
	let time = timeStr ? new Date(timeStr) : new Date()
	if (time === 'Invalid Date') return '传入每二个参数不是时间'
	let year = time.getFullYear();
	let month = time.getMonth() + 1;
	let day = time.getDate();
	let hours = time.getHours();
	let minutes = time.getMinutes();
	let milliseconds = time.getSeconds();
	let week = 0;
	if (/W/.test(newStr)) {
		week = (time.getTime() - new Date(year + '/1/1').getTime()) / 1000 / 60 / 60 / 24 / 7;
		week = parseInt(week);
	}

	let newStr = fromatStr;
	//正常处理,小于 10 补 0
	newStr = newStr.replace(/(YYYY)/, year)
	newStr = newStr.replace(/(MM)/, month < 10 ? '0' + month : month)
	newStr = newStr.replace(/(DD)/, day < 10 ? '0' + day : day)
	newStr = newStr.replace(/(hh)/, hours < 10 ? '0' + hours : hours)
	newStr = newStr.replace(/(mm)/, minutes < 10 ? '0' + minutes : minutes)
	newStr = newStr.replace(/(ss)/, milliseconds < 10 ? '0' + milliseconds : milliseconds)
	newStr = newStr.replace(/(WW)/, week < 10 ? '0' + week : week)
	// 不补零处理
	newStr = newStr.replace(/M/, month)
	newStr = newStr.replace(/D/, day)
	newStr = newStr.replace(/h/, hours)
	newStr = newStr.replace(/m/, minutes)
	newStr = newStr.replace(/s/, milliseconds)
	newStr = newStr.replace(/W/, week)
	return newStr;
}

/**
 * 打开弹窗参数说明
 * @param {string} title 提示标题，默认没内容就不显示
 * @param {string} titleColor 标题颜色，默认'#333'
 * @param {string} content 提示内容，默认无
 * @param {string} contentColor 内容颜色，默认'#333'
 * @param {string} confirmText 确认按钮内容，默认'确认'
 * @param {Boolean} showCancel 是否显示取消按钮，默认true
 * @param {string} cancelText 确认按钮内容，默认'取消'
 * @param {string} confirmColor 确认按钮颜色，默认'#3981FC'
 * @param {string} cancelColor 取消按钮颜色，默认'#333'
 * @param {Number} btnType 取消按钮颜色，默认1 1-左取消，右确认 2-与1相反
 * @param {Boolean} maskClick 是否允许点蒙层关闭，默认true
 * @param {Fnction} confirm 确认回调
 * @param {Fnction} cancel 取消回调
 */
export const openPopup = ({
	title,
	titleColor,
	content,
	contentColor,
	confirmText,
	showCancel,
	cancelText,
	confirmColor,
	cancelColor,
	btnType,
	maskClick,
	confirm,
	cancel
}) => {
	let data = {
		title,
		titleColor: titleColor ? titleColor : '#333',
		content,
		contentColor: contentColor ? contentColor : '#333',
		confirmText: confirmText ? confirmText : '确认',
		showCancel: showCancel == false ? showCancel : true,
		cancelText: cancelText ? cancelText : '取消',
		confirmColor: confirmColor ? confirmColor : '#3981FC',
		cancelColor: cancelColor ? cancelColor : '#333',
		btnType: btnType ? btnType : 1,
		maskClick: maskClick == false ? maskClick : true,
		confirm,
		cancel,
		random: new Date().getTime()
	};
	getApp().globalData.popupConfig = data;
	uni.navigateTo({
		url: `/components/popup`
	})
}

//关闭弹窗
export const closePopup = () => {
	const app = getApp()
	if (app.globalData.popupConfig) {
		app.globalData.popupConfig = null;
		uni.navigateBack();
	}
}