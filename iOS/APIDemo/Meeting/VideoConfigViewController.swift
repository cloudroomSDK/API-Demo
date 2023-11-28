//
//  VideoConfigViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class VideoConfigViewController: VideoWallViewController {

    @IBOutlet weak var videoConfigMenu: UIView!
    @IBOutlet weak var button_360P: CRCornerButton!
    @IBOutlet weak var button_480P: CRCornerButton!
    @IBOutlet weak var button_720P: CRCornerButton!
    
    @IBOutlet weak var kbpsLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    @IBOutlet weak var kbpsSlider: UISlider!
    @IBOutlet weak var fpsSlider: UISlider!
    
    let selectedColor = UIColor.init("3981FC")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.view.bringSubviewToFront(videoConfigMenu)
        videoConfigMenu.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        button_360P.layer.borderWidth = 1.0
        button_480P.layer.borderWidth = 1.0
        button_720P.layer.borderWidth = 1.0
        
        button_360P.layer.borderColor = UIColor.white.cgColor
        button_480P.layer.borderColor = UIColor.white.cgColor
        button_720P.layer.borderColor = UIColor.white.cgColor
    }
    
    func readDefaultConfig() {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        let fps = vCfg.fps
        fpsSlider.value = Float(fps)
        fpsLabel.text = "\(fps)fps"

        let maxbps = vCfg.maxbps
        kbpsSlider.value = maxbps > 0 ? Float(maxbps/1000) : Float(maxbps)
        kbpsLabel.text = maxbps > 0 ? "\(maxbps/1000)kbps" : "\(maxbps)kbps"
        
        
        let videoSize = vCfg.size
        if min(videoSize.width, videoSize.height) == 360 {
            button_360P.layer.borderColor = selectedColor.cgColor
        } else if min(videoSize.width, videoSize.height) == 480 {
            button_480P.layer.borderColor = selectedColor.cgColor
        } else if min(videoSize.width, videoSize.height) == 720 {
            button_720P.layer.borderColor = selectedColor.cgColor
        }
        
    }
    
    @IBAction func configVideoSize360P(_ sender: Any) {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        vCfg.size = CGSize(width: 640, height: 360)
        vCfg.maxbps = -1
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        button_360P.layer.borderColor = selectedColor.cgColor
        button_480P.layer.borderColor = UIColor.white.cgColor
        button_720P.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func configVideoSize480P(_ sender: Any) {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        vCfg.size = CGSize(width: 848, height: 480)
        vCfg.maxbps = -1
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        button_360P.layer.borderColor = UIColor.white.cgColor
        button_480P.layer.borderColor = selectedColor.cgColor
        button_720P.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func configVideoSize720P(_ sender: Any) {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        vCfg.size = CGSize(width: 1280, height: 720)
        vCfg.maxbps = -1
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        button_360P.layer.borderColor = UIColor.white.cgColor
        button_480P.layer.borderColor = UIColor.white.cgColor
        button_720P.layer.borderColor = selectedColor.cgColor
    }
    
    @IBAction func kbpsChanged(_ sender: UISlider) {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let value = Int32(sender.value)
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        if vCfg.maxbps == value {
            return
        }
        vCfg.maxbps = value*1000
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        kbpsLabel.text = "\(value)" + "kbps"
        print("current FPS:\(cloudroomVideoMeeting.getVideoCfg().maxbps)kbps")
    }
    
    @IBAction func fpsChanged(_ sender: UISlider) {
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let value = Int32(sender.value)
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        if vCfg.fps == value {
            return
        }
        vCfg.fps = value
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        fpsLabel.text = "\(value)" + "fps"
        print("current FPS:\(cloudroomVideoMeeting.getVideoCfg().fps )")
    }
    
    @IBAction func exitMeeting(_ sender: Any) {
        exitMeetingRoom()
    }
    
    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        let vCfg = cloudroomVideoMeeting.getVideoCfg()
        vCfg.fps = 24
        vCfg.maxbps = 350*1000
        vCfg.size = CGSize(width: 640, height: 360)
        cloudroomVideoMeeting.setVideoCfg(vCfg)
        
        readDefaultConfig()
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
