//
//  SceenShareViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class ScreenShareViewController: CommonMeetingViewController {
    @IBOutlet weak var startShareButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBOutlet weak var meetIDLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var shareSizeLabel: UILabel!
    @IBOutlet weak var shareConfigView: UIView!
    @IBOutlet weak var shareView: CLShareView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        self.navigationItem.title = feature?.rawValue
        self.meetIDLabel.text = "\(meetID!)"
    }
    
    @IBAction func startShareAction(_ sender: Any) {
        if startShareButton.currentTitle == "开始屏幕共享" {
            
            let cfg = CloudroomVideoMeeting.shareInstance().getScreenShareCfg()
            cfg.maxFPS = 8
            CloudroomVideoMeeting.shareInstance().setScreenShareCfg(cfg)
            
            CloudroomVideoMeeting.shareInstance().startScreenShare()
        } else {
            CloudroomVideoMeeting.shareInstance().stopScreenShare()
        }
    }
    
    @IBAction func microphoneAction(_ sender: Any) {
        let userId = myUserId()
        let aStatus = CloudroomVideoMeeting.shareInstance().getAudioStatus(userId)
        if aStatus == AOPEN {
            CloudroomVideoMeeting.shareInstance().closeMic(userId)
        } else {
            CloudroomVideoMeeting.shareInstance().openMic(userId)
        }
    }
    
    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        guard code == CRVIDEOSDK_NOERR else { return }
        
        usernameLabel.text = CloudroomVideoMeeting.shareInstance().getNickName(myUserId())
    }
    
    func notifyScreenShareStarted() {
        shareView.clearFrame()
        self.view.bringSubviewToFront(self.shareView)
    }
    
    func notifyScreenShareStopped() {
        shareView.clearFrame()
        self.view.bringSubviewToFront(self.shareConfigView)
    }
    
    func startScreenShareRslt(_ sdkErr: CRVIDEOSDK_ERR_DEF) {
        if sdkErr == CRVIDEOSDK_NOERR {
            startShareButton.setTitle("停止屏幕共享", for: .normal)
            startShareButton.backgroundColor = UIColor.init("FF6969")
            usernameLabel.text = CloudroomVideoMeeting.shareInstance().getNickName(myUserId())
        } else {
            view.makeToast("开启屏幕共享失败")
        }
    }
    
    func stopScreenShareRslt(_ sdkErr: CRVIDEOSDK_ERR_DEF) {
        if sdkErr == CRVIDEOSDK_NOERR {
            startShareButton.setTitle("开始屏幕共享", for: .normal)
            startShareButton.backgroundColor = UIColor.init("3981FC")
        } else {
            view.makeToast("停止屏幕共享失败")
        }
    }
    
    func audioStatusChanged(_ userID: String!, oldStatus: AUDIO_STATUS, newStatus: AUDIO_STATUS) {
        guard userID == myUserId() else { return}
        
        let title = newStatus == AOPEN ? "关闭麦克风" : "打开麦克风"
        guard title != microphoneButton.currentTitle else {return}
        self.microphoneButton.setTitle(title, for: .normal)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
