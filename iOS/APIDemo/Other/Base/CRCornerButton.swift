//
//  CRCornerButton.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/11.
//

import UIKit

class CRCornerButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeCorners()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeCorners()
    }
    
    private func makeCorners() {
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
    }
}
