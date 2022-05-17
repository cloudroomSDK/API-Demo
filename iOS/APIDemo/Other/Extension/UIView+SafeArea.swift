//
//  UIView+SafeArea.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/10.
//

import Foundation

public extension UIView {
    
    var crSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
}
