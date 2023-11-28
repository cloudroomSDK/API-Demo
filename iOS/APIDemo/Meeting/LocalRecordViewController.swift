//
//  LocalRecordViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class LocalRecordViewController: VideoWallViewController {

    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var recordButton: CRCornerButton!
    @IBOutlet weak var helpViewBottomCons: NSLayoutConstraint!
    
    var lastFileName: String?
    let mixerID = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        textField.text = curFileName() + ".mp4"
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.bringSubviewToFront(helpView)
    }
    
    @objc func keyboardFrameChanged(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let bottomCons = endFrame.origin.y < self.view.frame.size.height ? -endFrame.size.height + self.view.crSafeAreaInsets.bottom : 0;
        
        UIView.animate(withDuration: duration) {
            self.helpViewBottomCons.constant = bottomCons
        }
    }
    
    @IBAction func keyboardDown(_ sender: Any) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    override func backToPrevious() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        guard recordButton.currentTitle == "结束录制" else {
            super.backToPrevious()
            return
        }
        
        
        let alert = UIAlertController.init(title: "退出房间", message: "您正在进行本地录制，退出房间将结束云端录制", preferredStyle: .alert)
        
        let okay = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            cloudroomVideoMeeting.destroyLocMixer("1")
            cloudroomVideoMeeting.exitMeeting()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction.init(title: "取消", style: .default) { UIAlertAction in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(okay)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func recordAction(_ sender: Any) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        guard let title = recordButton.currentTitle, title == "开始录制" else {
            cloudroomVideoMeeting.destroyLocMixer("1")
            recordButton.setTitle("开始录制", for: .normal)
            recordButton.backgroundColor = UIColor.init("3981FC")
            return
        }
        
        
        var fileName = textField.text
        if fileName?.count == 0 || fileName == lastFileName {
            fileName = curFileName() + ".mp4"
            textField.text = fileName
        }
        lastFileName = fileName
        
        
        let cfg = mixerCfg()
        let recContent = videoMixerContent()
        let rslt = cloudroomVideoMeeting.createLocMixer(mixerID, cfg: cfg, content: recContent)
        guard rslt == CRVIDEOSDK_NOERR else {
            let error = "创建本地录制失败:\(rslt.rawValue ?? 0)"
            self.view.makeToast(error)
            print(error)
            return
        }
        
        let outputCfgs = NSMutableArray()
        let outputCfg = OutputCfg()
        outputCfg.fileName = SDKPath().appending("/\(fileName!)")
        outputCfgs.add(outputCfg)
        
        let mixerOutput = MixerOutput()
        mixerOutput.outputs = outputCfgs
        let rslt2 = cloudroomVideoMeeting.addLocMixer(mixerID, outputs: mixerOutput)
        guard rslt2 == CRVIDEOSDK_NOERR else {
            let error = "添加本地录制输出失败:\(rslt.rawValue ?? 0)"
            self.view.makeToast(error)
            print(error)
            return
        }
        recordButton.setTitle("结束录制", for: .normal)
        recordButton.backgroundColor = UIColor.init("F44E4E")
    }
    
    // 重写视频变化函数更新录制内容（订阅观看了什么录制什么）
    override func updateVideoWall() {
        super.updateVideoWall()
        
        CloudroomVideoMeeting.shareInstance().updateLocMixerContent(mixerID, content: videoMixerContent())
    }
    
    // 录制过程出错(导致录制停止)
    func recordErr(_ sdkErr: REC_ERR_TYPE) {
        
    }
    
    // 录制过程状态改变回调
    func locMixerStateChanged(_ mixerID: String!, state: MIXER_STATE) {
        
    }
    
    // 本地录制文件，本地直播信息通知
    func locMixerOutputInfo(_ mixerID: String!, nameUrl: String!, outputInfo: OutputInfo!) {
        
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
