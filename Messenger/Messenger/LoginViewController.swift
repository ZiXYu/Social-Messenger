//
//  LoginViewController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTF.autocorrectionType = UITextAutocorrectionType.No
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func loginAction(sender: AnyObject) {
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if rate > 0 {
            rate = rate - 1
            
            PFUser.logInWithUsernameInBackground(usernameTF.text, password: passwordTF.text) { (getuser, error: NSError!) -> Void in
                if getuser != nil {
                    currentuser = getuser
                    if UIDevice.currentDevice().model != "iPhone Simulator" {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation["user"] = currentuser
                        currentInstallation.saveInBackground()
                    }
                    self.performSegueWithIdentifier("logintab", sender: self)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let errorString = error.userInfo["error"] as? NSString {
                        var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                        alert.show()
                    }
                }
                
            }
        }else {
            MBProgressHUD.hideHUDForView(self.view, animated: true)

            let alert = UIAlertView(title: "Error", message: "The server is busy now, please try it a few mins later!", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        }
        
    }
    
    
    @IBAction func loginFb(sender: AnyObject) {
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let permissions = ["public_profile", "email", "user_friends"]
        
        if rate > 0 {
            rate = rate - 1
            PFFacebookUtils.logInWithPermissions(permissions, block: {
                (fbuser: PFUser!, error: NSError!) -> Void in
                if fbuser == nil {
                    NSLog("Uh oh. The user cancelled the Facebook login.")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                } else if fbuser.isNew {
                    NSLog("User signed up and logged in through Facebook!")
                    justSignedUp = true
                    currentuser = fbuser
                    self.createFbUser()
                    
                } else if fbuser != nil{
                    NSLog("User logged in through Facebook!")
                    currentuser = fbuser
                    if UIDevice.currentDevice().model != "iPhone Simulator" {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation["user"] = currentuser
                        currentInstallation.saveInBackground()
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.performSegueWithIdentifier("logintab", sender: self)
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let errorString = error.userInfo["error"] as? NSString {
                        var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                        alert.show()
                    }
                }
            })
        }else{
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            var alert = UIAlertView(title: "Error", message: "The server is busy now, please try it a few mins later!", delegate: self, cancelButtonTitle: "okay")
            alert.show()
        
        }
    }
    
    
    @IBAction func forgotPass(sender: UIButton) {
        let alert = UIAlertView(title: "Forgot Password", message: "Enter your email address and we will send you the Password reset link.", delegate: self, cancelButtonTitle: "Reset Password")
        alert.addButtonWithTitle("Cancel")
        alert.tag = 4
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 && alertView.tag == 4 {
            if let textAlert = alertView.textFieldAtIndex(0) {
                if textAlert.text?.characters.count > 3 {
                    PFUser.requestPasswordResetForEmailInBackground(textAlert.text, block: { (success, error) -> Void in
                        if success {
                            var alert = UIAlertView(title: "Email Sent", message: "An email has been sent to reset the password.", delegate: self, cancelButtonTitle: "Okay")
                            alert.show()
                        } else if (error != nil) {
                            if let errorString = error.userInfo["error"] as? NSString {
                                var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                                alert.show()
                            }

                        }
                    })
                } else {
                    var alert = UIAlertView(title: "Error Try Again", message: "Email should be more than 3 characters.", delegate: self, cancelButtonTitle: "Okay")
                    alert.show()
                }
            }
        }
    }
    
    
    
    func createFbUser() {
        reqNumber = reqNumber + 1
        reqWeight = reqWeight + 3
        reqNumThe = reqNumThe + 1
        
        FBRequestConnection.startWithGraphPath("me", completionHandler: { (connection, fbuser, error) -> Void in
            
            if let useremail = fbuser.objectForKey("email") as? String {
                currentuser.email = useremail
            }
            
            currentuser["name"] = fbuser.name // full name
            let id = fbuser.objectID as String
            let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=640&height=640")!
            let data = NSData(contentsOfURL: url)
            let image = UIImage(data: data!)
            let imageL = scaleImage(image!, and: 320) // save 640x640 image
            let imageS = scaleImage(image!, and: 60)
            let dataL = UIImageJPEGRepresentation(imageL, 0.9)
            let dataS = UIImageJPEGRepresentation(imageS, 0.9)
            currentuser["dpLarge"] = PFFile(name: "dpLarge.jpg", data: dataL)
            currentuser["dpSmall"] = PFFile(name: "dpSmall.jpg", data: dataS)
            currentuser["fbId"] = fbuser.objectID as String
            currentuser["status"] = initialStatus
            if( rate > 0 ){
                rate = rate - 1
                
                currentuser.saveInBackgroundWithBlock({ (done, error) -> Void in
                    if !(error != nil) {
                        if UIDevice.currentDevice().model != "iPhone Simulator" {
                            let currentInstallation = PFInstallation.currentInstallation()
                            currentInstallation["user"] = currentuser
                            currentInstallation.saveInBackground()
                        }
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.performSegueWithIdentifier("logintab", sender: self)
                    } else {
                        if let errorString = error.userInfo["error"] as? NSString {
                            let alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                            alert.show()
                        }
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        
                    }
                })
            }else{
                let alert = UIAlertView(title: "Error Try Again", message: "Email should be more than 3 characters.", delegate: self, cancelButtonTitle: "Okay")
                alert.show()
            }
        })
        
    }

}
