//
//  ImageFunc.swift
//  Messenger
//
//  Created by djay mac on 13/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit


func scaleImage(image:UIImage, and newSize:CGFloat)->UIImage{
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize, height: newSize), false, 0.0)
    image.drawInRect(CGRectMake(0, 0, newSize, newSize))
    var newImg = UIGraphicsGetImageFromCurrentImageContext()
    return newImg
}




func getImage(forKey:String,imgView:UIImageView) {
    // get user  pics
    if let pic = currentuser.objectForKey(forKey) as? PFFile {
        pic.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
            if error == nil {
                imgView.image = UIImage(data: data)
            }
        })
    }
}



func circleBorder(image:UIImageView) {
    image.layer.masksToBounds = true
    image.layer.cornerRadius = image.frame.size.height/2
    image.layer.borderWidth = image.frame.size.height/30
    image.layer.borderColor = borderColor.CGColor
}














