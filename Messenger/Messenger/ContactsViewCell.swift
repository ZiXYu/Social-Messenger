//
//  ContactsViewCell.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class ContactsViewCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactStatus: UILabel!
    @IBOutlet weak var contactPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
