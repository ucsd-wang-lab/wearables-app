//
//  GlobalVariables.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

var configsList:[Config] = []
var connectedDeiviceName:String?
var loopCount:Int?
var queuePosition: Int = 0
var currentLoopCount = -1
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

func showErrorMessage(message: String, viewController: UIViewController){
    let alert = UIAlertController(title: "Error!!", message: message, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    viewController.present(alert, animated: true)
}
    
func sendTestConfiguration(testCofig: TestConfig, viewController: UIViewController){
    for characteristics in testCofig.testSettings.keys{
        let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristics)
        let value = testCofig.testSettings[characteristics]!
        updateValue(name: characteristics, encodingType: encodingType, value: String(value), viewController: viewController)
    }
    
    // Sending Start Signal
    let data: UInt8 = 1
    var d: Data = Data(count: 1)
    d = withUnsafeBytes(of: data) { Data($0) }
    let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
    
    DispatchQueue.global().async {
        while !BluetoothInterface.instance.isConnected{
            // do nothing....Wait for connection to come back
        }
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }
}
    
func updateValue(name: String, encodingType: Any?, value: String?, viewController: UIViewController){
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
