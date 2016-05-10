//
//  RequestViewCell.swift
//  Messenger
//
//  Created by DJay on 29/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class RequestViewCell: UITableViewCell {

    
    
    @IBOutlet weak var requestPic: UIImageView!
    
    @IBOutlet weak var requestNae: UILabel!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var reject: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
