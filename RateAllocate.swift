//
//  RateAllocate.swift
//  Messenger
//
//  Created by 虞子轩 on 16/3/23.
//  Copyright © 2016年 Zixuan. All rights reserved.
//

import UIKit

public class RateAllocate {
    
    func checkStatus(){
        
        var number : [Int] = []
        let urlComponents = NSURLComponents(string: serverUrl + "update")!
        reqReal = reqReal + preRate - rate
        
        //send data of request to server
        urlComponents.queryItems = [
            NSURLQueryItem(name: "type", value: String(2)),
            NSURLQueryItem(name: "userid", value: uuid),
            NSURLQueryItem(name: "reqNumber", value: String(reqNumber)),
            NSURLQueryItem(name: "reqWeight", value: String(reqWeight)),
            NSURLQueryItem(name: "reqNumOne", value: String(reqNumOne)),
            NSURLQueryItem(name: "reqNumTwo", value: String(reqNumTwo)),
            NSURLQueryItem(name: "reqNumThe", value: String(reqNumThe)),
            NSURLQueryItem(name: "reqReal", value: String(reqReal))
        ]
        
        print(urlComponents.URL)
        
        //reset all data
        reqNumber = 0; reqWeight = 0; reqReal = 0
        reqNumOne = 0; reqNumTwo = 0; reqNumThe = 0
        
        let request = NSMutableURLRequest(URL: urlComponents.URL!)
        
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            //if has error, using the ways like AIMD TCP to do rate allocate
            if error != nil {
                if errorCode == 0 {
                    rate = preRate + 1
                    preRate = preRate + 1
                }else{
                    errorCode = 0
                    rate = preRate / 2
                    preRate = preRate / 2
                }
                
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            number = getNumber(responseString)
            
            //the number in response should be 1, if more numbers occur, there are some errors on the server
            if number.count == 1 {
                rate = number[0]
                preRate = number[0]
                errorCode = 0
            }else{
                if errorCode == 0 {
                    rate = preRate + 1
                    preRate = preRate + 1
                }else{
                    errorCode = 0
                    rate = preRate / 2
                    preRate = preRate / 2
                }
            }
            
        }
        
        task.resume()
    }
    
    
}