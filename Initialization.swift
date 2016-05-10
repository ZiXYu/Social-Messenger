//
//  Initialization.swift
//  Messenger
//
//  Created by 虞子轩 on 16/3/23.
//  Copyright © 2016年 Zixuan. All rights reserved.
//

import UIKit

public class Initialization {
    
    func launch(){
        var number : [Int] = []
        //send request to server to initialization
        let request = NSMutableURLRequest(URL: NSURL(string: serverUrl + "update?type=1&userid=" + uuid)!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                //if the connection is fail, use local second to syncorize
                rate = 10
                preRate = 10
                
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components( .Second, fromDate: date)
                let second = components.second
                
                syncSec = second
                
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            number = getNumber(responseString)
        
            //the numbers in response should be 2, if more numbers occur, there are some errors on the server
            if number.count == 2 {
                rate = number[0]
                preRate = number[0]
                syncSec = number[1]
            }else{
                preRate = rate
                
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components( .Second, fromDate: date)
                let second = components.second
                
                syncSec = second
            }
            
            print("rate size: " + String(rate) + "\n")
            print("syncSec time: " + String(syncSec) + "\n")
        }
        task.resume()
    }
    
    func quit(){
        
        //send request to server to quit allocation
        let request = NSMutableURLRequest(URL: NSURL(string: serverUrl + "update?type=3&userid=" + uuid)!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        //stop timer2
        timer2.invalidate()
        
        //if the buffer is not empty, send a push notification to current user
        if(!FRArray.isEmpty || nameUpdate != 0 || picUpdate != 0 || statusUpdate != "" || userName != 0 || !ReqArray.isEmpty){
            let pushText = "Still having some requests not send yet! These requests will be discarded by the App automatically!"
            
            let pushQuery = PFInstallation.query()
            pushQuery.whereKey("user", equalTo: currentuser)
            
            let push = PFPush()
            push.setQuery(pushQuery)
            
            let pushDict = ["alert":pushText,"badge":"increment","sound":"notification.mp3"]
            
            push.setData(pushDict)
            push.sendPushInBackground()
        }
    }


}