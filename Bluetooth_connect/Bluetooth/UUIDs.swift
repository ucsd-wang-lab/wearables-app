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
    private var availableService: [String: CBService] = [:]

    
    init() {
        UUIDtoServiceName.updateValue("Device Information", forKey: "B8B6B745-A99E-4B29-975E-76347005B273")
        UUIDtoServiceName.updateValue("Ampero Configuration", forKey: "62C5963D-E0F9-4BFD-9599-739C56147CF7")
        UUIDtoServiceName.updateValue("Ampero Output Data", forKey: "B8B6B745-A99E-4B29-975E-76347005B273")
        
        serviceNametoUUID.updateValue("B8B6B745-A99E-4B29-975E-76347005B273", forKey: "Device Information")
        serviceNametoUUID.updateValue("62C5963D-E0F9-4BFD-9599-739C56147CF7", forKey: "Ampero Configuration")
        serviceNametoUUID.updateValue("B8B6B745-A99E-4B29-975E-76347005B273", forKey: "Ampero Output Data")
    }
    
    func getServiceUUID(serviceName: String) -> String?{
        return serviceNametoUUID[serviceName]
    }
    
    func getServiceName(serviceUUID: String) -> String? {
        return UUIDtoServiceName[serviceUUID]
    }
}

class CharacteristicsUUID{
    static let instance = CharacteristicsUUID.init()
    
    private var UUIDtoCharacteristicName: [String: String] = [:]
    private var characteristicNametoUUID: [String: String] = [:]

    
    init() {
        // Device Info Service
        UUIDtoCharacteristicName.updateValue("Firmware Version", forKey: "DBE12BA0-C97A-4976-B71B-40267411338C")
        UUIDtoCharacteristicName.updateValue("System Power", forKey: "bf764404-f6e0-11e9-aad5-362b9e155667".uppercased())
        
        characteristicNametoUUID.updateValue("DBE12BA0-C97A-4976-B71B-40267411338C", forKey: "Firmware Version")
        characteristicNametoUUID.updateValue("bf764404-f6e0-11e9-aad5-362b9e155667".uppercased(), forKey: "System Power")
        
        // Sensing Configuration Serivce
        UUIDtoCharacteristicName.updateValue("Queue Repeat Count", forKey: "bbc837d1-b070-4d6c-9125-955eb64cd151".uppercased())
        UUIDtoCharacteristicName.updateValue("Start/Stop Queue", forKey: "aea9435c-96e9-4bca-bee4-4a1d3961bfef".uppercased())
        
        characteristicNametoUUID.updateValue("bbc837d1-b070-4d6c-9125-955eb64cd151".uppercased(), forKey: "Queue Repeat Count")
        characteristicNametoUUID.updateValue("aea9435c-96e9-4bca-bee4-4a1d3961bfef".uppercased(), forKey: "Start/Stop Queue")
        
        // Ampero Configuration Service
        UUIDtoCharacteristicName.updateValue("Electrode Selection", forKey: "aea9435c-96e9-4bca-bee4-4a1d3961bfef".uppercased())
        UUIDtoCharacteristicName.updateValue("Potential", forKey: "AB1745C8-FAAC-4858-874D-139AEE7EE06C")
        UUIDtoCharacteristicName.updateValue("Initial Delay", forKey: "08F8BA7E-E228-4EF5-9420-753642BBB087")
        UUIDtoCharacteristicName.updateValue("Sample Count", forKey: "F539D25E-1C00-44FE-AE81-10F1FCF7A634")
        UUIDtoCharacteristicName.updateValue("Sample Period", forKey: "ABD11F7C-C6AB-4C54-B34D-FF80343FD7E9")
        UUIDtoCharacteristicName.updateValue("Gain", forKey: "507e21b4-da96-40e5-8ca4-67321fb2ab3b".uppercased())
        
        characteristicNametoUUID.updateValue("aea9435c-96e9-4bca-bee4-4a1d3961bfef".uppercased(), forKey: "Electrode Selection")
        characteristicNametoUUID.updateValue("AB1745C8-FAAC-4858-874D-139AEE7EE06C", forKey: "Potential")
        characteristicNametoUUID.updateValue("08F8BA7E-E228-4EF5-9420-753642BBB087", forKey: "Initial Delay")
        characteristicNametoUUID.updateValue("F539D25E-1C00-44FE-AE81-10F1FCF7A634", forKey: "Sample Count")
        characteristicNametoUUID.updateValue("ABD11F7C-C6AB-4C54-B34D-FF80343FD7E9", forKey: "Sample Period")
        characteristicNametoUUID.updateValue("507e21b4-da96-40e5-8ca4-67321fb2ab3b".uppercased(), forKey: "Gain")
        
        // Ampero Output Data Service
        UUIDtoCharacteristicName.updateValue("Data Characteristic - current", forKey: "808C72E4-175E-4595-8CF1-AB07E49A8331")
        UUIDtoCharacteristicName.updateValue("Queue ID", forKey: "949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased())
        
        characteristicNametoUUID.updateValue("808C72E4-175E-4595-8CF1-AB07E49A8331", forKey: "Data Characteristic - current")
        characteristicNametoUUID.updateValue("949b35e0-8d39-4b03-a9b2-8fb370fa332f".uppercased(), forKey: "Queue ID")
    }
    
    func getCharacteristicName(characteristicUUID: String) -> String? {
        return UUIDtoCharacteristicName[characteristicUUID]
    }
    
    func getCharacteristicUUID(characteristicName: String) -> String? {
        return characteristicNametoUUID[characteristicName]
    }
}
