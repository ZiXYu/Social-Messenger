//
//  SearchViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate{

    @IBOutlet weak var seach: UISearchBar!
    
    @IBOutlet weak var noUserText: UILabel!
    @IBOutlet weak var userFoundView: UIView!
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var displayname: UILabel!
    var foundUser:PFUser!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = backColor
        self.userFoundView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.userFoundView.hidden = true
        self.noUserText.text = "Type the UserName to search"
        self.noUserText.textColor = colorText
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        self.seach.resignFirstResponder()
        let userSearchtext = self.seach.text
        if seach.text!.isEmpty == false {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if rate > 0 {
                rate = rate - 1
                
                let userSearch = PFUser.query()
                userSearch.whereKey("name", equalTo: userSearchtext)
                userSearch.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        if objects.count < 1 {
                            self.userFoundView.hidden = true
                            self.noUserText.text = "No User Found with username \"\(self.seach.text)\"."
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                        } else {
                            self.userFoundView.hidden = false
                            self.foundUser = objects.last as! PFUser
                            self.displayname.text = self.foundUser.objectForKey("name") as? String
                            self.username.text = "Username: \(self.seach.text!)"
                            self.requestButton.enabled = true
                            self.requestButton.setTitle("Send Request", forState: UIControlState())
                            if let dp = self.foundUser.objectForKey("dpSmall") as? PFFile {
                                dp.getDataInBackgroundWithBlock { (data, error) -> Void in
                                    let img = UIImage(data: data)
                                    self.userPic.image = img
                                }
                            }
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            if self.foundUser.objectId == currentuser.objectId {
                                self.requestButton.enabled = false
                                self.requestButton.setTitle("", forState: UIControlState())
                            }
                            for friend in contacts {
                                let cont = friend as PFUser
                                if cont.objectId == self.foundUser.objectId {
                                    self.requestButton.enabled = false
                                    self.requestButton.setTitle("Cannot Send Request", forState: UIControlState())
                                }
                            }
                        }
                    }else{
                        errorCode = 1
                    }
                }
            }else{
                let alert = UIAlertView(title: "Error", message: "The server is busy now, please try it a few mins later!", delegate: self, cancelButtonTitle: "Ok")
                alert.show()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.seach.resignFirstResponder()
        self.userFoundView.hidden = true
        searchBar.text = ""
    }
    

    @IBAction func sendRequest(sender: AnyObject) {
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 1
        reqNumThe = reqNumThe + 1
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let friendRequest = FriendRequest()
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components( .Minute, fromDate: date)
        let minutes = components.minute
        
        friendRequest.toFriend = foundUser
        friendRequest.time = minutes
        if(rate > 0){
            rate = rate - 1
            sendRequest2(friendRequest)
        }else{
            FRArray.append(friendRequest)
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.requestButton.enabled = false
        self.requestButton.setTitle("Request Sent", forState: UIControlState())
        
    }
    
    func sendRequest2( friend : FriendRequest ){
        foundUser = friend.toFriend
        
        let pred = NSPredicate(format: "requestBy = %@ AND requestTo = %@ OR requestBy = %@ AND requestTo = %@", currentuser, foundUser, currentuser, foundUser)
        
        let friends = PFQuery(className: "Friends", predicate: pred)
        friends.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                if objects.count > 0 {
                    //MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let obj = objects.last as? PFObject {
                        if obj.objectForKey("requestBy").objectId == currentuser.objectId {
                            //self.requestButton.enabled = false
                            //self.requestButton.setTitle("Request Already Sent", forState: UIControlState.allZeros)
                            let alert = UIAlertView(title: "Error", message: "Request Already Sent!", delegate: self, cancelButtonTitle: "Ok")
                            alert.show()
                            
                        } else {
                            obj["accepted"] = true
                            obj.saveInBackgroundWithBlock({ (done, error) -> Void in
                                //self.requestButton.enabled = false
                                //self.requestButton.setTitle("You both are Friends Now", forState: UIControlState.allZeros)
                                let alert = UIAlertView(title: "Error", message: "You both are already friends!", delegate: self, cancelButtonTitle: "Ok")
                                alert.show()
                            })
                            
                        }
                    }
                } else {
                    let friend = PFObject(className: "Friends")
                    friend["requestBy"] = currentuser
                    friend["requestTo"] = self.foundUser
                    friend["lastUpdate"] = NSDate()
                    friend.saveInBackgroundWithBlock({ (done, error) -> Void in
                        //MBProgressHUD.hideHUDForView(self.view, animated: true)
                        //self.requestButton.enabled = false
                        //self.requestButton.setTitle("Request Sent", forState: UIControlState.allZeros)
                        var pushText = "\(currentuser.username) sent you friend request."
                        let pushQuery = PFInstallation.query()
                        pushQuery.whereKey("user", equalTo: self.foundUser)
                        
                        let push = PFPush()
                        push.setQuery(pushQuery)
                        
                        var pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
                        
                        push.setData(pushDict)
                        push.sendPushInBackgroundWithBlock(nil)
                        
                        pushText = "Your friend request to \(self.foundUser) is sent successfully!"
                        pushQuery.whereKey("user", equalTo: currentuser)
                        push.setQuery(pushQuery)
                        
                        pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
                        
                        push.setData(pushDict)
                        push.sendPushInBackgroundWithBlock(nil)
                        
                    })
                }
            }else{
                errorCode = 1
            }
        }
        
        
    }


    
    
}









