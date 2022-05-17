//
//  CRSDKLogin.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/7.
//

import Foundation

typealias loginCallback = (_ success: Bool) ->()

class CRSDKLogin: NSObject, CloudroomVideoMgrCallBack {
    //单例
    static let shared = CRSDKLogin()
    var completionHandler: loginCallback?
    var isEnterMeeting: Bool?
    
    override init() {
        super.init()
        CloudroomVideoMgr.shareInstance().registerCallback(self)
    }
    
    func loginSDK(callback: @escaping loginCallback) {
        completionHandler = callback
        let helper = CRSDKHelper.shared
        
        guard let nickname = helper.nickname, nickname.count > 0 else {
            UIApplication.rootViewControllerView().makeToast("昵称为空")
            return
        }
        guard let server = helper.server, server.count > 0 else {
            UIApplication.rootViewControllerView().makeToast("服务器地址为空")
            return
        }
        guard let appID = helper.APPID, appID.count > 0 else {
            UIApplication.rootViewControllerView().makeToast("appID为空")
            return
        }
        guard let appSecret = helper.APPSecret?.md5, appSecret.count > 0 else {
            UIApplication.rootViewControllerView().makeToast("appSecret为空")
            return
        }
        
        CloudroomVideoSDK.shareInstance().setServerAddr(server)
        
        CloudroomVideoMgr.shareInstance().login(appID, appSecret: appSecret, nickName: nickname, userID: nickname, userAuthCode: "", cookie: "")
    }
    
    // MARK: - CloudroomVideoMgrCallBack
    
    func loginSuccess(_ usrID: String!, cookie: String!) {
//        UIApplication.rootViewControllerView().makeToast("登录成功")
        guard let completionHandler = completionHandler else { return }
        completionHandler(true)
    }
    
    func loginFail(_ sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String!) {
        let error = "登录失败: \(sdkErr.rawValue)"
        print(error)
        UIApplication.rootViewControllerView().hideToast()
        UIApplication.rootViewControllerView().makeToast(error)
        
        guard let completionHandler = completionHandler else { return }
        completionHandler(false)
    }
    
    func lineOff(_ sdkErr: CRVIDEOSDK_ERR_DEF) {
        guard isEnterMeeting == false else {
            return
        }
        
        var title = "您已掉线"
        if sdkErr == CRVIDEOSDK_KICKOUT_BY_RELOGIN {
            title = "您的帐号在别处被使用!"
        }
        
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)

        let okay = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            
        }
        
        alert.addAction(okay)
        
        UIApplication.rootViewController().present(alert, animated: true, completion: nil)
        
        
    }
}
