//
//  CustomCameraView.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/12.
//

import UIKit

class CustomCameraView: CLCameraView {

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
        self.addSubview(self.usernameLabel)
        usernameLabel.layer.cornerRadius = 2.0
        usernameLabel.clipsToBounds = true
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(3)
            make.leading.equalTo(self).offset(3)
            make.trailing.lessThanOrEqualTo(self).offset(-3)
        }
    }
    
    override func setUsrVideoId(_ usrVideoId: UsrVideoId!, qualityLv: Int32) {
        super.setUsrVideoId(usrVideoId, qualityLv: qualityLv)
        
        guard let usrVideoId = usrVideoId, let userID = usrVideoId.userId, userID.count > 0 else { return }
        usernameLabel.text = CloudroomVideoMeeting.shareInstance().getNickName(userID)
        
    }
    
    lazy var usernameLabel: UILabel = {
        usernameLabel = UILabel()
        usernameLabel.textColor = UIColor.white
        usernameLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        return usernameLabel
    }()
}
