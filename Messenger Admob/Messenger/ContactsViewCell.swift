//
//  ContactsViewCell.swift
//  Messenger
//
//  Created by DJay on 22/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
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
