//
//  VoiceViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class VoiceCallViewController: CommonMeetingViewController {

    @IBOutlet weak var micButton: CRCornerButton!
    @IBOutlet weak var speakerOutButton: CRCornerButton!
    @IBOutlet weak var localProgress: UIProgressView!
    @IBOutlet weak var remoteProgress: UIProgressView!
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var remoteLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init("1D232F")
    }

    @IBAction func hungupAction(_ sender: Any) {
        exitMeetingRoom()
    }
    
    @IBAction func micAction(_ sender: Any) {
        let userId = myUserId()
        let aStatus = CloudroomVideoMeeting.shareInstance().getAudioStatus(userId)
        if aStatus == AOPEN {
            CloudroomVideoMeeting.shareInstance().closeMic(userId)
        } else {
            CloudroomVideoMeeting.shareInstance().openMic(userId)
        }
    }
    
    @IBAction func speakerOutAction(_ sender: Any) {
        let speakerOut = CloudroomVideoMeeting.shareInstance().getSpeakerOut()
        if speakerOut {
            CloudroomVideoMeeting.shareInstance().setSpeakerOut(false)
            speakerOutButton.setTitle("设为扬声器", for: .normal)

        } else {
            CloudroomVideoMeeting.shareInstance().setSpeakerOut(true)
            speakerOutButton.setTitle("设为听筒", for: .normal)
        }
    }
    
    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        
        guard code == CRVIDEOSDK_NOERR else {
            return
        }
        
        localLabel.text = CloudroomVideoMeeting.shareInstance().getNickName(myUserId())
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let speakerOut = CloudroomVideoMeeting.shareInstance().getSpeakerOut()
            if speakerOut {
                self.speakerOutButton.setTitle("设为听筒", for: .normal)
                
            } else {
                self.speakerOutButton.setTitle("设为扬声器", for: .normal)
            }
        }
    }
    
    func audioStatusChanged(_ userID: String!, oldStatus: AUDIO_STATUS, newStatus: AUDIO_STATUS) {
        guard userID == myUserId() else { return}
        
        let title = newStatus == AOPEN ? "关闭麦克风" : "打开麦克风"
        guard title != micButton.currentTitle else {return}
        self.micButton.setTitle(title, for: .normal)
    }
    
    func micEnergyUpdate(_ userID: String!, oldLevel: Int32, newLevel: Int32) {
        if userID == myUserId() {
            localProgress.progress = Float(newLevel)/10
        } else {
            remoteProgress.progress = Float(newLevel)/10
            remoteLabel.text = CloudroomVideoMeeting.shareInstance().getNickName(userID)
        }
    }
    
    func userLeftMeeting(_ userID: String!) {
        let nickname = CloudroomVideoMeeting.shareInstance().getNickName(userID)
        if nickname == remoteLabel.text {
            remoteProgress.progress = 0
            remoteLabel.text = "远端用户"
        }
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
