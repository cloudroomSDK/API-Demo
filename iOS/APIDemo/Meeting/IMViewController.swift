//
//  IMViewController.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/8.
//

import UIKit

let cellID1 = "ChatRemoteTableViewCell"
let cellID2 = "ChatMineTableViewCell"

struct Message: Codable {
    let IMMsg: String?
    let CmdType: String?
}

struct ChatModel: Codable {
    let name: String?
    let time: String?
    let msg: Message
    let mine: Bool?
    
    init(name: String, time: String, msg: Message, mine: Bool) {
        self.name = name
        self.time = time
        self.msg = msg
        self.mine = mine
    }
}


class IMViewController: CommonMeetingViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var chatInputView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatInputViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = Array<ChatModel>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setupTableView() {
        dataSource.removeAll()
        tableView.register(UINib.init(nibName: "ChatRemoteTableViewCell", bundle: nil), forCellReuseIdentifier: cellID1)
        tableView.register(UINib.init(nibName: "ChatMineTableViewCell", bundle: nil), forCellReuseIdentifier: cellID2)
    }
    
    func reloadNewMessage() {
        if dataSource.count > 1 {
            tableView.insertRows(at: [IndexPath(row: dataSource.count - 1, section: 0)], with: .bottom)
            tableView.scrollToRow(at: IndexPath(row: dataSource.count - 1, section: 0), at: .bottom, animated: true)
        } else {
            tableView.reloadData()
        }
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
//        if textField.isFirstResponder {
//            textField.resignFirstResponder()
//        }
        
        let text = textField.text
        guard let text = text, text.count > 0 else {
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: Date())
        
        let data = "{\"IMMsg\":\"\(text)\",\"CmdType\":\"IM\"}"
        
        let decoder = JSONDecoder()
        let msg = try! decoder.decode(Message.self, from: data.data(using: .utf8)!)
        
        let name = CloudroomVideoMeeting.shareInstance().getNickName(myUserId())
        let model = ChatModel.init(name: name, time: time, msg: msg, mine: true)
        dataSource.append(model)
        
        // send message
        CloudroomVideoMeeting.shareInstance().sendCustomMsg(data, cookie: "")
        
        textField.text = nil
        
        reloadNewMessage()
    }
    
    @IBAction func keyboardDown(_ sender: Any) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @objc func keyboardFrameChanged(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let bottomCons = endFrame.origin.y < self.view.frame.size.height ? -endFrame.size.height + self.view.crSafeAreaInsets.bottom : 0;
        
        UIView.animate(withDuration: duration) {
            self.chatInputViewBottomCons.constant = bottomCons
        }
    }
    
    // MARK: - CloudroomVideoMgrCallBack
    
    func sendCustomMeetingMsgRslt(_ sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String!) {
        guard sdkErr == CRVIDEOSDK_NOERR else {
            self.view.makeToast("发送IM失败: \(sdkErr.rawValue)")
            return
        }
    }
    
    func notifyCustomMeetingMsg(_ fromUserID: String!, jsonDat: String!) {
        guard fromUserID != myUserId() else {
            return
        }
        
        print("notifyCustomMeetingMsg:\(jsonDat!)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: Date())
        
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(Message.self, from: jsonDat.data(using: .utf8)!)
            let name = CloudroomVideoMeeting.shareInstance().getNickName(fromUserID)
            let model = ChatModel.init(name: name, time: time, msg: message, mine: false)
            dataSource.append(model)
            
            reloadNewMessage()
        } catch {
            self.view.hideToast()
            self.view.makeToast("不能解析的消息")
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        if model.mine == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID1, for: indexPath) as! ChatRemoteTableViewCell
            
            cell.usernameLabel.text = model.name! + ":"
            cell.timeLabel.text = model.time
            cell.contentLabel.text = model.msg.IMMsg
            
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID2, for: indexPath) as! ChatMineTableViewCell
        
        cell.timeLabel.text = model.time
        cell.contentLabel.text = model.msg.IMMsg
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
