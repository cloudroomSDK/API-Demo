//
//  MixerRecordViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class MixerRecordViewController: VideoWallViewController {

    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var recordButton: CRCornerButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.bringSubviewToFront(helpView)
    }
    
    override func backToPrevious() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let svrState = cloudroomVideoMeeting.getSvrRecordState()
        guard svrState != MIXER_STATE.NO_RECORD, recordButton.currentTitle == "结束录制" else {
            super.backToPrevious()
            return
        }
        
        
        let alert = UIAlertController.init(title: "退出房间", message: "您正在进行云端录制，退出房间将结束云端录制", preferredStyle: .alert)
        
        let okay = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction in
            cloudroomVideoMeeting.stopSvrMixer()
            cloudroomVideoMeeting.exitMeeting()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction.init(title: "取消", style: .default) { UIAlertAction in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(okay)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        
        guard code == CRVIDEOSDK_NOERR else { return }
        
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let svrState = cloudroomVideoMeeting.getSvrRecordState()
        guard svrState != MIXER_STATE.NO_RECORD else {
            return
        }
        
        recordButton.isEnabled = false
        recordButton.backgroundColor = UIColor.init("F0F0F0")
    }
    
    @IBAction func recordAction(_ sender: Any) {

        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let svrState = cloudroomVideoMeeting.getSvrRecordState()
        
        
        
        guard let title = recordButton.currentTitle, title == "开始录制", svrState == MIXER_STATE.NO_RECORD else {
            cloudroomVideoMeeting.stopSvrMixer()
            recordButton.setTitle("开始录制", for: .normal)
            recordButton.backgroundColor = UIColor.init("3981FC")
            return
        }
        
        let cfgDic = NSMutableDictionary()
        cfgDic.setValue(mixerCfg(), forKey: "1")
        
        let contentDic = NSMutableDictionary()
        contentDic.setValue(videoMixerContent(), forKey: "1")
        
        let outputDic = NSMutableDictionary()
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let fileName = "record_\(timeStamp).mp4"
        let outputCfgs = NSMutableArray()
        let outputCfg = OutputCfg()
        outputCfg.type = OUT_TYPE.FILE
        outputCfg.serverPathFileName = fileName
        outputCfg.isUploadOnRecording = true
        outputCfg.fileName = "/" + curDirName() + "/" + curFileName() + "_iOS_" + "\(meetID ?? 0)" + ".mp4"
        outputCfgs.add(outputCfg)
        let output = MixerOutput()
        output.outputs = outputCfgs
        outputDic.setValue(output, forKey: "1")
        
        let rslt = cloudroomVideoMeeting.startSvrMixer(cfgDic, contents: contentDic, outputs: outputDic)
        if rslt != CRVIDEOSDK_NOERR {
            print("[svrRecord]  开启云端录制失败 \(rslt.rawValue)")
        }
        recordButton.setTitle("结束录制", for: .normal)
        recordButton.backgroundColor = UIColor.init("F44E4E")
    }
    
    // 重写视频变化函数更新录制内容（订阅观看了什么录制什么）
    override func updateVideoWall() {
        super.updateVideoWall()
        
        let contentDic = NSMutableDictionary()
        contentDic.setValue(videoMixerContent(), forKey: "1")
        CloudroomVideoMeeting.shareInstance().updateSvrMixerContent(contentDic)
    }
    
    //  云端录制状态改变 新接口
    func svrMixerStateChanged(_ state: MIXER_STATE, err sdkErr: CRVIDEOSDK_ERR_DEF, opratorID: String!) {
        guard sdkErr == CRVIDEOSDK_NOERR, opratorID != myUserId() else { return }
        
        if state == MIXER_STATE.NO_RECORD {
            recordButton.isEnabled = true
            recordButton.backgroundColor = UIColor.init("3981FC")
        }
        
        if state == MIXER_STATE.RECORDING {
            recordButton.isEnabled = false
            recordButton.backgroundColor = UIColor.init("F44E4E")
        }
    }
    
    func startSvrMixerFailed(_ sdkErr: CRVIDEOSDK_ERR_DEF) {
        recordButton.setTitle("开始录制", for: .normal)
        recordButton.backgroundColor = UIColor.init("3981FC")
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
