//
//  SearchViewController.swift
//  Messenger
//
//  Created by DJay on 25/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
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
        self.seach.resignFirstResponder()
        var userSearchtext = self.seach.text.lowercaseString
        if seach.text.isEmpty == false {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            var userSearch = PFUser.query()
            userSearch.whereKey("username", equalTo: userSearchtext)
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
                        self.username.text = "Username: \(self.seach.text)"
                        self.requestButton.enabled = true
                        self.requestButton.setTitle("Send Request", forState: UIControlState.allZeros)
                        if let dp = self.foundUser.objectForKey("dpSmall") as? PFFile {
                            dp.getDataInBackgroundWithBlock { (data, error) -> Void in
                                var img = UIImage(data: data)
                                self.userPic.image = img
                            }
                        }
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        if self.foundUser.objectId == currentuser.objectId {
                            self.requestButton.enabled = false
                            self.requestButton.setTitle("", forState: UIControlState.allZeros)
                        }
                        for friend in contacts {
                            let cont = friend as PFUser
                            if cont.objectId == self.foundUser.objectId {
                                self.requestButton.enabled = false
                                self.requestButton.setTitle("Cannot Send Request", forState: UIControlState.allZeros)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.seach.resignFirstResponder()
        self.userFoundView.hidden = true
        searchBar.text = ""
    }
    

    @IBAction func sendRequest(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let pred = NSPredicate(format: "requestBy = %@ AND requestTo = %@ OR requestBy = %@ AND requestTo = %@", currentuser, foundUser, currentuser, foundUser)
        
        var friends = PFQuery(className: "Friends", predicate: pred)
        friends.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                if objects.count > 0 {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let obj = objects.last as? PFObject {
                        if obj.objectForKey("requestBy").objectId == currentuser.objectId {
                            self.requestButton.enabled = false
                            self.requestButton.setTitle("Request Already Sent", forState: UIControlState.allZeros)
                        } else {
                            obj["accepted"] = true
                            obj.saveInBackgroundWithBlock({ (done, error) -> Void in
                                self.requestButton.enabled = false
                                self.requestButton.setTitle("You both are Friends Now", forState: UIControlState.allZeros)
                            })

                        }
                    }
                } else {
                    var friend = PFObject(className: "Friends")
                    friend["requestBy"] = currentuser
                    friend["requestTo"] = self.foundUser
                    friend["lastUpdate"] = NSDate()
                    friend.saveInBackgroundWithBlock({ (done, error) -> Void in
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.requestButton.enabled = false
                        self.requestButton.setTitle("Request Sent", forState: UIControlState.allZeros)
                        var pushText = "\(self.foundUser.username) sent you friend request."
                        let pushQuery = PFInstallation.query()
                        pushQuery.whereKey("user", equalTo: self.foundUser)
                        
                        let push = PFPush()
                        push.setQuery(pushQuery)
                        
                        let pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
                        
                        push.setData(pushDict)
                        push.sendPushInBackgroundWithBlock(nil)
                        
                    })
                }
            }
        }
        
    }
    

    
    
}









