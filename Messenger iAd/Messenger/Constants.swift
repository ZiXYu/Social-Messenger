//
//  Constants.swift
//  Messenger
//
//  Created by djay mac on 12/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit


let phonewidth = UIScreen.mainScreen().bounds.width
let phoneheight = UIScreen.mainScreen().bounds.height

let Device = UIDevice.currentDevice()

let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8



let storyb = UIStoryboard(name: "Main", bundle: nil)

var currentuser = PFUser.currentUser()
let userpf = PFUser()
var justSignedUp = false





func scaleImage(imagename:String, and newSize:CGSize)->UIImage{
    var image = UIImage(named: imagename)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
    var newImg = UIGraphicsGetImageFromCurrentImageContext()
    return newImg
}




func updateActivity( type:String, content:String) {
    var activity = PFObject(className: "Activity")
    activity["type"] = type
    activity["content"] = content
    activity["user"] = currentuser
    activity.saveInBackground()
    
}















