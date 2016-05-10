//
//  Delay.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//

import UIKit

public class Clockwork : NSObject {
    
    func Synchronize(){
        
        //Synchronize with the server
        let sync = Double ( 15 - syncSec % 15 )
        
        //timer1 only run once, it could ensure the timer2 start at every serve time 10s/25s/40s/55s
        timer1 = NSTimer.scheduledTimerWithTimeInterval(sync, target: self, selector: Selector("startTimer"), userInfo: nil, repeats: false)
        
        NSRunLoop.currentRunLoop().addTimer(timer1, forMode: NSRunLoopCommonModes)
    }
    
    func startTimer(){
        
        //timer2 run constantly every 15s
        timer2 = NSTimer(timeInterval: 15.0, target: self, selector: "rateAllocate", userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(timer2, forMode: NSRunLoopCommonModes)
    }
    
    func rateAllocate(){
        if ( rate > 0 ){
            //if in the previous 15s, the allocated rate still has rest, try to use them first
            self.sendRest() // this runs at the end of this 15s.
        }
        
        //communicate with server, report data of request in previous 15s and get new rate
        RateAllocate().checkStatus()
        
        //use the new rate allocated to send rest sending message request first
        self.sendChatmessage() // this runs at the beginning of this 15s;
    }
    
    func sendRest(){
        //if the rate is positive and the buffer is not empty, try to send requests
        while (rate > 0 && ( !FRArray.isEmpty || nameUpdate != 0 || picUpdate != 0 || statusUpdate != "" || userName != 0 || !ReqArray.isEmpty)) {
            if( FRArray.isEmpty == false ){
                SearchViewController().sendRequest2(FRArray[0])
                FRArray.removeAtIndex(0)
                rate = rate - 1
            }else if( userName == 1 || nameUpdate == 1 || picUpdate == 1 || statusUpdate != ""){
                ProfileViewController().saveChange()
                rate = rate - 1
            }else if ( ReqArray.isEmpty == false ){
                RequestViewController().processRequest(ReqArray[0])
                ReqArray.removeAtIndex(0)
                rate = rate - 1
            }
        }

    }
    
    func sendChatmessage(){
        //if the rate is positive and the buffer of sending message request is not empty, try to send them first.
        while (rate > 0 && !MsgArray.isEmpty) {
            ChatMessagesViewController().sendMessage(MsgArray[0])
            
            MsgArray.removeAtIndex(0)
            rate = rate - 1
        }
    }
}