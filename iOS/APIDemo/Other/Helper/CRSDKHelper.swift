//
//  CRSDKHelper.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/7.
//

import Foundation

let APPIDKey = "APPIDKey"
let serverKey = "serverKey"
let APPSecretKey = "APPSecretKey"
let nicknameKey = "nicknameKey"
let datEncTypeKey = "datEncTypeKey"
let rsaPublicKey = "rsaPublicKey"

class CRSDKHelper {
    //单例
    static let shared = CRSDKHelper()
    
    var server: String?
    var APPID: String?
    var APPSecret: String?
    
    var nickname: String?
    var datEncType: String?
    var rsaPublicKey: String?
    
    init() {
        readInfo()
        
        guard let server = server, server.count > 0,
              let APPID = APPID, APPID.count > 0,
              let APPSecret = APPSecret, APPSecret.count > 0,
              let nickname = nickname, nickname.count > 0 else {
                  resetInfo()
                  return
              }
    }
    
    private
    
    func readInfo() {
        server = UserDefaults.standard.string(forKey: serverKey)
        APPID = UserDefaults.standard.string(forKey: APPIDKey)
        APPSecret = UserDefaults.standard.string(forKey: APPSecretKey)
        nickname = UserDefaults.standard.string(forKey: nicknameKey)
        datEncType = UserDefaults.standard.string(forKey: datEncTypeKey)
    }
    
    public
    
    func write(APPID: String? = "", APPSecret: String? = "", server: String, nickName: String, datEncType: String) {
        self.server = server
        if APPID?.isEmpty == false { self.APPID = APPID }
        if APPSecret?.isEmpty == false { self.APPSecret = APPSecret }
        self.nickname = nickName
        self.datEncType = datEncType
        
        UserDefaults.standard.setValue(server, forKey: serverKey)
        UserDefaults.standard.setValue(APPID, forKey: APPIDKey)
        UserDefaults.standard.setValue(APPSecret, forKey: APPSecretKey)
        UserDefaults.standard.setValue(nickName, forKey: nicknameKey)
        UserDefaults.standard.setValue(datEncType, forKey: datEncTypeKey)
    }
    
    func resetInfo() {
        let nickname = "iOS_" + String(arc4random_uniform(10000 - 1000) + 1000)
        
        write(APPID: nil, APPSecret: nil, server: "sdk.cloudroom.com", nickName: nickname, datEncType: "0")
        rsaPublicKey = nil
        readInfo()
        
        APPID = KDefaultAppID
        APPSecret = KDefaultAppSecret
    }
}
