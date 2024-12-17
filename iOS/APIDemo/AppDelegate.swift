//
//  AppDelegate.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/6.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window?.backgroundColor = UIColor.white
        setupForVideoCallSDK()
        setToastStyle()
        configDLProgressHud()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CloudroomVideoSDK.shareInstance().uninit()
    }
    
}

// MARK: - Configuration

extension AppDelegate {
    
    func setupForVideoCallSDK() {
        
        if CloudroomVideoSDK.shareInstance().isInitSuccess() {
            CloudroomVideoSDK.shareInstance().uninit()
        }
        
        // 准备路径
        let sdkPath = SDKPath()
        
        let sdkInitData:SdkInitDat = SdkInitDat()
        sdkInitData.sdkDatSavePath = sdkPath
        sdkInitData.showSDKLogConsole = true
        
        let dataEncTypeInt = Int(CRSDKHelper.shared.datEncType ?? "0")
        sdkInitData.datEncType = dataEncTypeInt! >= 1 ? "1" : "0"
        if dataEncTypeInt == 1 {
            sdkInitData.params.setValue("1", forKey: "VerifyHttpsCert")
        } else {
            sdkInitData.params.setValue("0", forKey: "VerifyHttpsCert")
        }
        
       let rsaPublicKey = CRSDKHelper.shared.rsaPublicKey
        if ((rsaPublicKey != nil) && rsaPublicKey!.count > 0) {
            sdkInitData.params.setValue("1", forKey: "HttpDataEncrypt")
            sdkInitData.params.setValue(rsaPublicKey, forKey: "RsaPublicKey")
        } else {
            sdkInitData.params.setValue("0", forKey: "HttpDataEncrypt")
        }
        
        let error = CloudroomVideoSDK.shareInstance().initSDK(sdkInitData)
        guard error == CRVIDEOSDK_NOERR else {
            print("CloudroomVideoSDK init error!")
            CloudroomVideoSDK.shareInstance().uninit()
            return
        }
        
        let SDKVer = CloudroomVideoSDK.getVer()
        print("GetCloudroomVideoSDKVer:" + SDKVer!)
    }
    
    
    func setToastStyle() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .center
    }
    
    func configDLProgressHud() {
        DLProgressHUD.defaultConfiguration.hudColor = UIColor.black.withAlphaComponent(0.9)
        DLProgressHUD.defaultConfiguration.activityIndicatorColor = UIColor.white
    }
}



