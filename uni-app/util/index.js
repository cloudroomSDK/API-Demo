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