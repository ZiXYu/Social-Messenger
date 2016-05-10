//
//  TermsViewController.swift
//  DateMe
//
//  Created by djay mac on 14/04/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backB: UIButton!
    var backBt = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Terms"
        
        var url:NSURL = NSURL(string: termsUrl)!
        var req:NSURLRequest = NSURLRequest(URL: url)
        webView.loadRequest(req)
        
        if backBt == false {
            backB.hidden = false
        }
        
        
    }

    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
