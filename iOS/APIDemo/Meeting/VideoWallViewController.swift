//
//  VideoWallViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class VideoWallViewController: CommonMeetingViewController {

    var members = Array<UsrVideoId>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        mineCameraView.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom)
        videoWallView.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.width)
    }
    
    func setupUI() {
        self.view.addSubview(self.mineCameraView)
        self.view.addSubview(self.videoWallView)
        print("setupUI frame")
        print(mineCameraView.frame)
        print(videoWallView.frame)
        mineCameraView.keepAspectRatio = false
    }
    
    func updateVideoWall() {
        
        let videoMeeting = CloudroomVideoMeeting.shareInstance()
        
        guard let watchableVideos = videoMeeting?.getWatchableVideos() as? Array<UsrVideoId> else { return }
        
        if members.count == 0 {
            members.append(contentsOf: watchableVideos)
        } else {

            // 原来存在的
            let same = watchableVideos.filter { (item) -> Bool in
                for obj2 in members {
                    if item.userId == obj2.userId, item.videoID == obj2.videoID {
                        return true
                    }
                }
                return false
            }
            
            // 变化的
            let diff = watchableVideos.filter { (item) -> Bool in
                for obj2 in members {
                    if item.userId == obj2.userId, item.videoID == obj2.videoID {
                        return false
                    }
                }
                return true
            }
            
            guard diff.count > 0 else {
                return
            }
            
            members.removeAll()
            members.append(contentsOf: same)
            members.append(contentsOf: diff)
        }
        
        let tmpItems = members.filter { (item) -> Bool in
            if item.userId == myUserId() {
                self.mineCameraView.usrVideoId = item
                return false
            }
            return true
        }
        members.removeAll()
        members.append(contentsOf: tmpItems)
        
        videoWallView.updateVideoWall(items: members)
    }

  
    // MARK: - CloudroomVideoMeetingCallBack

    override func enterMeetingRslt(_ code: CRVIDEOSDK_ERR_DEF) {
        super.enterMeetingRslt(code)
        
        updateVideoWall()
    }
    
    func userLeftMeeting(_ userID: String!) {
        updateVideoWall()
    }
    
    func userEnterMeeting(_ userID: String!) {
        updateVideoWall()
    }
    
    func videoStatusChanged(_ userID: String!, oldStatus: VIDEO_STATUS, newStatus: VIDEO_STATUS) {
        updateVideoWall()
        
        guard userID == myUserId(), newStatus == VCLOSE else {return}
        
        mineCameraView.clearFrame()
    }
    
    override func videoDevChanged(_ userID: String!) {
        super.videoDevChanged(userID)
        
        updateVideoWall()
    }

    lazy var videoWallView: VideoWallContentView = {
        let videoWallView = VideoWallContentView.init(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.width))
        return videoWallView
    }()
    
    lazy var mineCameraView: CustomCameraView = {
        let mineCameraView = CustomCameraView.init(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        return mineCameraView
    }()
    
}

extension VideoWallViewController {
    
    func dstResolution() -> CGSize {
        return CGSize(width: 480, height: 848)
    }
    
    func mixerCfg() -> MixerCfg {
        let cfg = MixerCfg()
        cfg.fps = 15
        cfg.defaultQP = 18
        cfg.gop = 15*15
        cfg.dstResolution = dstResolution()
        cfg.maxBPS = 500*1000
        
        return cfg
    }
    
    func videoMixerContent() -> MixerContent {
        
        let recContent = MixerContent()
        let recordVideos = NSMutableArray()
        let rows = 3
        let vSpace = 8.0
        let hSpace = 25.0
        let contentWidth = dstResolution().width
        let contentHeight = dstResolution().height
        let itemWidth = (contentWidth - CGFloat(rows - 1)*hSpace)/CGFloat(rows)
        let itemHeight = itemWidth*16/9
        
        let cloudroomVideoMeeting = CloudroomVideoMeeting.shareInstance()
        
        guard let watchableVideos = cloudroomVideoMeeting?.getWatchableVideos() as? Array<UsrVideoId>, watchableVideos.count > 0 else { return recContent }
        
        let videos = watchableVideos.filter { (item) -> Bool in
            if item.userId == myUserId() {
                let cameraRect = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
                let video = RecVideoContentItem(rect: cameraRect, userID: item.userId, camID: item.videoID)
                video?.keepAspectRatio = false
                recordVideos.add(video as Any)
                return false
            }
            return true
        }
        
        let itemsCount = videos.count
        
        guard itemsCount > 0 else {
            recContent.contents = recordVideos
            return recContent
        }
        
        for i in 0..<itemsCount {
            
            let usrVideoId = videos[i]
            
            let column = i/rows
            let row = i%rows
            
            let x = contentWidth - CGFloat(column + 1)*itemWidth - Double(column)*hSpace
            let y = CGFloat(row)*itemHeight + Double(row)*vSpace
            
            let cameraRect = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            guard let video = RecVideoContentItem(rect: cameraRect, userID: usrVideoId.userId, camID: usrVideoId.videoID) else {
                recContent.contents = recordVideos
                return recContent
            }
            video.keepAspectRatio = true
            recordVideos.add(video)
        }
        
        // 加时间戳
        let time = RecTimeStampContentItem(rect: CGRect(x: 3, y: 3, width: contentWidth - 3*2, height: 15), resID: "time")
        recordVideos.add(time as Any)
        
        recContent.contents = recordVideos
        
        return recContent
    }
    
    func curFileName() -> String {
        let date = Date()
        let formartter = DateFormatter()
        formartter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = formartter.string(from: date)
        return fileName
    }
    
    func curDirName() -> String {
        let date = Date()
        let formartter = DateFormatter()
        formartter.dateFormat = "yyyy-MM-dd"
        let fileName = formartter.string(from: date)
        return fileName
    }
    
}
