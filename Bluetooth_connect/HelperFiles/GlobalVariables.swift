//
//  GlobalVariables.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//


var configsList:[Config] = []
var connectedDeiviceName:String?
var loopCount:Int?
var totalHr: Int = 0
var totalMin: Int = 0
var totalSec: Int = 0
var tempTestConfig:TestConfig?

func constructDelayString(hour: Int, min: Int, sec: Int) -> String{
    var delayStr = ""
    
    if hour < 10{
        delayStr = delayStr + "0" + String(hour) + ":"
    }
    else{
        delayStr = delayStr + String(hour) + ":"
    }
    
    if min < 10{
        delayStr = delayStr + "0" + String(min) + ":"
    }
    else{
        delayStr = delayStr + String(min) + ":"
    }
    
    if sec < 10{
        delayStr = delayStr + "0" + String(sec)
    }
    else{
        delayStr = delayStr + String(sec)
    }
    return delayStr
}
