//
//  RequestViewController.swift
//  Messenger
//
//  Created by DJay on 28/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class RequestViewController: UITableViewController {

    var requests = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadRequests()
        self.tableView.backgroundColor = backColor
        
    }

    func loadRequests() {
        var query = PFQuery(className: "Friends")
        query.whereKey("requestTo", equalTo: currentuser)
        query.whereKeyDoesNotExist("accepted")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.requests.removeAllObjects()
                self.requests.addObjectsFromArray(objects)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if requests.count > 0 {
            return requests.count
        } else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        if requests.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("requestcell", forIndexPath: indexPath) as! RequestViewCell
            
            var request = requests[indexPath.row] as! PFObject
            
            var findUser = PFUser.query()
            findUser.whereKey("objectId", equalTo: request.objectForKey("requestBy").objectId)
            findUser.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    if let fUser = objects.last as? PFUser {
                        cell.requestNae.text = fUser.objectForKey("name") as? String
                        cell.requestNae.textColor = colorText
                        if let pica = fUser.objectForKey("dpSmall") as? PFFile {
                            pica.getDataInBackgroundWithBlock({ (data:NSData!, error:NSError!) -> Void in
                                if error == nil {
                                    cell.requestPic.image = UIImage(data: data)
                                    cell.requestPic.layer.borderColor = colorText.CGColor
                                    
                                }
                            })
                        }
                        
                    }
                }

            })
            
            circleBorder(cell.requestPic)
            
            cell.accept.addTarget(self, action: "acceptRequest:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.reject.addTarget(self, action: "rejectRequest:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.accept.tag = indexPath.row
            cell.reject.tag = indexPath.row
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("norequestcell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = "No requests Pending"
            
            return cell
        }
    }
    

   
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if requests.count > 0 {
            return 74
        } else {
            return 300
        }
    }
    
    
    func acceptRequest(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        var request = requests[sender.tag] as! PFObject
        request["accepted"] = true
        request["lastUpdate"] = NSDate()
        request.saveInBackgroundWithBlock { (done, error) -> Void in
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            self.loadRequests()
            var findUser = PFUser.query()
            findUser.whereKey("objectId", equalTo: request.objectForKey("requestBy").objectId)
            findUser.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    if let fUser = objects.last as? PFUser {
                        var pushText = "\(fUser.username) accepted you request."
                        let pushQuery = PFInstallation.query()
                        pushQuery.whereKey("user", equalTo: fUser)
                        
                        let push = PFPush()
                        push.setQuery(pushQuery)
                        
                        let pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
                        
                        push.setData(pushDict)
                        push.sendPushInBackgroundWithBlock(nil)
                        
                    }
                }
                
            })
            
            
        }
    }
    
    
    func rejectRequest(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        var request = requests[sender.tag] as! PFObject
        request["accepted"] = false
        request["lastUpdate"] = NSDate()
        request.saveInBackgroundWithBlock { (done, error) -> Void in
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            self.loadRequests()
        }
    }
    
    
    
    
    
    
    
}






