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
    var numSettingSend:Int {get set}
}

struct DelayConfig: Config {
    
    var numSettingSend: Int
    
    var name: String?
    var hour: Int
    var min: Int
    var sec: Int
    var milSec: Int
    var totalDelay: Int
    
    init() {
        hour = -1
        min = -1
        sec = -1
        milSec = -1
        totalDelay = -1
        numSettingSend = 1
    }
    
    init(name: String) {
        self.name = name
        hour = 0
        min = 0
        sec = 1
        milSec = 0
        totalDelay = 1
        numSettingSend = 0
    }
}

struct TestConfig: Config {
    var name: String?    
    var hour: Int
    var min: Int
    var sec: Int
    var milSec: Int
    var initialDelay: Int
    var numSettingSend:Int
    
    var testSettings:[String:Int]
    var testData: [Int: [Double]]       // loopNumber: Data Array
    var startTimeStamp: [Int: String]   // loopNumber: StartTime
    var endTimeStamp: [Int: String]     // loopNumber: EndTime
    
    var measurementTypeIndex: Int
    var leadConfigIndex: Int
    
    init() {
        hour = 0
        min = 0
        sec = 0
        milSec = 0
        initialDelay = 0
        numSettingSend = 0
        
        testSettings = [:]
        testData = [:]
        startTimeStamp = [:]
        endTimeStamp = [:]
        measurementTypeIndex = 0
        leadConfigIndex = -1
    }
    
    init(name: String){
        self.name = name
        hour = 0
        min = 0
        sec = 10
        milSec = 400
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
        
        testSettings = ["Potential": 500, "Initial Delay": 400, "Sample Period": 100, "Sample Count": 100, "Gain": 4]
        measurementTypeIndex = 0
        leadConfigIndex = -1
    }
}
