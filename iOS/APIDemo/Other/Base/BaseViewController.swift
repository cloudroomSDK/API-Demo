//
//  BaseViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/6.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init("F0F0F0")
        
        makeCustomBackButtonItem()
    }
    
}


extension BaseViewController {
    
    func makeCustomBackButtonItem() {
        
        guard let viewControllersCount = navigationController?.viewControllers.count, viewControllersCount > 1 else { return }
        
        let backButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "meetlistback"), style: .done, target: self, action: #selector(backToPrevious))
        let fixedItem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedItem.width = -5
        
        navigationItem.leftBarButtonItems = [backButtonItem]
        
    }
    
    @objc func backToPrevious() {
        self.navigationController?.popViewController(animated: true)
    }
}
