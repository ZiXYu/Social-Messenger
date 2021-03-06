//
//  ChatTableViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {
    
    
    var rooms = [PFObject]()
    var users = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = backColor
        self.navigationItem.title = "Loading ..."
        
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayPushMessage:", name: "displayMessage", object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "displayMessage", object: nil)
    }
    
    
    func displayPushMessage (notification:NSNotification) {
        loadData()
        let notificationDict = notification.object as! NSDictionary
        
        if let aps = notificationDict.objectForKey("aps") as? NSDictionary {
            let messageText = aps.objectForKey("alert") as! String
            
            let alert = UIAlertController(title: "New Message", message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            
          //  self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    func loadData(){
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        rooms = [PFObject]()
        users = [PFUser]()
        
      //  self.tableView.reloadData()
        
        let pred = NSPredicate(format: "requestBy = %@ OR requestTo = %@", currentuser, currentuser)
        
        let query = PFQuery(className: "Friends", predicate: pred)
        query.orderByDescending("updatedAt")
        query.whereKey("accepted", equalTo: true)

        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                self.rooms = results as! [PFObject]

                self.navigationItem.title = "\(results.count) Chat"
                for room in self.rooms {
                    let user1 = room.objectForKey("requestBy") as! PFUser
                    let user2 = room.objectForKey("requestTo") as! PFUser
                    
                    if user1.objectId != currentuser.objectId {
                        self.users.append(user1)
                    }
                    
                    if user2.objectId != currentuser.objectId {
                        self.users.append(user2)
                    }
                }
                
                self.tableView.reloadData()
                
                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            } else {
                errorCode = 1
                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            }
        
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if rooms.count > 0 {
            return rooms.count
        }
         return 1
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if rooms.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("nochatcell", forIndexPath: indexPath) 
            return cell

        } else {
            
            
                
                let cell = tableView.dequeueReusableCellWithIdentifier("chatcell", forIndexPath: indexPath) as! ChatViewCell
                let targetObject = rooms[indexPath.row] as PFObject
                let targetUser = users[indexPath.row] as PFUser
                
                cell.timeAgo.text = "\(targetObject.updatedAt.formattedAsTimeAgo())"
                cell.backgroundColor = UIColor.clearColor()
            
                cell.timeAgo.textColor = colorText
                cell.nameUser.textColor = colorText
                cell.lastMessage.textColor = colorText
            
            
                let userget = PFUser.query()
                userget.whereKey("objectId", equalTo: targetUser.objectId)
                userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        if let fUser = objects.last as? PFUser {
                            cell.nameUser.text = fUser.objectForKey("name") as? String
                            if let pica = fUser.objectForKey("dpSmall") as? PFFile {
                                pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                                    if error == nil {
                                        cell.userdp.image = UIImage(data: data)
                                        cell.userdp.layer.borderColor = colorText.CGColor
                                        circleBorder(cell.userdp)
                                    }
                                })
                            }

                        }
                    }else{
                        errorCode = 1
                    }
                }
                
                let getlastmsg = PFQuery(className: "Messages")
                getlastmsg.whereKey("friend", equalTo: targetObject)
                getlastmsg.orderByDescending("createdAt")
                getlastmsg.limit = 1
                getlastmsg.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        if let msg = objects.last as? PFObject {
                            cell.lastMessage.text = msg.objectForKey("content") as? String
                        }
                        if objects.count == 0 {
                            cell.lastMessage.text = ""
                        }
                    }else{
                        errorCode = 1
                    }
                }
                circleBorder(cell.userdp)
                return cell
        }

    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if rooms.count > 0 {
            let messagesVC = storyb.instantiateViewControllerWithIdentifier("messagesvc") as! ChatMessagesViewController
            let user2 = users[indexPath.row] as PFUser
            let targetObject = rooms[indexPath.row] as PFObject
            messagesVC.room = targetObject
            messagesVC.incomingUser = user2
            messagesVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(messagesVC, animated: true)
        }
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if rooms.count > 0 {
            return 66
        } else {
            return phoneheight/2
        }
    }
    
    
}
