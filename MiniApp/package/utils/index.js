/**
 * Parse the time to string
 * @param {(Object|string|number)} time
 * @param {string} cFormat
 * @returns {string | null}
 */
export const parseTime = (time, cFormat) => {
	if (arguments.length === 0 || !time) {
		return null;
	}
	const format = cFormat || "YYYY/MM/DD HH:mm:ss";
	let date;
	if (typeof time === "object") {
		date = time;
	} else {
		if (typeof time === "string") {
			if (/^[0-9]+$/.test(time)) {
				// support "1548221490638"
				time = parseInt(time);
			} else {
				// support safari
				// https://stackoverflow.com/questions/4310953/invalid-date-in-safari
				time = time.replace(new RegExp(/-/gm), "/");
			}
		}

		if (typeof time === "number" && time.toString().length === 10) {
			time = time * 1000;
		}
		date = new Date(time);
	}
	const formatObj = {
		Y: date.getFullYear(),
		M: date.getMonth() + 1,
		D: date.getDate(),
		H: date.getHours(),
		m: date.getMinutes(),
		s: date.getSeconds(),
		d: date.getDay(),
	};

	const time_str = format.replace(/([YMDHmsd])+/g, (result, key) => {
		const value = formatObj[key].toString();
		// Note: getDay() returns 0 on Sunday
		if (key === "d") {
			return ["日", "一", "二", "三", "四", "五", "六"][value];
		}

		const resultLen = result.length;

		return (new Array(resultLen + 1).join("0") + value).slice(-resultLen);
	});
	return time_str;
}