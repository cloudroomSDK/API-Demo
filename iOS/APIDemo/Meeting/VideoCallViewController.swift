//
//  VideoCallViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/12.
//

import UIKit

class VideoCallViewController: VideoWallViewController {

    @IBOutlet weak var buttonHelperView: UIView!
    @IBOutlet weak var changeCamButton: UIButton!
    @IBOutlet weak var closeCamButton: UIButton!
    @IBOutlet weak var closeMicButton: UIButton!
    @IBOutlet weak var changeSpeakerOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.bringSubviewToFront(buttonHelperView)
    }
    
    @IBAction func changeCamera(_ sender: Any) {
        exchangeCamera()
        
        let title = changeCamButton.currentTitle
        let frontCamera = "前置摄像头"
        let backCamera = "后置摄像头"
        if title == frontCamera {
            changeCamButton.setTitle(backCamera, for: .normal)
        } else if title == backCamera {
            changeCamButton.setTitle(frontCamera, for: .normal)
        }
    }
    
    @IBAction func closeMic(_ sender: Any) {
        let userId = myUserId()
        let aStatus = CloudroomVideoMeeting.shareInstance().getAudioStatus(userId)
        if aStatus == AOPEN {
            CloudroomVideoMeeting.shareInstance().closeMic(userId)
        } else {
            CloudroomVideoMeeting.shareInstance().openMic(userId)
        }
    }
    
    @IBAction func changeSpeakerOut(_ sender: Any) {
        let speakerOut = CloudroomVideoMeeting.shareInstance().getSpeakerOut()
        if speakerOut {
            CloudroomVideoMeeting.shareInstance().setSpeakerOut(false)
            changeSpeakerOutButton.setTitle("设为扬声器", for: .normal)

        } else {
            CloudroomVideoMeeting.shareInstance().setSpeakerOut(true)
            changeSpeakerOutButton.setTitle("设为听筒", for: .normal)
        }
    }
    
    @IBAction func closeCamera(_ sender: Any) {
        let userId = myUserId()
        let vStatus = CloudroomVideoMeeting.shareInstance().getVideoStatus(userId)
        if vStatus == VOPEN {
            CloudroomVideoMeeting.shareInstance().closeVideo(userId)
        } else {
            CloudroomVideoMeeting.shareInstance().openVideo(userId)
        }
    }
    
    override func videoStatusChanged(_ userID: String!, oldStatus: VIDEO_STATUS, newStatus: VIDEO_STATUS) {
        super.videoStatusChanged(userID, oldStatus: oldStatus, newStatus: newStatus)
        
        guard userID == myUserId() else { return}
        
        let title = newStatus == VOPEN ? "关闭摄像头" : "打开摄像头"
        guard title != closeCamButton.currentTitle else {return}
        self.closeCamButton.setTitle(title, for: .normal)
    }
    
    func audioStatusChanged(_ userID: String!, oldStatus: AUDIO_STATUS, newStatus: AUDIO_STATUS) {
        guard userID == myUserId() else { return}
        
        let title = newStatus == AOPEN ? "关闭麦克风" : "打开麦克风"
        guard title != closeMicButton.currentTitle else {return}
        self.closeMicButton.setTitle(title, for: .normal)
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
