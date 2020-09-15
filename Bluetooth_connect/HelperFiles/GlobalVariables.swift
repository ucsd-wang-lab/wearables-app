//
//  GlobalVariables.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

var configsList2:[Config] = [
    TestConfig(name: "Test 1", mode: 0),
    DelayConfig(name: "Delay 1")
//    TestConfig(name: "Test 2", mode: 1)
//    DelayConfig(name: "Delay 2"),
//    TestConfig(name: "Test 3")
]

var configsList:[Config] = []
var connectedDeiviceName:String?        // Name of the connected BLE device
var loopCount:Int?                  // The number of times to loop through the queue
//var loopCount:Int? = 2                  // The number of times to loop through the queue
var queuePosition: Int = 0              // The current test that is being run
var currentLoopCount = 1                // The current loop counter for testing
var totalHr: UInt64 = 0
var totalMin: UInt64 = 0
var totalSec: UInt64 = 0
var totalMilSec: UInt64 = 0
var totalRunTime: UInt64 = 0             // Total run time for all the test, in ms
var scaledTotalRunTime: UInt64 = 0             // Total run time for all the test, in ms
var testTimeElapsed: UInt64 = 0         // Time elapsed since the start of the queue, in ms
var tempTestConfig:TestConfig?




func constructDelayString(hour: Int, min: Int, sec: Int, milSec: Int) -> String{
    var delayStr = ""
    
    // Hour
    if hour < 10{
        delayStr = delayStr + "0" + String(hour) + ":"
    }
    else{
        delayStr = delayStr + String(hour) + ":"
    }
    
    // Min
    if min < 10{
        delayStr = delayStr + "0" + String(min) + ":"
    }
    else{
        delayStr = delayStr + String(min) + ":"
    }
    
    // Sec
    if sec < 10{
        delayStr = delayStr + "0" + String(sec) + "."
    }
    else{
        delayStr = delayStr + String(sec) + "."
    }
    
    // MilliSec
    if milSec < 10{
        delayStr = delayStr + "00" + String(milSec)
    }
    else if milSec < 100{
        delayStr = delayStr + "0" + String(milSec)
    }
    else{
        delayStr = delayStr + String(milSec)
    }
    
    return delayStr
}

func showErrorMessage(message: String, viewController: UIViewController){
    let alert = UIAlertController(title: "Error!!", message: message, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    viewController.present(alert, animated: true)
}

func sendModeSelection(config: Config, viewController: UIViewController){
    // Sending Mode Selection
    let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: "Mode Select")
    let value = config.testMode
    updateValue(name: "Mode Select", encodingType: encodingType, value: String(value), viewController: viewController)
}

func sendTestConfiguration(testCofig: TestConfig, viewController: UIViewController){
    // Sending Mode Selection
    sendModeSelection(config: testCofig, viewController: viewController)
    
    // Sending Test Configuration
    for characteristics in testCofig.testSettings2[Int(testCofig.testMode)]!.keys{
        var char = characteristics
        if !characteristics.contains("Electrode Mask") && testCofig.testMode == 1{
            char += " - Potentio"
        }
        let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: char)
        let value = testCofig.testSettings2[Int(testCofig.testMode)]![characteristics]!
        updateValue(name: char, encodingType: encodingType, value: String(value), viewController: viewController)
    }

    // Sending Start Signal
    DispatchQueue.global().async {
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
        d = withUnsafeBytes(of: data) { Data($0) }
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        
        while !BluetoothInterface.instance.isConnected {
            // do nothing....Wait for connection to come back
        }

        print("Sending Start Signal.....")
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }
}
    
func updateValue(name: String, encodingType: Any?, value: String?, viewController: UIViewController){
    print("Writing to: \(name)")
    if let value = value{
        if value == ""{
            showErrorMessage(message: "Value Field Cannot be empty", viewController: viewController)
        }
        else if Int(value) == nil{
            showErrorMessage(message: "Value Field Must be a number: \(value)", viewController: viewController)
        }
        else{
            if encodingType is UInt8{
                let data = UInt8(value) ?? nil
                var d = Data(count: 1)
                d = withUnsafeBytes(of: data!) { Data($0) }
                let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                DispatchQueue.global().async {
                    while !BluetoothInterface.instance.isConnected{
                        // do nothing....Wait for connection to come back
                    }
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                }
            }
            else if encodingType is UInt16{
                let data = UInt16(value) ?? nil
                var d = Data(count: 2)
                d = withUnsafeBytes(of: data!) { Data($0) }
                let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                DispatchQueue.global().async {
                    while !BluetoothInterface.instance.isConnected{
                        // do nothing....Wait for connection to come back
                    }
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                }
                
            }
            else if encodingType is Int16{
                let data = Int16(value) ?? nil
                var d = Data(count: 2)
                d = withUnsafeBytes(of: data!) { Data($0) }
                let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                DispatchQueue.global().async {
                    while !BluetoothInterface.instance.isConnected{
                        // do nothing....Wait for connection to come back
                    }
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                }
                
            }
            else{
                showErrorMessage(message: "Error Sending Data to Firmware\nInvalid Data Type", viewController: viewController)
            }
        }
        
    }
    else{
        showErrorMessage(message: "Error Sending Data to Firmware...Contact Developer", viewController: viewController)
    }
}

func updateTimeElapsedLabel(timeInMS: UInt64) -> String{
    var temp = timeInMS
    
    // Hr
    var label = ""
    if temp / 3600000 < 10{
        label += "0" + String(temp / 3600000)
    }
    else{
        label += String(temp / 3600000)
    }
    temp %=  3600000
    
    // Min
    label = label + ":"
    if temp / 60000 < 10{
        label += "0" +  String(temp / 60000)
    }
    else{
        label += String(temp / 60000)
    }
    temp %= 60000
    
    // Sec
    label = label + ":"
    if temp / 1000 < 10{
        label += "0" + String(temp / 1000)
    }
    else{
        label += String(temp / 1000)
    }
    temp %= 1000
    
    // ms
    label = label + "."
    if temp < 10{
        label += "00" +  String(temp)
    }
    else if temp < 100{
        label += "0" +  String(temp)
    }
    else{
        label += String(temp)
    }
    
    return label
}
