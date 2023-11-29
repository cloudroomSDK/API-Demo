//
//  UIApplication+Extension.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/7.
//

import Foundation
import UIKit

extension UIApplication {
    static func rootViewControllerView() -> UIView? {
        return UIApplication.rootViewController()?.view
    }
    static func rootViewController() -> UINavigationController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else {
            return nil
        }
        return rootViewController
    }
}
