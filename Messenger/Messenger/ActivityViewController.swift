//
//  ActivityViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class ActivityViewController: UITableViewController {

    var updates = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = backColor
        self.navigationItem.title = "Updates"
        loadUpdates()
    }

    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    func loadUpdates() {
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        if(rate > 0){
            rate = rate - 1
            
            let activityQuery = PFQuery(className: "Activity")
            activityQuery.whereKey("user", containedIn: contacts)
            activityQuery.orderByDescending("updatedAt")
            activityQuery.limit = 100
            activityQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    self.updates.removeAllObjects()
                    self.updates.addObjectsFromArray(contactUpdates as [AnyObject])
                    self.updates.addObjectsFromArray(objects)
                    let sort = NSSortDescriptor(key: "createdAt", ascending: false)
                    self.updates.sortUsingDescriptors([sort])
                    self.tableView.reloadData()
                }else{
                    errorCode = 1
                }
            }
            
        }else{
            let alert = UIAlertView(title: "Error", message: "The server is busy now, please try it a few mins later!", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
        
        }
        
    }

    // MARK: - Table view data source

   
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.loadUpdates()
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.updates.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activitycell", forIndexPath: indexPath) as! ActivityViewCell
        
        let activity = self.updates[indexPath.row] as! PFObject
        cell.updateLabel.textColor = colorText
        let timeUpdated = activity.createdAt.formattedAsTimeAgo()
        let timeString = NSMutableAttributedString(string: timeUpdated, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12, weight: 0.1)])
        
        if let content = activity.objectForKey("content") as? String {
            let userget = PFUser.query()
            userget.whereKey("objectId", equalTo: activity.objectForKey("user").objectId)
            userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                    if let fUser = objects.last as? PFUser {
                        
                        let name = fUser.objectForKey("name") as! String
                        let type = activity.objectForKey("type") as! String
                        
                        
                        if iOS8 {
                            let nameString = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.1)])
                                                        
                            
                            if type == "nameUpdated" {
                                let updateString = NSMutableAttributedString(string: " updated Name.      ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
                                nameString.appendAttributedString(updateString)
                                nameString.appendAttributedString(timeString)
                                cell.updateLabel.attributedText = nameString
                            } else if type == "statusUpdated" {
                                let updateString = NSMutableAttributedString(string: " said \"\(content)\". ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
                                nameString.appendAttributedString(updateString)
                                nameString.appendAttributedString(timeString)
                                cell.updateLabel.attributedText = nameString
                            } else if type == "picUpdated" {
                                let updateString = NSMutableAttributedString(string: " changed Display Picture. ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
                                nameString.appendAttributedString(updateString)
                                nameString.appendAttributedString(timeString)
                                cell.updateLabel.attributedText = nameString
                            }
                        } else {
                            if type == "nameUpdated" {
                                
                                cell.updateLabel.text = "\(name) updated Name. \(timeUpdated)"
                            } else if type == "statusUpdated" {
                                
                                cell.updateLabel.text = "\(name) said \"\(content)\". \(timeUpdated)"
                            } else if type == "picUpdated" {
                                
                                cell.updateLabel.text = "\(name) changed Display Picture. \(timeUpdated)"
                            }
                        }
                        
                        
                        if let pica = fUser.objectForKey("dpSmall") as? PFFile {
                            pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                                if error == nil {
                                    cell.userDp.image = UIImage(data: data)
                                    cell.userDp.layer.borderColor = colorText.CGColor
                                    // circleBorder(cell.userDp)
                                }
                            })
                        }
                        
                    }
                }else{
                    errorCode = 1
                }
            }

        } else {
            let user1 = activity.objectForKey("requestBy") as! PFUser
            let user2 = activity.objectForKey("requestTo") as! PFUser
            
            if user1.objectId != currentuser.objectId {
                user1.fetchIfNeeded()
                let nameString = NSMutableAttributedString(string: user1.objectForKey("name") as! String + " is now a contact. ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.1)])
                nameString.appendAttributedString(timeString)
                cell.updateLabel.attributedText = nameString
                if let pica = user1.objectForKey("dpSmall") as? PFFile {
                    pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                        if error == nil {
                            cell.userDp.image = UIImage(data: data)
                            cell.userDp.layer.borderColor = colorText.CGColor
                            // circleBorder(cell.userDp)
                        }
                    })
                }
            }
            
            if user2.objectId != currentuser.objectId {
                user2.fetchIfNeeded()
                let nameString = NSMutableAttributedString(string: user2.objectForKey("name") as! String + " is now a contact. ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.1)])
                nameString.appendAttributedString(timeString)
                cell.updateLabel.attributedText = nameString
                if let pica = user2.objectForKey("dpSmall") as? PFFile {
                    pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                        if error == nil {
                            cell.userDp.image = UIImage(data: data)
                            cell.userDp.layer.borderColor = colorText.CGColor
                            // circleBorder(cell.userDp)
                        }
                    })
                }
            }

        }
        
        

        return cell
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let activity = self.updates[indexPath.row] as! PFObject
        if let type = activity.objectForKey("type") as? String {
            let content = activity.objectForKey("content") as! String
            if type == "statusUpdated" {
                var font = UIFont.systemFontOfSize(18.0)
                if iOS8 {
                    font = UIFont.systemFontOfSize(16.0, weight: 0.3)
                }
                let size = CGSizeMake(phonewidth - 70,CGFloat.max)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .ByWordWrapping
                let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy()]
                
                let text = content + "ABCDEFGHIJKLMNOP Time Ago" as NSString
                let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
                let height = rect.size.height + 16
                if height < 60 {
                    return 60
                } else {
                    return height
                }
            } else {
                return 60
            }
        } else {
            return 60
        }
    }



    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let activity = self.updates[indexPath.row] as! PFObject
        if let content = activity.objectForKey("content") as? String {
            let userget = PFUser.query()
            userget.whereKey("objectId", equalTo: activity.objectForKey("user").objectId)
            userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                    let userprofilevc = storyb.instantiateViewControllerWithIdentifier("userprofilevc") as! UserProfileViewController
                    userprofilevc.profileUser = objects.last as! PFUser
                    self.navigationController?.pushViewController(userprofilevc, animated: true)
                }else{
                    errorCode = 1
                }
            }
        } else {
            let user1 = activity.objectForKey("requestBy") as! PFUser
            let user2 = activity.objectForKey("requestTo") as! PFUser
            if user1.objectId != currentuser.objectId {
                let userget = PFUser.query()
                userget.whereKey("objectId", equalTo: user1.objectId)
                userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        let userprofilevc = storyb.instantiateViewControllerWithIdentifier("userprofilevc") as! UserProfileViewController
                        userprofilevc.profileUser = objects.last as! PFUser
                        self.navigationController?.pushViewController(userprofilevc, animated: true)
                    }else{
                        errorCode = 1
                    }
                }
            }
            
            if user2.objectId != currentuser.objectId {
                let userget = PFUser.query()
                userget.whereKey("objectId", equalTo: user2.objectId)
                userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        let userprofilevc = storyb.instantiateViewControllerWithIdentifier("userprofilevc") as! UserProfileViewController
                        userprofilevc.profileUser = objects.last as! PFUser
                        self.navigationController?.pushViewController(userprofilevc, animated: true)
                    }else{
                        errorCode = 1
                    }
                }
            }

            
        }
        
        
        
    }




}








