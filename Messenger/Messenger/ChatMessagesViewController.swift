//
//  ChatMessagesViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit
import MediaPlayer

class ChatMessagesViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate {


    var room:PFObject!
    var incomingUser:PFUser!
    var users = [PFUser]()
    
    var messages = [JSQMessage]()
    var messageObjects = [PFObject]()
    
    var outgoingBubbleImage:JSQMessagesBubbleImage!
    var incomingBubbleImage:JSQMessagesBubbleImage!
    
    var selfAvatar:JSQMessagesAvatarImage!
    var incomingAvatar:JSQMessagesAvatarImage!
    
    var selfUsername:NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.backgroundColor = backColor //!
        incomingUser.fetchIfNeeded()
        selfUsername = currentuser.objectForKey("name") as! NSString
        let incomingUsername = incomingUser.objectForKey("name") as! NSString
        
        self.senderId = currentuser.objectId
        self.senderDisplayName = currentuser.username
        
        
        
        let vv:UIView = UIView(frame: CGRectMake(0, 0, 140, 44))
        vv.backgroundColor = UIColor.clearColor()
        let toplabel = UILabel(frame: vv.frame)
        toplabel.numberOfLines = 0
        toplabel.textAlignment = .Center
        toplabel.text = incomingUsername as String
        toplabel.textColor = colorText
        vv.addSubview(toplabel)
        self.navigationItem.titleView = vv
    
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "barButtonPressed:")
        
        if let userimage = currentuser.objectForKey("dpSmall") as? PFFile {
            userimage.getDataInBackgroundWithBlock({ (img:NSData!, error:NSError!) -> Void in
                if (error == nil)
                {
                    self.selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: img), diameter: 15)
                    
                }
            })
        } else {
            selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(selfUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        
        
        if let inuserimage = incomingUser.objectForKey("dpSmall") as? PFFile {
            inuserimage.getDataInBackgroundWithBlock({ (img:NSData!, error:NSError!) -> Void in
                if (error == nil)
                {
                    self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: img), diameter: 15)
                }
            })
        } else {
            incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(incomingUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        
     
       
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.greenColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.grayColor())
        
        loadMessages()
        
    }
    
    
    
    
    
    override func didPressAccessoryButton(sender: UIButton!) {

        let picker = UIImagePickerController()
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    
    func barButtonPressed(sender:UIBarButtonItem!) {
        let sheetChat = UIActionSheet(title: "Choose one", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete Contact")
        sheetChat.addButtonWithTitle("View Profile")
        sheetChat.showInView(self.view)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {

        if buttonIndex == 0 { // delete
            
            room["accepted"] = false
            room.saveInBackgroundWithBlock({ (done:Bool, error:NSError!) -> Void in
                if error == nil {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            })
            
            
            let query = PFQuery(className: "Messages")
            query.whereKey("friend", equalTo: self.room)
            query.findObjectsInBackgroundWithBlock({ (objs:[AnyObject]!, error) -> Void in
                if error == nil {
                    for obj in objs {
                        let ob = obj as! PFObject
                        ob.deleteInBackground()
                    }
                }else{
                    errorCode = 1
                }
            })
            
        } else if buttonIndex == 2 { // view orofile
            
            let userprofilevc = storyb.instantiateViewControllerWithIdentifier("userprofilevc") as! UserProfileViewController
            userprofilevc.profileUser = self.incomingUser
            self.navigationController?.pushViewController(userprofilevc, animated: true)

            
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pic:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let message = Message()
        
        
        message.content = "[sent a photo]"
        message.friend = incomingUser;
        message.room = room
        message.picf = pic
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 2
        reqNumTwo = reqNumTwo + 1
        
        if(rate > 0){
            self.sendMessage(message)
            rate = rate - 1
        }
        else{
            MsgArray.append(message)
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        
        //self.sendMessage("[sent a photo]", pic: pic)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMessages", name: "reloadMessages", object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
    }
    
    
    // MARK: - LOAD MESSAGES
    func loadMessages(){
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        if( rate > 0 ){
            rate = rate - 1
            
            var lastMessage:JSQMessage? = nil
            
            if messages.last != nil {
                lastMessage = messages.last
            }
            
            
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.whereKey("friend", equalTo: room)
            messageQuery.orderByDescending("createdAt")
            messageQuery.limit = 50
            messageQuery.includeKey("user")
            
            if lastMessage != nil {
                messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date)
            }
            
            messageQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                    var messages = results as! [PFObject]
                    
                    messages = messages.reverse()
                    
                    for message in messages{
                        self.messageObjects.append(message)
                        self.addMessage(message)
                    }
                    
                    if results.count != 0 {
                        self.finishReceivingMessage()
                    }
                    
                }else{
                    let alert = UIAlertView(title: "error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                    errorCode = 1
                }
            }
        }else{
            let alert = UIAlertView(title: "Error", message: "The server is busy now, please try it a few mins later!", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
   
    func addMessage(object:PFObject) {
        let user = object["user"] as! PFUser
        self.users.append(user)
        self.senderId = currentuser.objectId
        
        if let photo = object.objectForKey("image") as? PFFile {
            let mediaItem :JSQPhotoMediaItem = JSQPhotoMediaItem(image: nil)

            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: object.createdAt, media: mediaItem)
            self.messages.append(chatMessage)
            
            photo.getDataInBackgroundWithBlock { (dpdata, error) -> Void in
                    if error == nil {
                        mediaItem.image = UIImage(data: dpdata)
                        self.collectionView!.reloadData() //!
                    }
                }
        } else {
            let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: object.createdAt, text: object["content"] as! String + "   ")
            self.messages.append(chatMessage)
        }
    }
    
    
    // MARK: - SEND MESSAGES
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = Message()
        
        message.content = text
        message.friend = incomingUser
        message.room = room
        message.picf = nil
        
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 2
        reqNumTwo = reqNumTwo + 1
        
        if(rate > 0){
            self.sendMessage(message)
            rate = rate - 1
        }
        else{
            MsgArray.append(message)
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        self.finishSendingMessage()
        
    }
    
    func sendMessage(theMessage:Message) {
        
        var picf:PFFile!
        let pic = theMessage.picf
        let friend = theMessage.friend
        room = theMessage.room
        
        let message = PFObject(className: "Messages")
        
        if pic != nil {
            picf = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(pic!, 0.8)) //!
            picf.saveInBackgroundWithBlock({ (done:Bool, error:NSError!) -> Void in
                if error == nil { print("photo sent") }
            })
            message["image"] = picf
        }
        
        message["content"] = theMessage.content
        message["friend"] = theMessage.room
        message["user"] = currentuser
        
        
        let pushText = "\(currentuser.objectForKey("name")): \(theMessage.content)"
        message.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let pushQuery = PFInstallation.query()
                pushQuery.whereKey("user", equalTo: friend)
                
                let push = PFPush()
                push.setQuery(pushQuery)
            
                let pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
                
                push.setData(pushDict)
                push.sendPushInBackground()
                
                self.room["lastUpdate"] = NSDate()
                self.room.saveInBackgroundWithBlock(nil)
                self.loadMessages()
                
            } else{
                errorCode = 1
                print("error sending message \(error.localizedDescription)")
                let alert = UIAlertView(title: "error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "Ok")
                alert.show()
            }
            
        }
    }
    
    
    // MARK: - DELEGATE METHODS
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == currentuser.objectId {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == currentuser.objectId {
          
            return selfAvatar
        } else {
           
            return incomingAvatar
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.avatarImageView!.layer.borderWidth = 0.1 //!
        cell.avatarImageView!.layer.masksToBounds = true //!
        let message = messages[indexPath.row]
        
        // run if only TextView is available
        if (cell.textView != nil) {
            if message.senderId == currentuser.objectId {
            
                cell.textView!.backgroundColor = UIColor.clearColor() //!
                
          
            } else {
                    cell.textView!.backgroundColor =  UIColor.clearColor()  //!
                cell.textView!.textColor = UIColor.whiteColor()  //!
            }
            
            cell.avatarImageView!.layer.cornerRadius = 15  //!
            cell.textView!.layer.masksToBounds = true  //!
            cell.textView!.textColor = UIColor.blackColor()  //!

            
        }
        

        return cell
        
    }
    
    
    

    
    // MARK: - DATASOURCE
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let object = self.messageObjects[indexPath.row] as PFObject

        
        if let photo = object.objectForKey("image") as? PFFile {

            photo.getDataInBackgroundWithBlock { (dpdata, error) -> Void in
                if error == nil {
                    let imgvc = GGFullscreenImageViewController()
                    imgvc.liftedImageView = UIImageView(image: UIImage(data: dpdata)!)
                    self.presentViewController(imgvc, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
    }
    

    

}
