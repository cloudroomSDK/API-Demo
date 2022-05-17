//
//  VideoWallContentView.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/13.
//

import UIKit

class VideoWallContentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commitUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commitUI()
    }
    
    func commitUI() {
        
    }
    
    func updateVideoWall(items: Array<UsrVideoId>) {
        
        // 如果历史控件溢出
        let subviewsCount = self.subviews.count
        let itemsCount = items.count
        if itemsCount < subviewsCount {
            // 反向遍历删除
            for i in (itemsCount..<subviewsCount).reversed() {
                if let subView = self.subviews[i] as? CustomCameraView {
                    subView.usrVideoId = nil
                    subView.removeFromSuperview()
                }
            }
            
        } else {
            // 补齐所需控件
            for _ in subviewsCount..<itemsCount {
                
                let cameraView = CustomCameraView()
                addSubview(cameraView)
            }
        }
        
        let rows = 3
        let vSpace = 8.0
        let hSpace = 25.0
        let contentWidth = self.frame.size.width
        let itemWidth = (contentWidth - CGFloat(rows - 1)*hSpace)/CGFloat(rows)
        let itemHeight = itemWidth*16/9
        
        for i in 0..<itemsCount {
            
            let usrVideoId = items[i]
            
            let column = i/rows
            let row = i%rows
            
            let x = contentWidth - CGFloat(column + 1)*itemWidth - Double(column)*hSpace
            let y = CGFloat(row)*itemHeight + Double(row)*vSpace
            
            if let cameraView = self.subviews[i] as? CustomCameraView {
                cameraView.usrVideoId = usrVideoId
                cameraView.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            }
            
        }
    }

}
