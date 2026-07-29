import { defaultServer, defaultAppID, defaultAppSecret } from './auth.js';
let config = uni.getStorageSync('config') || {
	server: defaultServer,
	appId: defaultAppID,
	appSecret: defaultAppSecret,
	useToken: false,
	token: "",
	auth: "",
};

export const changeConfig = (newConfig) => {
	Object.assign(config, newConfig);
	uni.setStorage({
		key: 'config',
		data: config
	});
}

export const resetConfig = () => {
	config = {
		server: defaultServer,
		appId: defaultAppID,
		appSecret: defaultAppSecret,
		useToken: false,
		token: "",
		auth: "",
	};
	uni.removeStorage({
		key: 'config',
	})
	return config;
};
export const getConfig = () => config;

const createInfo = () => {
	const t = parseInt(Math.random() * 9000 + 1000); //4位随机数
	const userInfo = {
		userID: `wx_${t}`,
		nickname: `微信用户_${t}`,
	}
	uni.setStorage({
		key: 'userInfo',
		data: userInfo
	});

	return userInfo;
}

const userInfo = uni.getStorageSync('userInfo') || createInfo();

export const getUserInfo = () => userInfo;

export const getLastRoomId = () => uni.getStorageSync('lastRoomId') || '';
export const setLastRoomId = (roomId) => uni.setStorage({
	key: 'lastRoomId',
	data: roomId
});