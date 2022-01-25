import { randomNumber } from '@/utils/index'

CRVideo_LoginSuccess.callback = (UID, cookie) => {
  const { resolve, nickName } = cookie
  resolve({
    UID,
    nickName
  })
}

CRVideo_LoginFail.callback = (errCode, cookie) => {
  const { reject } = cookie
  reject(errCode)
}

export const SDKInit = {
  isInit: false,
  init() {
    if (this.isInit) {
      return Promise.resolve()
    }
    return CRVideo_Init({
      // isCallSer: false,
      isUploadLog: false
    })
      .then(() => {
        // 初始化成功
        this.isInit = true
      })
      .catch((err) => {
        this.isInit = true
        throw err
      })
  },
  // 登录
  Login({ AppId, MD5_AppSecret }) {
    return new Promise((resolve, reject) => {
      const UID = `H5_${randomNumber(4)}`
      const nickName = UID
      CRVideo_Login(AppId, MD5_AppSecret, nickName, UID, undefined, {
        AppId,
        MD5_AppSecret,
        nickName,
        resolve,
        reject
      })
    })
  },
  // 登录
  Logout() {
    CRVideo_Logout()
  }
}
