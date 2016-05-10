//
//  Parameters.swift
//  Messenger
//
//  Created by 虞子轩 on 16/3/23.
//  Copyright © 2016年 Zixuan. All rights reserved.
//

import UIKit

let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
let serverUrl = "http://ec2-52-90-136-128.compute-1.amazonaws.com:8080/request/"

//Create two timer
var timer1 = NSTimer()
var timer2 = NSTimer()

var rate = 10 //Default rate as 10, in case of losing connection with server
var preRate = 10

var syncSec = 0 //syncSec declair the current second of server
var reqNumber = 0, reqWeight = 0, reqReal = 0
var reqNumOne = 0, reqNumTwo = 0, reqNumThe = 0
var errorCode = 0 //this code is used when the connection with server is failed

//buffer of friend request
class FriendRequest {
    var toFriend : PFUser = PFUser(),
    time : Int = 0
}

//buffer of chat message
class Message {
    var room : PFObject! = nil,
    friend : PFUser = PFUser(),
    picf : UIImage? = nil,
    content : String = ""
}

//buffer of other requests
var FRArray : [FriendRequest] = []
var MsgArray : [Message] = []
var nameUpdate = 0, picUpdate = 0, userName = 0
var statusUpdate = ""
var ReqArray : [PFObject] = []

















