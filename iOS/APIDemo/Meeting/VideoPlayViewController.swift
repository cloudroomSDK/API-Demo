//
//  VideoPlayViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit
import PhotosUI

class VideoPlayViewController: CommonMeetingViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var openFileButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mediaView: CLMediaView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var pauseImageView: UIImageView!
    
    var playing = false
    var pause = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playImageView.isHidden = true
        pauseImageView.isHidden = true

    }
    
    @IBAction func openFileAction(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        pickerController.mediaTypes = ["public.movie"]
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func playAction(_ sender: Any) {
        let filePath = textField.text
        
        guard let filePath = filePath, filePath.count > 0 else {
            self.view.makeToast("请选择文件")
            return
        }
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            self.view.makeToast("文件已不存在")
            textField.text = nil
            return
        }

        if playButton.title(for: .normal) == "开始播放" {
            CloudroomVideoMeeting.shareInstance().startPlayMedia(filePath, bLocPlay: 0, bPauseWhenFinished: 0)
            playing = true
        } else {
            CloudroomVideoMeeting.shareInstance().stopPlayMedia()
            playing = false
        }
    }
    
    @IBAction func pauseMedia(_ sender: Any) {
        guard playing else { return }
        
        pause = !pause
        CloudroomVideoMeeting.shareInstance().pausePlayMedia(pause)
    }
    
    func copyAlbumFile(mediaUrl: URL) -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let documentURL = URL.init(fileURLWithPath: documentDir)
        let tempPath = documentURL.appendingPathComponent(mediaUrl.lastPathComponent).path
        try! FileManager.default.copyItem(atPath: mediaUrl.path, toPath: tempPath)
        
        if FileManager.default.fileExists(atPath: tempPath) {
            return tempPath
        }
        
        return ""
    }
    
    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        
        guard code == CRVIDEOSDK_NOERR else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            CloudroomVideoMeeting.shareInstance().setSpeakerOut(true)
        }
        
        // 存储入会成功后的会议号(不用每次输入)
        UserDefaults.standard.setValue(String(meetID!), forKey: "KLastJoinMeetingIDKey")
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
            
        if let phAsset = info[.phAsset] as? PHAsset {
            let options = PHVideoRequestOptions()
            options.version = .current
            options.deliveryMode = .automatic
            
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
                let urlAsset = asset as! AVURLAsset
                self.textField.text = self.copyAlbumFile(mediaUrl: urlAsset.url)
            }
        } else if let mediaUrl = info[.mediaURL] as? URL {
            self.textField.text = copyAlbumFile(mediaUrl: mediaUrl)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CloudroomVideoMeetingCallBack
    
    
    
    func notifyMediaStart(_ userid: String!) {
        mediaView.clearFrame()
        
        if userid == myUserId() {
            playButton.setTitle("停止播放", for: .normal)
        } else {
            helpView.isHidden = true
        }
    }
    
    func notifyMediaPause(_ userid: String!, bPause: Bool) {
        if userid == myUserId() {
            playImageView.isHidden = !bPause
        } else {
            pauseImageView.isHidden = !bPause
        }
    }
    
    func notifyMediaStop(_ userid: String!, reason: MEDIA_STOP_REASON) {
        CloudroomVideoSDK.shareInstance().writeLog(SDK_LOG_LEVEL.DEBUG, message: "notifyMediaStop: reason \(reason.rawValue)")
        
        if userid == myUserId() {
            playing = false
            playButton.setTitle("开始播放", for: .normal)
        } else {
            helpView.isHidden = false
        }
        
        playImageView.isHidden = true
        pauseImageView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.mediaView.clearFrame()
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
