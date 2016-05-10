//
//  RequestViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
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
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        if rate > 0 {
            rate = rate - 1
            let query = PFQuery(className: "Friends")
            query.whereKey("requestTo", equalTo: currentuser)
            query.whereKeyDoesNotExist("accepted")
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    self.requests.removeAllObjects()
                    self.requests.addObjectsFromArray(objects)
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
            
            let request = requests[indexPath.row] as! PFObject
            
            let findUser = PFUser.query()
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
                }else{
                    errorCode = 1
                }

            })
            
            circleBorder(cell.requestPic)
            
            cell.accept.addTarget(self, action: "acceptRequest:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.reject.addTarget(self, action: "rejectRequest:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.accept.tag = indexPath.row
            cell.reject.tag = indexPath.row
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("norequestcell", forIndexPath: indexPath) 
            
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
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 1
        reqNumOne = reqNumOne + 1
       
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        let request = requests[sender.tag] as! PFObject
        request["accepted"] = true
        request["lastUpdate"] = NSDate()
        if rate > 0 {
            processRequest(request)
        }else{
            ReqArray.append(request)
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        MBProgressHUD.hideHUDForView(self.tableView, animated: true)
        self.loadRequests()
    
    }
    
    
    
    
    func rejectRequest(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        let request = requests[sender.tag] as! PFObject
        request["accepted"] = false
        request["lastUpdate"] = NSDate()
        if rate > 0 {
            processRequest(request)
        }else{
            ReqArray.append(request)
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        
        processRequest(request)
        MBProgressHUD.hideHUDForView(self.tableView, animated: true)
        self.loadRequests()
    }
    
    func processRequest( request : PFObject ){
        rate = rate - 1
        request.saveInBackgroundWithBlock{ (done, error) -> Void in
        }
    }
    
}






