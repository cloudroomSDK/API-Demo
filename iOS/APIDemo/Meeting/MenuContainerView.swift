//
//  MenuContainerView.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

class MenuContainerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commitAppearance()
//        fatalError("init(coder:) has not been implemented")
    }
    
    func commitAppearance() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.9)
    }
    
}
