/**
 * Created by PanJiaChen on 16/11/18.
 */

/**
 * Parse the time to string
 * @param {(Object|string|number)} time
 * @param {string} cFormat
 * @returns {string | null}
 */
export function parseTime(time, cFormat) {
  if (arguments.length === 0 || !time) {
    return null
  }
  const format = cFormat || 'YYYY/MM/DD HH:mm:ss'
  let date
  if (typeof time === 'object') {
    date = time
  } else {
    if (typeof time === 'string') {
      if (/^[0-9]+$/.test(time)) {
        // support "1548221490638"
        time = parseInt(time)
      } else {
        // support safari
        // https://stackoverflow.com/questions/4310953/invalid-date-in-safari
        time = time.replace(new RegExp(/-/gm), '/')
      }
    }

    if (typeof time === 'number' && time.toString().length === 10) {
      time = time * 1000
    }
    date = new Date(time)
  }
  const formatObj = {
    Y: date.getFullYear(),
    M: date.getMonth() + 1,
    D: date.getDate(),
    H: date.getHours(),
    m: date.getMinutes(),
    s: date.getSeconds(),
    d: date.getDay()
  }

  const time_str = format.replace(/([YMDHmsd])+/g, (result, key) => {
    const value = formatObj[key].toString()
    // Note: getDay() returns 0 on Sunday
    if (key === 'd') {
      return ['日', '一', '二', '三', '四', '五', '六'][value]
    }

    const resultLen = result.length

    return (new Array(resultLen + 1).join('0') + value).slice(-resultLen)
  })
  return time_str
}

/**
 * @param {number} time
 * @param {string} option
 * @returns {string}
 */
export function formatTime(time, option) {
  if (('' + time).length === 10) {
    time = parseInt(time) * 1000
  } else {
    time = +time
  }
  const d = new Date(time)
  const now = Date.now()

  const diff = (now - d) / 1000

  if (diff < 30) {
    return '刚刚'
  } else if (diff < 3600) {
    // less 1 hour
    return Math.ceil(diff / 60) + '分钟前'
  } else if (diff < 3600 * 24) {
    return Math.ceil(diff / 3600) + '小时前'
  } else if (diff < 3600 * 24 * 2) {
    return '1天前'
  }
  if (option) {
    return parseTime(time, option)
  } else {
    return (
      d.getMonth() +
      1 +
      '月' +
      d.getDate() +
      '日' +
      d.getHours() +
      '时' +
      d.getMinutes() +
      '分'
    )
  }
}

/**
 * @param {string} url
 * @returns {Object}
 */
export function param2Obj(url) {
  const search = decodeURIComponent(url.split('?')[1]).replace(/\+/g, ' ')
  if (!search) {
    return {}
  }
  const obj = {}
  const searchArr = search.split('&')
  searchArr.forEach((v) => {
    const index = v.indexOf('=')
    if (index !== -1) {
      const name = v.substring(0, index)
      const val = v.substring(index + 1, v.length)
      obj[name] = val
    }
  })
  return obj
}

/**
 * @param {Number} length
 * @returns {Number}
 */
export function randomNumber(length) {
  var t = Math.pow(10, length - 1)
  return parseInt(Math.random() * 9 * t) + t
}

/** difference：寻找差异（并返回第一个数组独有的）
 * @param {Array} a
 * @param {Array} b
 * @returns {Array} 第一个数组独有的值
 */
export const difference = (a, b) => {
  const s = new Set(b)
  return a.filter((x) => !s.has(x))
}

export const jsonp = function(options) {
  const { url, data = {}, jsonp = 'callback', success, fail } = options
  // 拼接data，如果有的话

  const body = document.getElementsByTagName('body')[0]
  const jsonName = 'CRjsonp_' + new Date().getTime()

  // 如果data有内容
  let dataStr = ''

  for (const k in data) {
    dataStr += '&' + encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }

  const script = document.createElement('script')
  script.src = `${url}?${jsonp}=${jsonName}${dataStr}`
  body.appendChild(script)
  window[jsonName] = function() {
    success && success.apply(this, arguments)
    body.removeChild(script)
    window[jsonName] = null
    delete window[jsonName]
  }
  script.onerror = function() {
    console.error('jsonp request fail!url:' + url)
    fail && fail.apply(this, arguments)
    body.removeChild(script)
    window[jsonName] = null
    delete window[jsonName]
  }
}
