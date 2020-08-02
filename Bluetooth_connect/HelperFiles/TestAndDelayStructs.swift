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
    var milSec: Int {get set}
    var totalDuration: Int64{get set}
    var numSettingSend:Int {get set}
    
    mutating func updateTotalDuration()
}

struct DelayConfig: Config {
    
    var name: String?
    var hour: Int
    var min: Int
    var sec: Int
    var milSec: Int
    var totalDuration: Int64                 // Total delay in ms
    var numSettingSend: Int

    
    init() {
        hour = -1
        min = -1
        sec = -1
        milSec = -1
        totalDuration = -1
        numSettingSend = 1
    }
    
    init(name: String) {
        self.name = name
        hour = 0
        min = 0
        sec = 1
        milSec = 0
        totalDuration = 1000
        numSettingSend = 0
    }
    
    mutating func updateTotalDuration(){
        totalDuration = Int64(hour * 3600000) + Int64(min * 60000) + Int64(sec * 1000) + Int64(milSec)
        print("Update delay total duration: \(totalDuration)")
    }
}

struct TestConfig: Config {
    var name: String?    
    var hour: Int
    var min: Int
    var sec: Int
    var milSec: Int
    var totalDuration: Int64
    var numSettingSend:Int
    
    var initialDelay: Int
    var testSettings:[String:Int]
    var testData: [Int: [Double]]       // loopNumber: Data Array
    var startTimeStamp: [Int: String]   // loopNumber: StartTime
    var endTimeStamp: [Int: String]     // loopNumber: EndTime
    
    var leadConfigIndex: Int
    
    init() {
        hour = 0
        min = 0
        sec = 0
        milSec = 0
        totalDuration = 0
        initialDelay = 0
        numSettingSend = 0
        
        testSettings = [:]
        testData = [:]
        startTimeStamp = [:]
        endTimeStamp = [:]
        leadConfigIndex = -1
    }
    
    init(name: String){
        self.name = name
        hour = 0
        min = 0
        sec = 0
        milSec = 900
        totalDuration = 0
        initialDelay = 0
        numSettingSend = 0
        testData = [:]
        startTimeStamp = [:]
        endTimeStamp = [:]

        
//        [0: ["Potential": " mV"],
//         1: ["Initial Delay": " ms"],
//         2: ["Sample Period": " ms"],
//         3: ["Sample Count": ""],
//         4: ["Gain": " k\u{2126}"]
//        ]
        
        testSettings = ["Mode Select": 0, "Potential": 500, "Initial Delay": 400, "Sample Period": 100, "Sample Count": 5, "Gain": 4]
        leadConfigIndex = -1
        updateTotalDuration()
    }
    
    mutating func updateTotalDuration() {
        totalDuration = Int64(hour * 3600000) + Int64(min * 60000) + Int64(sec * 1000) + Int64(milSec)
    }
}
