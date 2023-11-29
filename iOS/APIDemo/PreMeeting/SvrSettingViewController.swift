//
//  SvrSettingViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/6.
//

import UIKit

let kAppIDDefaultShow = "默认appID"

class SvrSettingViewController: BaseViewController {
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var appIDTextField: UITextField!
    @IBOutlet weak var appSecretTextField: UITextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        reloadTextFields()
    }
    
    func setupUI() {
        self.restoreButton.layer.cornerRadius = 2.0
        self.restoreButton.layer.masksToBounds = true
        
        
        // 保存按钮
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle("保存", for: .normal)
        button.setTitleColor(UIColor.init("3981FC"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        button.addTarget(self, action: #selector(saveConfigAction), for: .touchUpInside)
        
        let rightBarItem = UIBarButtonItem.init(customView: button)
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func reloadTextFields() {
        let appIDCache = UserDefaults.standard.string(forKey: APPIDKey) ?? ""
        if appIDCache.isEmpty == true, KDefaultAppID.isEmpty == false, CRSDKHelper.shared.APPID == KDefaultAppID {
            appIDTextField.text = kAppIDDefaultShow
        } else {
            appIDTextField.text = CRSDKHelper.shared.APPID
        }
        serviceTextField.text = CRSDKHelper.shared.server
        appSecretTextField.text = CRSDKHelper.shared.APPSecret
    }
    
    func keyboardDown() {
        if serviceTextField.isFirstResponder {
            serviceTextField.resignFirstResponder()
        }
        
        if appSecretTextField.isFirstResponder {
            appSecretTextField.resignFirstResponder()
        }
        
        if appIDTextField.isFirstResponder {
            appIDTextField.resignFirstResponder()
        }
    }
    
    @IBAction func saveConfigAction(_ sender: Any) {
        keyboardDown()
        
        let appID = appIDTextField.text
        let appSecret = appSecretTextField.text
        let server = serviceTextField.text
        let nickName = CRSDKHelper.shared.nickname
        
        self.view.hideToast()
        guard let appID = appID, appID.count > 0 else {
            self.view.makeToast("appID不正确")
            return
        }

        guard let appSecret = appSecret, appSecret.count > 0 else {
            self.view.makeToast("appSecret不正确")
            return
        }
        
        guard let server = server, server.count > 0 else {
            self.view.makeToast("服务器地址不正确")
            return
        }
        
        guard let nickName = nickName, nickName.count > 0 else {
            print("昵称不正确")
            return
        }
        
        
        CloudroomVideoMgr.shareInstance().logout()
        
        let appIDCache = UserDefaults.standard.string(forKey: APPIDKey)
        if appIDCache?.isEmpty == true, appID == KDefaultAppID {
            CRSDKHelper.shared.write(APPID: nil, APPSecret: nil, server: server, nickName: nickName, datEncType: "0")
        } else {
            CRSDKHelper.shared.write(APPID: appID, APPSecret: appSecret, server: server, nickName: nickName, datEncType: "0")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setupForVideoCallSDK()
                
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.view.hideToast()
        self.navigationController?.view.makeToast("保存成功")
    }
    
    @IBAction func restoreDefaultAction(_ sender: Any) {
        keyboardDown()
        
        CloudroomVideoMgr.shareInstance().logout()
        CRSDKHelper.shared.resetInfo()
        reloadTextFields()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setupForVideoCallSDK()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownKeyboard(_ sender: Any) {
        keyboardDown()
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
