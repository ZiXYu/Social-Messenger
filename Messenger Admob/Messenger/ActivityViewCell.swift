//
//  ActivityViewCell.swift
//  Messenger
//
//  Created by DJay on 22/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class ActivityViewCell: UITableViewCell {

    
    @IBOutlet weak var userDp: UIImageView!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var viewPic: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
