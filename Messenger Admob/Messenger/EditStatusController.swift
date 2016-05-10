//
//  EditStatusController.swift
//  Messenger
//
//  Created by DJay on 23/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
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
        self.navtem.title = "Status (\(statusCount - count(statusText.text)))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func didSave(sender: AnyObject) {
        if count(statusText.text) > 4 {
            currentuser["status"] = statusText.text
            currentuser.saveInBackgroundWithBlock { (done, error) -> Void in
                if error == nil {
                    statusChanged = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                    updateActivity("statusUpdated", self.statusText.text)
                }
            }
        } else {
            var alert = UIAlertView(title: "Status Too Small", message: "Status should be minimum 4 characters long", delegate: self, cancelButtonTitle: "Okay")
            alert.show()
        }
        
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var textlength = (textView.text as NSString).length + (text as NSString).length - range.length
        self.navtem.title = "Status (\(statusCount - textlength))"

        if text == "\n" {
            textView.resignFirstResponder()
        }
        return (textlength > statusCount) ? false : true
    }

}
