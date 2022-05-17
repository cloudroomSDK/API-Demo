//
//  BaseNavigationController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/11.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 15.0, *) { //UINavigationBarAppearance属性从iOS13开始
            let navBarAppearance = UINavigationBarAppearance()
            // 背景色
            navBarAppearance.backgroundColor = UIColor.white
            // 去掉半透明效果
            navBarAppearance.backgroundEffect = nil
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            navBarAppearance.shadowColor = UIColor.clear
            // 字体颜色
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationBar.scrollEdgeAppearance = navBarAppearance
            self.navigationBar.standardAppearance = navBarAppearance
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
