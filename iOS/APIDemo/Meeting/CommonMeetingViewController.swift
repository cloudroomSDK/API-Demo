//
//  CommomMeetingViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/7.
//

import UIKit
import AVFoundation

class CommonMeetingViewController: BaseViewController {
    
    var meetID: Int32?
    var feature: APIFeature?
    var cameraDivices: [UsrVideoInfo]?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.black
        
        guard let meetID = meetID else {
            return
        }

        self.navigationItem.title = "房间号: \(meetID)"
        CloudroomVideoMeeting.shareInstance().enter(meetID)
    }
    
    deinit {
        print("CommonMeetingViewController deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerCallback()
        CRSDKLogin.shared.isEnterMeeting = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeCallback()
        CRSDKLogin.shared.isEnterMeeting = false
        UIApplication.shared.isIdleTimerDisabled = false

    }
    
    // MARK: - Back Handler
    
    override func backToPrevious() {
        exitMeetingRoom()
    }

}

extension CommonMeetingViewController: CloudroomVideoMeetingCallBack, CloudroomVideoMgrCallBack  {
    
    func readCameraDivices() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        cameraDivices = (cloudroomVideoMeeting?.getAllVideoInfo(myUserId())) as? [UsrVideoInfo]
    }
    
    func setupDefaultCamera() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let currentVideo = cloudroomVideoMeeting?.getDefaultVideo(myUserId())
        if let item = cameraDivices?[1], item.videoID != currentVideo {
            cloudroomVideoMeeting?.setDefaultVideo(item.userId, videoID: item.videoID)
        }
    }
    
    func exchangeCamera() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let currentVideo = cloudroomVideoMeeting?.getDefaultVideo(myUserId())
        
        guard let cameraDivices = cameraDivices, cameraDivices.count > 0 else {return}
        
        for item in cameraDivices {
            if item.videoID != currentVideo {
                cloudroomVideoMeeting?.setDefaultVideo(item.userId, videoID: item.videoID)
            }
        }
    }
    
    func registerCallback() {
        CloudroomVideoMeeting.shareInstance().registerCallback(self)
        CloudroomVideoMgr.shareInstance().registerCallback(self)
    }
    
    func removeCallback() {
        CloudroomVideoMeeting.shareInstance().remove(self)
        CloudroomVideoMgr.shareInstance().removeCallback(self)
    }
    
    func myTermID() -> Int16 {
        return CloudroomVideoMeeting.shareInstance().getMyTermID()
    }
    
    func myUserId() -> String {
        return CloudroomVideoMeeting.shareInstance().getMyUserID()
    }
    
    func openCamera() {
        CloudroomVideoMeeting.shareInstance().openVideo(myUserId())
    }
    
    func openMicrophone() {
        CloudroomVideoMeeting.shareInstance().openMic(myUserId())
    }
    
    func joinMeetingFail(code: CRVIDEOSDK_ERR_DEF) {
        
        var errorMsg: String?
        switch code {
        case CRVIDEOSDK_MEETNOTEXIST:
            errorMsg = "会议不存在或已结束!"
            break
            
        case CRVIDEOSDK_MEETROOMLOCKED:
            errorMsg = "房间已加锁!"
            break
            
        default:
            errorMsg = "进入房间失败!"
        }
        
        let title = errorMsg! + ":\(code.rawValue)"
        
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            CloudroomVideoMeeting.shareInstance().exitMeeting()
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func exitMeetingRoom() {
        CloudroomVideoMeeting.shareInstance().exitMeeting()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - CloudroomVideoMeetingCallBack
    
    func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        guard code == CRVIDEOSDK_NOERR else {
            joinMeetingFail(code: code)
            return
        }
        readCameraDivices()
        openCamera()
        openMicrophone()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.setupDefaultCamera()
        }
        
        // 存储入会成功后的会议号(不用每次输入)
        UserDefaults.standard.setValue(String(meetID!), forKey: "KLastJoinMeetingIDKey")
    }
    
    func videoDevChanged(_ userID: String!) {
        readCameraDivices()
    }
    
    func meetingDropped(_ reason: CRVIDEOSDK_MEETING_DROPPED_REASON) {
        var errorMsg: String?
        switch reason {
        case CRVIDEOSDK_DROPPED_KICKOUT:
            errorMsg = "您已被请出会议!"
            break
        case CRVIDEOSDK_DROPPED_BALANCELESS:
            errorMsg = "余额不足!"
            break
        default:
            errorMsg = "您已掉线!"
            break
        }
        
        let alert = UIAlertController.init(title: errorMsg, message: nil, preferredStyle: .alert)
        
        let action1 = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            self.checkTimerValid()
            CloudroomVideoMeeting.shareInstance().exitMeeting()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(action1)
        
        self.present(alert, animated: true, completion: nil)
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoExitHandler), userInfo: nil, repeats: false)
    }
    
    func lineOff(_ sdkErr: CRVIDEOSDK_ERR_DEF) {
        var errorMsg: String?
        switch sdkErr {
        case CRVIDEOSDK_KICKOUT_BY_RELOGIN:
            errorMsg = "您的帐号在别处被使用!"
            break
        default:
            errorMsg = "您已掉线!"
            break
        }
        
        let alert = UIAlertController.init(title: errorMsg, message: nil, preferredStyle: .alert)
        
        let action1 = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            self.checkTimerValid()
            CloudroomVideoMeeting.shareInstance().exitMeeting()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(action1)
        
        self.present(alert, animated: true, completion: nil)
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoExitHandler), userInfo: nil, repeats: false)
    }
    
    func checkTimerValid() {
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func autoExitHandler() {
        self.dismiss(animated: true, completion: nil)
        timer?.invalidate()
        timer = nil
        CloudroomVideoMeeting.shareInstance().exitMeeting()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
