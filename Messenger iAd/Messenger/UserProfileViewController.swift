//
//  UserProfileViewController.swift
//  Messenger
//
//  Created by DJay on 30/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController {

    var updates = NSMutableArray()
    var profileUser:PFUser!
    
    
    @IBOutlet weak var usersName: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userId: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadUpdates()
        
        usersName.textColor = colorText
        self.tableView.backgroundColor = backColor
        self.usersName.text = profileUser.objectForKey("name") as? String
        self.userId.textColor = colorText
        self.userId.text = "Username: " + profileUser.username
        
        if let dp = profileUser.objectForKey("dpSmall") as? PFFile {
            dp.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    var img = UIImage(data: data)
                    self.profilePic.image = img
                }
            })
        }
        
    }
    
    
    
    @IBAction func sendMessage(sender: UIButton) {
        
        if profileUser.objectId != currentuser.objectId {
            MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            let pred = NSPredicate(format: "requestBy = %@ AND requestTo = %@ OR requestBy = %@ AND requestTo = %@", currentuser, profileUser, profileUser, currentuser)
            
            var query = PFQuery(className: "Friends", predicate: pred)
            
            query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                   MBProgressHUD.hideHUDForView(self.tableView, animated: true)
                    
                    let messagesVC = storyb.instantiateViewControllerWithIdentifier("messagesvc") as! ChatMessagesViewController
                    let user1 = currentuser
                    let user2 = self.profileUser
                    let targetObject = results.last as! PFObject
                    messagesVC.room = targetObject
                    messagesVC.incomingUser = user2
                    messagesVC.hidesBottomBarWhenPushed = true
                    
                    self.navigationController?.pushViewController(messagesVC, animated: true)

                } else {
                    MBProgressHUD.hideHUDForView(self.tableView, animated: true)
                    
                }
                
            }

        }
    }
    
    
    @IBAction func viewPic(sender: UIButton) {
        var imgvc = GGFullscreenImageViewController()
        imgvc.liftedImageView = UIImageView(image: self.profilePic.image)
        self.presentViewController(imgvc, animated: true, completion: nil)
    }

    func loadUpdates() {
        var activityQuery = PFQuery(className: "Activity")
        activityQuery.whereKey("user", equalTo: profileUser)
        activityQuery.orderByDescending("updatedAt")
        activityQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.updates.removeAllObjects()
                self.updates.addObjectsFromArray(objects)
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - Table view data source

   

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.updates.count > 0 {
            return self.updates.count
        } else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.updates.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("profileupdatescell", forIndexPath: indexPath) as! ProfileUpdatesViewCell
            
            let activity = self.updates[indexPath.row] as! PFObject
            cell.updateLabel.textColor = colorText
            
            var content = activity.objectForKey("content") as! String
            
            var userget = PFUser.query()
            userget.whereKey("objectId", equalTo: activity.objectForKey("user").objectId)
            userget.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                    if let fUser = objects.last as? PFUser {
                        
                        var name = fUser.objectForKey("name") as! String
                        var type = activity.objectForKey("type") as! String
                        var timeUpdated = activity.createdAt.formattedAsTimeAgo()
                        
                        if iOS8 {
                            var nameString = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.1)])
                            
                            var timeString = NSMutableAttributedString(string: timeUpdated, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12, weight: 0.1)])
                            
                            
                            if type == "nameUpdated" {
                                var updateString = NSMutableAttributedString(string: " updated Name.      ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
                                nameString.appendAttributedString(updateString)
                                nameString.appendAttributedString(timeString)
                                cell.updateLabel.attributedText = nameString
                            } else if type == "statusUpdated" {
                                var updateString = NSMutableAttributedString(string: " said \"\(content)\". ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
                                nameString.appendAttributedString(updateString)
                                nameString.appendAttributedString(timeString)
                                cell.updateLabel.attributedText = nameString
                            } else if type == "picUpdated" {
                                var updateString = NSMutableAttributedString(string: " changed Display Picture. ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: 0.2)])
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
                }
            }
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("profilenoupdatescell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = "No updates to Show"
            cell.textLabel?.textColor = colorText
            
            return cell
        }
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if self.updates.count > 0 {
            let activity = self.updates[indexPath.row] as! PFObject
            var type = activity.objectForKey("type") as! String
            var content = activity.objectForKey("content") as! String
            if type == "statusUpdated" {
                var font = UIFont.systemFontOfSize(18.0)
                if iOS8 {
                    font = UIFont.systemFontOfSize(16.0, weight: 0.3)
                }
                let size = CGSizeMake(phonewidth - 70,CGFloat.max)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .ByWordWrapping
                let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy()]
                
                var text = content + "ABCDEFGHIJKLMNOP" as NSString
                let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
                var height = rect.size.height
                if height < 50 {
                    return 60
                } else {
                    return height
                }
            } else {
                return 60
            }
        } else {
            return 300
        }
    }

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
}







