//
//  EditStatusController.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class EditStatusController: UIViewController, UITextViewDelegate {

    
    
    @IBOutlet weak var statusText: UITextView!
    @IBOutlet weak var navtem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navtem.title = "Status"
        self.statusText.text = " "
        self.view.backgroundColor = backColor
    }

    override func viewDidAppear(animated: Bool) {
        self.statusText.text = currentuser.objectForKey("status") as? String
        self.navtem.title = "Status (\(statusCount - statusText.text.characters.count))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func didSave(sender: AnyObject) {
        if statusText.text.characters.count > 4 {
            reqNumber = reqNumber + 1
            reqWeight = reqWeight + 1
            reqNumOne = reqNumOne + 1
            
            currentuser["status"] = statusText.text
            statusUpdate = statusText.text
            statusChanged = true
            
            if rate > 0 {
                rate = rate - 1
                ProfileViewController().saveChange()
            }else{
                let alert = UIAlertView(title: "Error", message: "Sever is busy now, the app will try to resend the message in a few seconds", delegate: self, cancelButtonTitle: "okay")
                alert.show()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertView(title: "Status Too Small", message: "Status should be minimum 4 characters long", delegate: self, cancelButtonTitle: "Okay")
            alert.show()
        }
        
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let textlength = (textView.text as NSString).length + (text as NSString).length - range.length
        self.navtem.title = "Status (\(statusCount - textlength))"

        if text == "\n" {
            textView.resignFirstResponder()
        }
        return (textlength > statusCount) ? false : true
    }

}
