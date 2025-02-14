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
    private var mixerID: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.bringSubviewToFront(helpView)
    }
    
    override func backToPrevious() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        let info = cloudroomVideoMeeting.getCloudMixerInfo(mixerID)
        let myUserId = cloudroomVideoMeeting.getMyUserID()
        var svrState = MIXER_STATE.NO_RECORD
        if let jsonData = info.data(using: .utf8) {
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    if let owner = jsonDict["owner"] as? String, owner == myUserId, let state = jsonDict["state"] as? Int{
                        svrState = MIXER_STATE(rawValue: state) ?? .NO_RECORD
                    }
                }
            } catch {
                print("JSON serialization failed: \(error)")
            }
        }
        
        guard svrState != MIXER_STATE.NO_RECORD, recordButton.currentTitle == "结束录制" else {
            super.backToPrevious()
            return
        }
        
        
        let alert = UIAlertController.init(title: "退出房间", message: "您正在进行云端录制，退出房间将结束云端录制", preferredStyle: .alert)
        
        let okay = UIAlertAction.init(title: "确定", style: .default) { UIAlertAction  in
            cloudroomVideoMeeting.destroyCloudMixer(self.mixerID)
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
        
        checkLastCloudMixerInfo()
    }
    
    func checkLastCloudMixerInfo() {
        guard mixerID.isEmpty == true else {
            return
        }
        
        let info = CloudroomVideoMeeting.shareInstance().getAllCloudMixerInfo()
        let myUserId = CloudroomVideoMeeting.shareInstance().getMyUserID()
        if let jsonData = info.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                    // 遍历数组
                    for jsonDict in jsonArray {

                        if let owner = jsonDict["owner"] as? String, owner == myUserId, let state = jsonDict["state"] as? Int, MIXER_STATE(rawValue: state) == .RECORDING, let ID = jsonDict["ID"] as? String {
                            self.mixerID = ID
                            recordButton.setTitle("结束录制", for: .normal)
                            recordButton.backgroundColor = UIColor.init("F44E4E")
                            recordButton.isEnabled = true
                            break
                        }
                    }
                }
            } catch {
                print("JSON serialization failed: \(error)")
            }
        }
    }
    
    func videoCloudMixerContent() -> [[String: Any]] {
        
        var layoutConfig = [[String: Any]]()
        let columns = 3
        let vSpace = 8
        let hSpace = 25
        let contentWidth = Int(dstResolution().width)
        let contentHeight = Int(dstResolution().height)
        let itemWidth = (contentWidth - (columns - 1)*hSpace)/columns
        let itemHeight = itemWidth*16/9
        
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        guard let watchableVideos = cloudroomVideoMeeting.getWatchableVideos() as? Array<UsrVideoId>, watchableVideos.count > 0 else { return [] }
        
        let videos = watchableVideos.filter { (item) -> Bool in
            if item.userId == myUserId() {
                var config = [String: Any]()
                config["type"] = 0
                config["top"] = 0
                config["left"] = 0
                config["width"] = contentWidth
                config["height"] = contentHeight
                config["keepAspectRatio"] = 1
                config["param"] = ["camid": "\(item.userId ?? "").\(item.videoID)"]
                layoutConfig.append(config)
                return false
            }
            return true
        }
        
        let itemsCount = videos.count
        
        guard itemsCount > 0 else {
            return layoutConfig
        }
        
        for i in 0..<itemsCount {
            
            let usrVideoId = videos[i]
            
            let row = i/columns
            let column = i%columns
            
            let x = contentWidth - (column + 1)*itemWidth - column*hSpace
            let y = row*itemHeight + row*vSpace
            
            var config = [String: Any]()
            config["type"] = 0
            config["top"] = Int(x)
            config["left"] = Int(y)
            config["width"] = itemWidth
            config["height"] = itemHeight
            config["keepAspectRatio"] = 1
            config["param"] = ["camid": "\(usrVideoId.userId ?? "").\(usrVideoId.videoID)"]
            layoutConfig.append(config)
        }
        
        // 加时间戳
        var config = [String: Any]()
        config["type"] = 10
        config["top"] = 3
        config["left"] = 3
        config["param"] = ["text": "%timestamp%",
                           "background": "#0000007D",
                           "font-size": 20,
                           "text-margin": 5,
                           "color": "#FFFFFF"] as [String : Any]
        layoutConfig.append(config)
        
        return layoutConfig
    }
    
    
    @IBAction func recordAction(_ sender: Any) {

        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        guard let title = recordButton.currentTitle, title == "开始录制", mixerID.isEmpty else {
            cloudroomVideoMeeting.destroyCloudMixer(mixerID)
            recordButton.setTitle("开始录制", for: .normal)
            recordButton.backgroundColor = UIColor.init("3981FC")
            return
        }
        
        var videoFileCfg = [String: Any]()
        videoFileCfg["svrPathName"] = "/" + curDirName() + "/" + curFileName() + "_iOS_" + "\(meetID ?? 0)" + ".mp4"
        videoFileCfg["vWidth"] = dstResolution().width
        videoFileCfg["vHeight"] = dstResolution().height
        videoFileCfg["vFps"] = 15
        videoFileCfg["layoutConfig"] = videoCloudMixerContent()
        
        var cloudMixerMap = [String: Any]()
        cloudMixerMap["mode"] = 0
        cloudMixerMap["videoFileCfg"] = videoFileCfg
        
        let jsonData = try! JSONSerialization.data(withJSONObject: cloudMixerMap, options: .prettyPrinted)
        guard let cloudMixerCfg = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        let mixerID = cloudroomVideoMeeting.createCloudMixer(cloudMixerCfg)
        if mixerID.isEmpty == true {
            print("[svrRecord]  开启云端录制失败")
            return
        }
        self.mixerID = mixerID
        recordButton.setTitle("结束录制", for: .normal)
        recordButton.backgroundColor = UIColor.init("F44E4E")
    }
    
    // 重写视频变化函数更新录制内容（订阅观看了什么录制什么）
    override func updateVideoWall() {
        super.updateVideoWall()
        
        var videoFileCfg = [String: Any]()
        videoFileCfg["layoutConfig"] = videoCloudMixerContent()
        let jsonData = try! JSONSerialization.data(withJSONObject: videoFileCfg, options: .prettyPrinted)
        if let videoFileCfgJson = String(data: jsonData, encoding: .utf8) {
            CloudroomVideoMeeting.shareInstance().updateCloudMixerContent(mixerID, cfg: videoFileCfgJson)
        }
    }
    
    func createCloudMixerFailed(_ mixerID: String, err: CRVIDEOSDK_ERR_DEF) {
        recordButton.setTitle("开始录制", for: .normal)
        recordButton.backgroundColor = UIColor.init("3981FC")
    }
    
    func cloudMixerStateChanged(_ operatorID: String, mixerID: String, state: MIXER_STATE, exParam: String) {
        guard mixerID != self.mixerID, operatorID != myUserId() else { return }
        
        if state == MIXER_STATE.NO_RECORD {
            recordButton.isEnabled = true
            recordButton.backgroundColor = UIColor.init("3981FC")
        }
        
        if state == MIXER_STATE.RECORDING {
            recordButton.isEnabled = false
            recordButton.backgroundColor = UIColor.init("F44E4E")
        }
    }
    
    func cloudMixerInfoChanged(_ mixerID: String) {
        
    }
    
    func cloudMixerOutputInfoChanged(_ mixerID: String, jsonStr: String) {
        
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
