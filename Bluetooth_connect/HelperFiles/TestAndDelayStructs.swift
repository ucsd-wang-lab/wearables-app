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
    var testMode: Int8 { get set }
    
    /**
            Total duration in ms
     */
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
    var testMode: Int8
    
    init() {
        hour = -1
        min = -1
        sec = -1
        milSec = -1
        totalDuration = -1
        numSettingSend = 1
        testMode = 4
    }
    
    init(name: String) {
        self.init()
        self.name = name
        
        if(name.contains("Delay 1")){
            hour = 0
            min = 0
            sec = 3
            milSec = 100
            updateTotalDuration()
        }
        else if name.contains("Delay 2"){
            hour = 0
            min = 0
            sec = 5
            milSec = 100
            updateTotalDuration()
        }
        else if name.contains("Delay 3"){
            hour = 0
            min = 0
            sec = 7
            milSec = 100
            updateTotalDuration()
        }
    }
    
    mutating func updateTotalDuration(){
        totalDuration = Int64(hour * 3600000) + Int64(min * 60000) + Int64(sec * 1000) + Int64(milSec)
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
    
    var testMode: Int8
    var testData: [Int: [Double]]       // loopNumber: Data Array
    var startTimeStamp: [Int: String]   // loopNumber: StartTime
    var endTimeStamp: [Int: String]     // loopNumber: EndTime
    var testSettings: [Int: [String: Int]]  // Measurement Type: [Key: Value]
    var testSettingUpdateReceived: [Int: [String: Bool]]    // Measurement Type: [Key: Yes/No];
    var loopIteration: Int
    
    var leadConfigIndex: Int
    
    init() {
        hour = 0
        min = 0
        sec = 0
        milSec = 0
        totalDuration = 0
        numSettingSend = 0
        testMode = -1
        
        testData = [:]
        startTimeStamp = [:]
        endTimeStamp = [:]
        leadConfigIndex = -1
        testSettings = [:]
        testSettingUpdateReceived = [:]
        loopIteration = 0
    }
    
    init(name: String) {
        self.init()
        self.name = name
        
        if name.contains("Test 1"){
            // Ampero
            testMode = 0
            testSettings.updateValue(["Potential": 100, "Initial Delay": 300, "Sample Period": 200, "Sample Count": 100, "Electrode Mask": 72], forKey: 0)
            sec = 20
            milSec = 300
        }
        else if name.contains("Test 2"){
            // Potentio
            testMode = 1
            testSettings.updateValue(["Initial Delay": 200, "Sample Period": 200, "Sample Count": 5, "Filter Level": 3, "Electrode Mask": 72], forKey: 1)
//            testSettingUpdateReceived.updateValue(["Initial Delay": false, "Sample Period": false, "Sample Count": false, "Filter Level": false, "Electrode Mask": false], forKey: 1)
            sec = 1
            milSec = 200
            
        }
        else if name.contains("Test 3"){
            // Square Wave
            testMode = 2
            testSettings.updateValue(["Quiet Time": 200, "Num Steps": 10, "Frequency": 100,
                                       "Amplitude": 100, "Initial Potential": 100, "Final Potential": 200, "Gain Level": 4], forKey: 2)
            
            testSettings.updateValue(["Quiet Time": 200, "Num Steps": 200, "Frequency": 10,
                                       "Amplitude": 100, "Initial Potential": 100, "Final Potential": 200, "Gain Level": 4], forKey: 2)
            
            milSec = 300
            
        }
        
        updateTotalDuration()
        generateTestData()
    }
    
    mutating func updateTotalDuration() {
        totalDuration = Int64(hour * 3600000) + Int64(min * 60000) + Int64(sec * 1000) + Int64(milSec)
    }
    
    mutating func generateTestData(){
        let numOfData = 3
        for loopNum in 1..<numOfData{
            var data: [Double] = []
            for newData in 0..<10{
                data.append(Double(newData * loopNum))
            }
            testData.updateValue(data, forKey: loopNum)
        }
        var data: [Double] = []
        for newData in 0..<5{
            data.append(Double(newData * newData))
        }
        testData.updateValue(data, forKey: numOfData)
        
        startTimeStamp.updateValue("1", forKey: 1)
        startTimeStamp.updateValue("2", forKey: 2)
        startTimeStamp.updateValue("3", forKey: 3)
        
        endTimeStamp.updateValue("00:00:02:000", forKey: 1)
        endTimeStamp.updateValue("00:00:03:000", forKey: 2)
        endTimeStamp.updateValue("00:00:04:000", forKey: 3)
    }
}
