/**
 * Parse the time to string
 * @param {(Object|string|number)} time
 * @param {string} cFormat
 * @returns {string | null}
 */
export const parseTime = function (time: Date | number | string, format = "YYYY/MM/DD HH:mm:ss") {
    if (arguments.length === 0 || !time) {
        return null;
    }
    // const format = cFormat || "YYYY/MM/DD HH:mm:ss";
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
        // @ts-ignore
        const value = formatObj[key].toString();
        // Note: getDay() returns 0 on Sunday
        if (key === "d") {
            return ["日", "一", "二", "三", "四", "五", "六"][value];
        }

        const resultLen = result.length;

        return (new Array(resultLen + 1).join("0") + value).slice(-resultLen);
    });
    return time_str;
};

interface ThumbImageBuffer {
    _data: Uint8Array;
    _dataSize?: number;
    _width?: number;
    _height?: number;
}

// rgbaBuffer转base64
export const thumbImageBufferToBase64 = (target?: ThumbImageBuffer) => {
    if (!target || target._data.length === 0 || !target._height || !target._width) {
        return "";
    }
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    const width = (canvas.width = target._width);
    const height = (canvas.height = target._height);
    const imageData = ctx.createImageData(width, height);
    const length = target._data.length;
    for (let i = 0; i < length; i += 4) {
        imageData.data[i] = target._data[i + 2];
        imageData.data[i + 1] = target._data[i + 1];
        imageData.data[i + 2] = target._data[i];
        imageData.data[i + 3] = target._data[i + 3];
    }

    ctx.putImageData(imageData, 0, 0);
    return canvas.toDataURL("image/png");
};
