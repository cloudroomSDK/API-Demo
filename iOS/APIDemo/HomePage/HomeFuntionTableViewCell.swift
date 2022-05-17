//
//  HomeFuntionTableViewCell.swift
//  APIDemo
//
//  Created by YunWu01 on 2022/1/6.
//

import UIKit

class HomeFuntionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleButton.layer.cornerRadius = 2.0
        self.titleButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
