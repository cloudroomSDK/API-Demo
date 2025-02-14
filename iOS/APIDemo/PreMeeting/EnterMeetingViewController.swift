//
//  EnterMeetingViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/7.
//

import UIKit

class EnterMeetingViewController: BaseViewController, CloudroomVideoMgrCallBack, CloudroomVideoMeetingCallBack {
    @IBOutlet weak var meetIDTextField: UITextField!
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var createMeetingButton: UIButton!
    @IBOutlet weak var remindLabel: UILabel!
    
    var featureTitle: String?
    
    let createMeet_cookie = "createMeet_cookie"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        meetIDTextField.text = UserDefaults.standard.string(forKey: "KLastJoinMeetingIDKey")
        
        CloudroomVideoMgr.shareInstance().registerCallback(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CloudroomVideoMgr.shareInstance().removeCallback(self)
    }
    
    func setupUI() {
        joinMeetingButton.layer.cornerRadius = 2.0
        joinMeetingButton.layer.masksToBounds = true
        
        createMeetingButton.layer.cornerRadius = 2.0
        createMeetingButton.layer.masksToBounds = true
        createMeetingButton.layer.borderColor = UIColor.blue.cgColor
        createMeetingButton.layer.borderWidth = 1.0
        
        self.navigationItem.title = featureTitle
        
        guard let featureTitle = featureTitle else {
            return
        }

        let currentFeature = APIFeature.init(rawValue: featureTitle)
        if currentFeature == .screenShare {
            self.remindLabel.text = "1、“进入房间”默认角色为“观看端”\n2、“创建房间”默认角色为“共享端”"
        }
        
    }
    
    func joinMeeting(meetID: Int32) {
        guard let featureTitle = featureTitle else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        var viewController: CommonMeetingViewController?

        let currentFeature = APIFeature.init(rawValue: featureTitle)
        switch currentFeature {
        case .voice:
            viewController = storyboard.instantiateViewController(withIdentifier: "VoiceViewController") as! VoiceCallViewController
            break
            
        case .video:
            viewController = storyboard.instantiateViewController(withIdentifier: "VideoCallViewController") as! VideoCallViewController
            break
            
        case .videoConfig:
            viewController = storyboard.instantiateViewController(withIdentifier: "VideoConfigViewController") as! VideoConfigViewController
            break
            
        case .screenShare:
            viewController = storyboard.instantiateViewController(withIdentifier: "ScreenShareViewController") as! ScreenShareViewController
            break
            
        case .localRecord:
            viewController = storyboard.instantiateViewController(withIdentifier: "LocalRecordViewController") as! LocalRecordViewController
            break
            
        case .mixerRecord:
            viewController = storyboard.instantiateViewController(withIdentifier: "MixerRecordViewController") as! MixerRecordViewController
            break
            
        case .playVideo:
            viewController = storyboard.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController
            break
                        
        case .chat:
            viewController = storyboard.instantiateViewController(withIdentifier: "IMViewController") as! IMViewController
            break
            
        case .beauty:
            viewController = storyboard.instantiateViewController(withIdentifier: "BeautyViewController") as! BeautyViewController
            break
            
        case .voiceChange:
            viewController = storyboard.instantiateViewController(withIdentifier: "VoiceChangeViewController") as! VoiceChangeViewController
            break
            
        default:
            break
        }
        
        guard let viewController = viewController else {
            return
        }
        
        viewController.feature = currentFeature
        viewController.meetID = meetID
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func enterMeetingAction(_ sender: Any) {
        if self.meetIDTextField.isFirstResponder {
            self.meetIDTextField.resignFirstResponder()
        }
        
        guard let text = meetIDTextField.text, text.count > 0 else {
            self.view.hideToast()
            self.view.makeToast("请输入会议号")
            return
        }
        
        CloudroomVideoMgr.shareInstance().logout()
        
        DLProgressHUD.show(in: self.view)
        CRSDKLogin.shared.loginSDK { [weak self] success in
            guard success else {
                DLProgressHUD.dismiss()
                return
            }
            
            DLProgressHUD.dismiss()
            let meetID = Int32(text) ?? 0
            self?.joinMeeting(meetID: meetID)
        }
    }
    
    @IBAction func createMeetingAction(_ sender: Any) {
        if self.meetIDTextField.isFirstResponder {
            self.meetIDTextField.resignFirstResponder()
        }
        
        CloudroomVideoMgr.shareInstance().logout()
        
        DLProgressHUD.show(in: self.view)
        CRSDKLogin.shared.loginSDK { [weak self] success in
            guard success else {
                DLProgressHUD.dismiss()
                return
            }
            
            CloudroomVideoMgr.shareInstance().createMeeting("iOS_APIDemo", createPswd: false, cookie: self?.createMeet_cookie)
        }
    }
    
    @IBAction func keyboardDown(_ sender: Any) {
        if self.meetIDTextField.isFirstResponder {
            self.meetIDTextField.resignFirstResponder()
        }
    }
    
    // MARK: - CloudroomVideoMgrCallBack
    
    func createMeetingSuccess(_ meetInfo: MeetInfo!, cookie: String!) {
        guard cookie == createMeet_cookie else {
            return
        }
        
        DLProgressHUD.dismiss()
        let meetID = meetInfo.id
        self.joinMeeting(meetID: meetID)
    }
    
    func createMeetingFail(_ sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String!) {
        guard cookie == createMeet_cookie else {
            return
        }
        DLProgressHUD.dismiss()
        self.view.hideToast()
        self.view.makeToast("创建会议失败: \(sdkErr.rawValue)")
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
