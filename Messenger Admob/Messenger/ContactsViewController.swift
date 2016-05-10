//
//  ContactsViewController.swift
//  Messenger
//
//  Created by DJay on 22/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import GoogleMobileAds

var contacts = [PFUser]()
var contactUpdates = NSMutableArray()
class ContactsViewController: UITableViewController, GADBannerViewDelegate  {

    
    var rooms = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadContacts()
        self.tableView.backgroundColor = backColor
        
        
    }

    override func viewWillAppear(animated: Bool) {
        
    }

    
    @IBAction func reloadContacts(sender: AnyObject) {
        self.loadContacts()
    }
    
    
    func loadContacts() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let pred = NSPredicate(format: "requestBy = %@ OR requestTo = %@", currentuser, currentuser)
        contacts.removeAll(keepCapacity: false)
        var query = PFQuery(className: "Friends", predicate: pred)
        query.orderByDescending("updatedAt")
        query.whereKey("accepted", equalTo: true)
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                self.rooms = results as! [PFObject]
                contactUpdates.removeAllObjects()
                self.navigationItem.title = "\(results.count) Contacts"
                for room in results {
                    let user1 = room.objectForKey("requestBy") as! PFUser
                    let user2 = room.objectForKey("requestTo") as! PFUser
                    
                    if user1.objectId != currentuser.objectId {
                        contacts.append(user1)
                        contactUpdates.addObject(room)
                    }
                    
                    if user2.objectId != currentuser.objectId {
                        contacts.append(user2)
                        contactUpdates.addObject(room)
                    }
                }
                
                self.tableView.reloadData()

                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            } else {
                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
                
            }
            
        }
        
        
    }
    
    
    
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if contacts.count > 0 {
            return contacts.count
        } else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if contacts.count < 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("nocontactscell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactscell", forIndexPath: indexPath) as! ContactsViewCell
            var contact = contacts[indexPath.row] as PFUser
            contact.fetchIfNeeded()
            var userName = contact.objectForKey("name") as? String
            cell.contactName.text = userName
            cell.contactName.textColor = colorText
            var userStatus = contact.objectForKey("status") as? String
            cell.contactStatus.text = userStatus
            cell.contactStatus.textColor = colorText
            
            if let pica = contact.objectForKey("dpSmall") as? PFFile {
                pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                    if error == nil {
                        cell.contactPic.image = UIImage(data: data)
                        cell.contactPic.layer.borderColor = colorText.CGColor
                        circleBorder(cell.contactPic)
                    }
                })
            } 
                        
            circleBorder(cell.contactPic)
            
            
            
            return cell

        }
        
        
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if contacts.count > 0 {            
            let userprofilevc = storyb.instantiateViewControllerWithIdentifier("userprofilevc") as! UserProfileViewController
            userprofilevc.profileUser = contacts[indexPath.row] as PFUser
            self.navigationController?.pushViewController(userprofilevc, animated: true)
        }
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if contacts.count > 0 {
            var contact = contacts[indexPath.row] as PFUser
            contact.fetchIfNeeded()
            var status = contact.objectForKey("status") as! String
            let font = UIFont.systemFontOfSize(15)
            let size = CGSizeMake(phonewidth - 90,CGFloat.max)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy()]
            
            let text = status as NSString
            let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
            var height = rect.size.height + 25
            if height < 76 {
                return 76
            } else {
                return height
            }
            
        } else {
            return phoneheight/2
        }
    }

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var bannerView:GADBannerView = GADBannerView(frame: CGRectMake(0, 0, phonewidth, 50))
        bannerView.rootViewController = self
        bannerView.adUnitID = admobId
        bannerView.delegate = self
        var request = GADRequest()
        bannerView.loadRequest(request)
        return bannerView
    }
    
    
    


}



