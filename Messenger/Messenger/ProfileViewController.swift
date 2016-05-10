//
//  ProfileViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit
import Social

var statusChanged = false
class ProfileViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate {

    
    @IBOutlet weak var displayNameText: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    var currentname:String!
    var status:String!
    @IBOutlet weak var currentusername: UILabel!
    @IBOutlet weak var numberOfRequests: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberOfRequests.textColor = backColor
        self.numberOfRequests.backgroundColor = borderColor
        self.numberOfRequests.layer.cornerRadius = 10
        self.numberOfRequests.layer.masksToBounds = true
        self.numberOfRequests.text = "0"
        statusChanged = false
        let username = currentuser.username
        self.tableView.backgroundColor = backColor
        currentusername.textColor = colorText
        self.displayNameText.textColor = colorText
        statusLabel.textColor = colorText
        currentusername.text = "User ID: \(username)"
        status = currentuser.objectForKey("status") as? String
        circleBorder(self.userPic)
        currentname = currentuser.objectForKey("name") as! String
        self.nameTF.text = currentname
        if let dp = currentuser.objectForKey("dpSmall") as? PFFile {
            dp.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let img = UIImage(data: data!)
                    self.userPic.image = img
                }
            })
        }
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        self.numberOfRequests.text = "0"
        status = currentuser.objectForKey("status") as? String
        self.statusLabel.text = status
        if statusChanged {
            self.tableView.reloadData()
            statusChanged = false
        }
        self.loadFriendRequests()
    }
    
    
    func loadFriendRequests() {
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        if(rate > 0){
            rate = rate - 1
            
            let friends = PFQuery(className: "Friends")
            friends.whereKey("requestTo", equalTo: currentuser)
            friends.whereKeyDoesNotExist("accepted")
            friends.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    self.numberOfRequests.text = "\(objects.count)"
                }else{
                    errorCode = 1
                }
            }
        }else{
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
    }
    
    
    
    
    
    @IBAction func editPicAction(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTF.resignFirstResponder()
        if textField.text?.characters.count < 4 || textField.text?.characters.count > 20 {
            let alert = UIAlertView(title: "Error", message: "Display Name must be between 3-20 Characters", delegate: self, cancelButtonTitle: "okay")
            alert.show()

        } else {
            if nameTF.text != currentname {
                currentuser["name"] = nameTF.text
                currentname = nameTF.text
                
                reqNumber = reqNumber + 1
                reqWeight = reqWeight + 1
                reqNumOne = reqNumOne + 1
                
                nameUpdate = 1
                
                if(rate > 0){
                    rate = rate - 1
                    saveChange()
                }else{
                    let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
                    alert.show()
                }
            }
        }
        return true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let pickedImg = info[UIImagePickerControllerEditedImage] as! UIImage
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        userPic.image = pickedImg
        
        let image = pickedImg
        let imageL = scaleImage(image, and: 320) // save 640x640 image
        let imageS = scaleImage(image, and: 60)
        let dataL = UIImageJPEGRepresentation(imageL, 0.9)
        let dataS = UIImageJPEGRepresentation(imageS, 0.9)
        currentuser["dpLarge"] = PFFile(name: "dpLarge.jpg", data: dataL)
        currentuser["dpSmall"] = PFFile(name: "dpSmall.jpg", data: dataS)
        
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 1
        reqNumOne = reqNumOne + 1
        
        picUpdate = 1
        
        if(rate > 0){
            saveChange()
            rate = rate - 1
        }
        else{
            
            let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Change name and Profile Picture"
        } else if  section == 1 {
            return "Status"
        } else {
            return "Account"
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 112
        } else if indexPath.section == 1 {
            let font = UIFont.systemFontOfSize(16)
            let size = CGSizeMake(phonewidth - 16,CGFloat.max)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy()]
            
            let text = status as NSString
            let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
            return rect.size.height + 16
        } else {
            return 40
        }
    }
    
    
  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                let alert = UIAlertView(title: "Change Username", message: "You can share your new username with your friends.", delegate: self, cancelButtonTitle: "Save")
                alert.addButtonWithTitle("Cancel")
                alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                alert.show()
            } else if indexPath.row == 2 {
                let sheet = UIActionSheet(title: "Choose One", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Facebook", "Twitter")
                sheet.showInView(self.view)

            } else if indexPath.row == 3 {
                let termsvc = storyb.instantiateViewControllerWithIdentifier("termsvc") as! TermsViewController
                self.presentViewController(termsvc, animated: true, completion: nil)
            } else if indexPath.row == 4 {
                PFUser.logOut()
                currentuser = nil
                let loginvc = storyb.instantiateViewControllerWithIdentifier("loginvc") as! LoginViewController
                self.presentViewController(loginvc, animated: true, completion: nil)
            }
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 1 { // Facebook
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let controller = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
                controller.setInitialText(shareText)
                controller.addURL(NSURL(string: appUrl) )
                self.presentViewController(controller, animated: true, completion: nil)
                controller.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.Cancelled:
                        print("fb cancel")
                    case SLComposeViewControllerResult.Done:
                        print("done")
                    }
                }
            } else {
                let alert = UIAlertView(title: "No Facebook Account", message: "Oops, you've not added facebook account in your iphone settings", delegate: self, cancelButtonTitle: "Okay")
                alert.show()
            }
        } else if buttonIndex == 2 { // Twitter
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let controller = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
                controller.setInitialText(shareText)
                controller.addURL(NSURL(string: appUrl) )
                
                self.presentViewController(controller, animated: true, completion: nil)
                controller.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.Cancelled:
                        print("fb cancel")
                    case SLComposeViewControllerResult.Done:
                        print("done")
                    }
                }
            } else {
                let alert = UIAlertView(title: "No Twitter Account", message: "Oops! Looks like you've not added Twitter account in your settings", delegate: self, cancelButtonTitle: "Okay")
                alert.show()
            }
            
        }
    }
    

    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if let textAlert = alertView.textFieldAtIndex(0) {
                if textAlert.text?.characters.count > 3 && textAlert.text?.characters.count < 15 {
                    reqNumber = reqNumber + 1
                    reqWeight = reqWeight + 1
                    reqNumOne = reqNumOne + 1
                    
                    userName = 1
                    
                    currentuser.username = textAlert.text
                    self.currentusername.text = "User ID: \(textAlert.text)"
                    
                    if( rate > 0 ){
                        rate = rate - 1
                        self.saveChange()
                    }else{
                        let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
                        alert.show()
                    }
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertView(title: "Error Try Again", message: "Username should be between 4 to 15 characters.", delegate: self, cancelButtonTitle: "Okay")
                    alert.show()
                }
            }
        }
    }
    
    func saveChange(){
        
        currentuser.saveInBackgroundWithBlock({ (done, error) -> Void in
            if error == nil {
                //self.tableView.reloadData()
                //self.currentusername.text = "User ID: \(username)"
            } else {
                errorCode = 1
                
                if let errorString = error.userInfo["error"] as? NSString {
                    let alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                    alert.show()
                }
            }
        })
        
        if userName == 1 {
            userName = 0
        }else if picUpdate == 1{
            updateActivity("picUpdated", content: "nil")
            picUpdate = 0
        }else if(nameUpdate == 1){
            updateActivity("nameUpdated", content: "nil")
            nameUpdate = 0
        }else if (statusUpdate != "" ){
            updateActivity("statusUpdated", content: statusUpdate)
            statusUpdate = ""
        }
    }
    
    

}
