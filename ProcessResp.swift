//
//  ProcessNumber.swift
//  Messenger
//
//  Created by 虞子轩 on 16/3/23.
//  Copyright © 2016年 Zixuan. All rights reserved.
//

import Foundation

func getNumber(NSStr : NSString?) -> [Int] {
    
    // this function is used to get the numbers of a String
    let str = NSStr as! String
    
    let regex = try! NSRegularExpression(pattern: "\\d+", options: [])
    let results = regex.matchesInString(str, options: [], range: NSMakeRange(0, NSStr!.length))
    
    let numbers = results.map { Int(NSStr!.substringWithRange($0.range))! }
    
    return numbers
}
