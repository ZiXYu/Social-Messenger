//
//  TermsViewController.swift
//  DateMe
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backB: UIButton!
    var backBt = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Terms"
        
        let url:NSURL = NSURL(string: termsUrl)!
        let req:NSURLRequest = NSURLRequest(URL: url)
        webView.loadRequest(req)
        
        if backBt == false {
            backB.hidden = false
        }
        
        
    }

    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
