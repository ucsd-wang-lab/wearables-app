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
    var numSettingSend:Int {get set}
}

struct DelayConfig: Config {
    var numSettingSend: Int
    
    var name: String?
    var hour: Int
    var min: Int
    var sec: Int
    var totalDelay: Int
    
    init() {
        hour = -1
        min = -1
        sec = -1
        totalDelay = -1
        numSettingSend = 1
    }
    
    init(name: String) {
        self.name = name
        hour = -1
        min = -1
        sec = -1
        totalDelay = -1
        numSettingSend = 1
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
    var testData: [Int: [Double: Double]]   // loop: [x, y]
    
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
        measurementTypeIndex = 0
        leadConfigIndex = -1
    }
    
    init(name: String){
        self.name = name
        hour = 0
        min = 0
        sec = 0
        milSec = 0
        initialDelay = 0
        numSettingSend = 0
        testData = [:]
        
//        [0: ["Potential": " mV"],
//         1: ["Initial Delay": " ms"],
//         2: ["Sample Period": " ms"],
//         3: ["Sample Count": ""],
//         4: ["Gain": " k\u{2126}"]
//        ]
        
        testSettings = ["Potential": 500, "Initial Delay": 400, "Sample Period": 100, "Sample Count": 5, "Gain": 4]
        measurementTypeIndex = 0
        leadConfigIndex = -1
    }
}


struct TestData{
    
    var name: String?
    var data:[Int: [Double]]
    
    init() {
        data = [:]
    }
    
    mutating func insertData(loopCount: Int, data: Double){
        self.data[loopCount]?.append(data)
    }
}
