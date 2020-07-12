//
//  TestAndDelayStructs.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

protocol Config {
    var name:String? {get set}
    var hour: Int {get set}
    var min: Int {get set}
    var sec: Int {get set}
}

struct DelayConfig: Config {
    var name: String?
    var hour: Int
    var min: Int
    var sec: Int
}

struct TestConfig: Config {
    var name: String?    
    var hour: Int
    var min: Int
    var sec: Int
    var milSec: Int
    
    var testSettings:[String:Int]
    
    var measurementTypeIndex: Int
    var leadConfigIndex: Int
}
