import RTCSDK from '@/SDK'
RTCSDK.LoginSuccess.callback = (UID, cookie) => {
  const { resolve, nickName } = cookie
  resolve({
    UID,
    nickName
  })
}

RTCSDK.LoginFail.callback = (errCode, cookie) => {
  const { reject } = cookie
  reject(errCode)
}

export const SDKInit = {
  isInit: false,
  init() {
    if (this.isInit) {
      return Promise.resolve()
    }
    return RTCSDK.Init({
      permissionRequirement: false,
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
  // 密码登录
  Login({ AppId, MD5_AppSecret, UID, nickName }) {
    return new Promise((resolve, reject) => {
      RTCSDK.Login2(
        {
          appID: AppId,
          appSecret: MD5_AppSecret,
          userID: UID,
          isDemo: true
        },
        {
          AppId,
          MD5_AppSecret,
          nickName,
          resolve,
          reject
        }
      )
    })
  },
  // Token登录
  LoginByToken({ token, userAuthCode }) {
    return new Promise((resolve, reject) => {
      RTCSDK.LoginByToken2(token, userAuthCode, {
        resolve,
        reject
      })
    })
  },
  // 登录
  Logout() {
    RTCSDK.Logout()
  }
}
