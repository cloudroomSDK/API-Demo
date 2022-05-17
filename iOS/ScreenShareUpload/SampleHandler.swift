//
//  SampleHandler.swift
//  ScreenShareUpload
//
//  Created by YunWu01 on 2022/1/11.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        CRReplayKitExt.shareInstance().broadcastStarted(self, setupInfo: setupInfo!)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        CRReplayKitExt.shareInstance().broadcastPaused()
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        CRReplayKitExt.shareInstance().broadcastResumed()
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        CRReplayKitExt.shareInstance().broadcastFinished()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            CRReplayKitExt.shareInstance().processSampleBuffer(sampleBuffer, with: sampleBufferType)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
