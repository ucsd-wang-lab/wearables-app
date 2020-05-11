//
//  UUIDs.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 4/1/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import CoreBluetooth

class ServiceUUID{
    static let instance = ServiceUUID.init()
        
    private var UUIDtoServiceName: [String: String] = [:]
    private var serviceNametoUUID: [String: String] = [:]
    
    init() {
        UUIDtoServiceName.updateValue("Device Info Service", forKey: "180A")
        UUIDtoServiceName.updateValue("Battery Service", forKey: "180F")
        UUIDtoServiceName.updateValue("Ampero Configuration Service", forKey: "62C5963D-E0F9-4BFD-9599-739C56147CF7")
        UUIDtoServiceName.updateValue("Ampero Output Data Service", forKey: "B8B6B745-A99E-4B29-975E-76347005B273")
        UUIDtoServiceName.updateValue("Sensing Configuration Service", forKey: "6760110a-956f-4a92-8744-64326cbee033".uppercased())
        UUIDtoServiceName.updateValue("Power Service", forKey: "139CDD4D-2F80-492C-ADE6-6D91F920C920")
        
        
        serviceNametoUUID.updateValue("180A", forKey: "Device Info Service")
        serviceNametoUUID.updateValue("180F", forKey: "Battery Service")
        serviceNametoUUID.updateValue("62C5963D-E0F9-4BFD-9599-739C56147CF7", forKey: "Ampero Configuration Service")
        serviceNametoUUID.updateValue("B8B6B745-A99E-4B29-975E-76347005B273", forKey: "Ampero Output Data Service")
        serviceNametoUUID.updateValue("6760110a-956f-4a92-8744-64326cbee033".uppercased(), forKey: "Sensing Configuration Service")
        serviceNametoUUID.updateValue("139CDD4D-2F80-492C-ADE6-6D91F920C920", forKey: "Power Service")
        
        
    }
    
    func getServiceUUID(serviceName: String) -> String?{
        return serviceNametoUUID[serviceName]
    }
    
    func getServiceName(serviceUUID: String) -> String? {
        return UUIDtoServiceName[serviceUUID]
    }
}

enum CHARACTERISTICS_PROPERTIES: UInt{
    case BROADCAST = 0b1;
    case READ = 0b10;
    case WRITE_WITHOUT_RESPONSE = 0b100;
    case WRITE = 0b1000;
    case NOTIFY = 0b10000;
    case INDICATE = 0b100000;
}

var CHARACTERISTIC_VALUE: [String: String] = ["Battery Level": "xx",
                                              "Firmware Revision": "x.x.x",
                                              "Potential": "-1/+1",
                                              "Initial Delay": "xxx",
                                              "Sample Period": "xxxx",
                                              "Sample Count": "xxx",
                                              "Gain": "xxxx",
                                              "Electrode Mask": "xxxxxxxx"
                                            ]
var CHARACTERISTIC_VALUE_MIN_VALUE: [String: Int] = ["Battery Level": 0,
                                                 "Firmware Revision": -1,
                                                 "Potential": -1000,
                                                 "Initial Delay": 0,
                                                 "Sample Period": 100,
                                                 "Sample Count": 0,
                                                 "Gain": 0,
                                                 "Electrode Mask": 0
                                            ]

var CHARACTERISTIC_VALUE_MAX_VALUE: [String: Int] = ["Battery Level": 100,
                                                     "Firmware Revision": -1,
                                                     "Potential": 1000,
                                                     "Initial Delay": Int(UInt16.max),
                                                     "Sample Period": Int(UInt16.max),
                                                     "Sample Count": Int(UInt16.max),
                                                     "Gain": 27,
                                                     "Electrode Mask": Int(UInt8.max)
                                                    ]

class CharacteristicsUUID{
    static let instance = CharacteristicsUUID.init()
    
    private var UUIDtoCharacteristicName: [String: String] = [:]
    private var characteristicNametoUUID: [String: String] = [:]
    private var characteristicProperty: [String: String] = [:]
    private var characteristicDataType: [String: Any] = [:]
    private var characteristicValue: [String: String] = [:]
    

    
    init() {
        setupCharacteristicNametoUUID()
        setupUUIDtoCharacteristicName()
        setCharacteristicPropery()
//        setCharacteristicDataType()
//        setCharacteristicValue()
    }
    
    private func setupUUIDtoCharacteristicName(){
        // Device Info Service
        UUIDtoCharacteristicName.updateValue("Manufacturer", forKey: "2A29")
        UUIDtoCharacteristicName.updateValue("Model Number", forKey: "2A24")
        UUIDtoCharacteristicName.updateValue("System ID", forKey: "2A23")
        UUIDtoCharacteristicName.updateValue("Firmware Revision", forKey: "2A26")

        // Battery Service
        UUIDtoCharacteristicName.updateValue("Battery Level", forKey: "2A19")
        
        // Power Service
        UUIDtoCharacteristicName.updateValue("System Power", forKey: "bf764404-f6e0-11e9-aad5-362b9e155667".uppercased())
        
        // Sensing Configuration Serivce
        UUIDtoCharacteristicName.updateValue("Queue Repeat Count", forKey: "bbc837d1-b070-4d6c-9125-955eb64cd151".uppercased())
        UUIDtoCharacteristicName.updateValue("Start/Stop Queue", forKey: "aea9035c-96e9-4bca-bee4-4a1d3961bfef".uppercased())
        
        // Ampero Configuration Service
        UUIDtoCharacteristicName.updateValue("Electrode Mask", forKey: "949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased())
        UUIDtoCharacteristicName.updateValue("Potential", forKey: "AB1745C8-FAAC-4858-874D-139AEE7EE06C")
        UUIDtoCharacteristicName.updateValue("Initial Delay", forKey: "08F8BA7E-E228-4EF5-9420-753642BBB087")
        UUIDtoCharacteristicName.updateValue("Sample Count", forKey: "F539D25E-1C00-44FE-AE81-10F1FCF7A634")
        UUIDtoCharacteristicName.updateValue("Sample Period", forKey: "ABD11F7C-C6AB-4C54-B34D-FF80343FD7E9")
        UUIDtoCharacteristicName.updateValue("Gain", forKey: "507e21b4-da96-40e5-8ca4-67321fb2ab3b".uppercased())
        
        // Ampero Output Data Service
        UUIDtoCharacteristicName.updateValue("Data Characteristic - current", forKey: "808C72E4-175E-4595-8CF1-AB07E49A8331")
//        UUIDtoCharacteristicName.updateValue("Queue ID", forKey: "949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased())
        
        // Potentiometric Data Service
        UUIDtoCharacteristicName.updateValue("Start/Stop Potentiometry", forKey: "2e0b45c2-e649-4591-ae5e-840960863efa".uppercased())
        UUIDtoCharacteristicName.updateValue("Data Characteristic - Potential", forKey: "3e0152be-4183-4b6b-bd13-920322432016".uppercased())
    }
    
    private func setupCharacteristicNametoUUID(){
        // Device Info Service
        characteristicNametoUUID.updateValue("2A29", forKey: "Manufacturer")
        characteristicNametoUUID.updateValue("2A24", forKey: "Model Number")
        characteristicNametoUUID.updateValue("2A23", forKey: "System ID")
        characteristicNametoUUID.updateValue("2A26", forKey: "Firmware Revision")
        
        // Battery Service
        characteristicNametoUUID.updateValue("2A19", forKey: "Battery Level")

        // Power Service
        characteristicNametoUUID.updateValue("bf764404-f6e0-11e9-aad5-362b9e155667".uppercased(), forKey: "System Power")
        
        // Sensing Configuration Service
        characteristicNametoUUID.updateValue("bbc837d1-b070-4d6c-9125-955eb64cd151".uppercased(), forKey: "Queue Repeat Count")
        characteristicNametoUUID.updateValue("aea9035c-96e9-4bca-bee4-4a1d3961bfef".uppercased(), forKey: "Start/Stop Queue")
        
        // Ampero Configuration Service
        characteristicNametoUUID.updateValue("949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased(), forKey: "Electrode Mask")
        characteristicNametoUUID.updateValue("AB1745C8-FAAC-4858-874D-139AEE7EE06C", forKey: "Potential")
        characteristicNametoUUID.updateValue("08F8BA7E-E228-4EF5-9420-753642BBB087", forKey: "Initial Delay")
        characteristicNametoUUID.updateValue("F539D25E-1C00-44FE-AE81-10F1FCF7A634", forKey: "Sample Count")
        characteristicNametoUUID.updateValue("ABD11F7C-C6AB-4C54-B34D-FF80343FD7E9", forKey: "Sample Period")
        characteristicNametoUUID.updateValue("507e21b4-da96-40e5-8ca4-67321fb2ab3b".uppercased(), forKey: "Gain")
        
        // Ampero Output Data Service
        characteristicNametoUUID.updateValue("808C72E4-175E-4595-8CF1-AB07E49A8331", forKey: "Data Characteristic - current")
//        characteristicNametoUUID.updateValue("949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased(), forKey: "Queue ID")
        
        // Potentiometric Data Service
        characteristicNametoUUID.updateValue("2e0b45c2-e649-4591-ae5e-840960863efa".uppercased(), forKey:"Start/Stop Potentiometry")
        characteristicNametoUUID.updateValue("3e0152be-4183-4b6b-bd13-920322432016".uppercased(), forKey: "Data Characteristic - Potential")
    }
    
    private func setCharacteristicPropery(){
        // Device Info Service
        characteristicProperty.updateValue("Read", forKey: "Manufacturer")
        characteristicProperty.updateValue("Read", forKey: "Model Number")
        characteristicProperty.updateValue("Read", forKey: "System ID")
        characteristicProperty.updateValue("Read", forKey: "Firmware Revision")
        
        // Battery Service
        characteristicProperty.updateValue("Read", forKey: "Battery Level")
        
        // Power Service
        characteristicProperty.updateValue("Write No Response", forKey: "System Power")
        
        // Sensing Configuration Service
        characteristicProperty.updateValue("Read/Write", forKey: "Queue Repeat Count")
        characteristicProperty.updateValue("Read/Write", forKey: "Start/Stop Queue")
        
        // Ampero Configuration Service
        characteristicProperty.updateValue("Read/Write", forKey: "Electrode Mask")
        characteristicProperty.updateValue("Read/Write", forKey: "Potential")
        characteristicProperty.updateValue("Read/Write", forKey: "Initial Delay")
        characteristicProperty.updateValue("Read/Write", forKey: "Sample Count")
        characteristicProperty.updateValue("Read/Write", forKey: "Sample Period")
        characteristicProperty.updateValue("Read/Write", forKey: "Gain")
        
        // Ampero Output Data Service
        characteristicProperty.updateValue("Read/Notify", forKey: "Data Characteristic - current")
//        characteristicProperty.updateValue("Read", forKey: "Queue ID")
        
        // Potentiometric Data Service
        characteristicProperty.updateValue("Read/Write", forKey:"Start/Stop Potentiometry")
        characteristicProperty.updateValue("Read/Notify", forKey: "Data Characteristic - Potential")
    }
    
    private func setCharacteristicDataType(){
        // Device Info Service
        /*
         * All of the String Encoding is assumed to be utf8 encoding
         */
        characteristicDataType.updateValue(String.Encoding.RawValue(), forKey: "Manufacturer")
        characteristicDataType.updateValue(String.Encoding.RawValue(), forKey: "Model Number")
        characteristicDataType.updateValue(String.Encoding.RawValue(), forKey: "System ID")
        characteristicDataType.updateValue(String.Encoding.RawValue(), forKey: "Firmware Revision")

        // Battery Service
        characteristicDataType.updateValue(UInt8(), forKey: "Battery Level")
        
        // Power Service
        characteristicDataType.updateValue(UInt8(), forKey: "System Power")
        
        // Sensing Configuration Service
        characteristicDataType.updateValue(UInt16(), forKey: "Queue Repeat Count")
        characteristicDataType.updateValue(UInt8(), forKey: "Start/Stop Queue")
        
        // Ampero Configuration Service
        characteristicDataType.updateValue(UInt8(), forKey: "Electrode Mask")
        characteristicDataType.updateValue(Int16(), forKey: "Potential")
        characteristicDataType.updateValue(UInt16(), forKey: "Initial Delay")
        characteristicDataType.updateValue(UInt16(), forKey: "Sample Count")
        characteristicDataType.updateValue(UInt16(), forKey: "Sample Period")
        characteristicDataType.updateValue(UInt8(), forKey: "Gain")
        
        // Ampero Output Data Service
        characteristicDataType.updateValue(Int32(), forKey: "Data Characteristic - current")
//        characteristicDataType.updateValue(UInt8(), forKey: "Queue ID")
    }
    
    private func setCharacteristicValue(){
        // Device Info Service
        characteristicValue.updateValue("x.x.x", forKey: "Firmware Revision")

        // Battery Service
        characteristicValue.updateValue("xx", forKey: "Battery Level")
        
        // Ampero Configuration Service
        characteristicValue.updateValue("xxxx xxxx", forKey: "Electrode Mask")
        characteristicValue.updateValue("-1 to +1", forKey: "Potential")
        characteristicValue.updateValue("xxx", forKey: "Initial Delay")
        characteristicValue.updateValue("xxx", forKey: "Sample Count")
        characteristicValue.updateValue("xxxx", forKey: "Sample Period")
        characteristicValue.updateValue("xxxx", forKey: "Gain")
    }
    
    func getCharacteristicName(characteristicUUID: String) -> String? {
        return UUIDtoCharacteristicName[characteristicUUID]
    }
    
    func getCharacteristicUUID(characteristicName: String) -> String? {
        return characteristicNametoUUID[characteristicName]
    }
    
//    func getCharacteristicProperty(characteristic: String, isUUID: Bool) -> String?{
//        if isUUID{
//            if let name = getCharacteristicName(characteristicUUID: characteristic){
//                return characteristicProperty[name]
//            }
//        }
//        else{
//            return characteristicProperty[characteristic]
//
//        }
//        return nil
//    }
    
    func getCharacteristicDataType(characteristicName: String) -> Any?{
        return characteristicDataType[characteristicName]
    }
    
//    func getCharacteristicValue(characteristicName: String) -> String?{
//        return characteristicValue[characteristicName]
//    }
//
//    func updateCharacteristicValue(characteristicName: String, value: String){
//        characteristicValue.updateValue(value, forKey: characteristicName)
//    }
}
