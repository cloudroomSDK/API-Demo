//
//  ViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/6.
//

import UIKit

enum APIFeature: String, CaseIterable {
    case voice = "语音通话"
    case video = "视频通话"
    case videoConfig = "视频设置"
    case screenShare = "屏幕共享"
    
    case localRecord = "本地录制"
    case mixerRecord = "云端录制"
    case playVideo = "视频播放"
    case chat = "聊天"
}


let cellID = "HomeFuntionTableViewCell"

class ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, CloudroomVideoMgrCallBack {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["基础功能", "高级功能"]
    var dataSource = Array<Array<String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        makeDataSource()
        setupTableView()
        
//        CRSDKLogin.shared.loginSDK()
    }
    
    func makeDataSource() {
        var basic = [String]()
        for i in 0..<4 {
            let title = APIFeature.allCases[i].rawValue
            basic.append(title)
        }
        dataSource.append(basic)
        
        var advanced = [String]()
        for i in 4..<APIFeature.allCases.count {
            let title = APIFeature.allCases[i].rawValue
            advanced.append(title)
        }
        dataSource.append(advanced)
    }
    
    func setupTableView() {
        if #available(iOS 15.0, *) {
              self.tableView.sectionHeaderTopPadding = 0
        }
        self.tableView.backgroundColor = self.view.backgroundColor
        self.tableView.register(.init(nibName: "HomeFuntionTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        
        let appVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        self.versionLabel.text = "AppVer: " + appVer + "\n" + "SDKVer: " + CloudroomVideoSDK.getVer()
    }


    @IBAction func serviceConfig(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! HomeFuntionTableViewCell
        
        let title = dataSource[indexPath.section][indexPath.row]
        cell.titleButton.setTitle(title, for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("HomeFunctionHeader", owner: nil, options: nil)![0] as! HomeFunctionHeader
        header.titleLabel.text = sectionTitles[section]
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.view.hideToast()
        
        let title: String? = dataSource[indexPath.section][indexPath.row]

        guard let title = title else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EnterMeetingViewController") as! EnterMeetingViewController
        viewController.featureTitle = title
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

