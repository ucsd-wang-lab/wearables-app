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
        UUIDtoServiceName.updateValue("Ampero Data Service", forKey: "B8B6B745-A99E-4B29-975E-76347005B273")
        UUIDtoServiceName.updateValue("Potentio Configuration Service ", forKey: "5A0E4911-AEFC-4A82-AA80-FB8A178E6FE2")
        UUIDtoServiceName.updateValue("Sensing Configuration Service", forKey: "6760110a-956f-4a92-8744-64326cbee033".uppercased())
        UUIDtoServiceName.updateValue("Power Service", forKey: "139CDD4D-2F80-492C-ADE6-6D91F920C920")
        UUIDtoServiceName.updateValue("Square Wave Voltemetry Data Service", forKey: "BBC3A661-95DD-47DD-A4D8-9D0DADB1E47D")
        UUIDtoServiceName.updateValue("Square Wave Configuration Service", forKey: "20542BD7-A8D8-418B-96CA-244B815C5BE6")
        UUIDtoServiceName.updateValue("Delay Configuration Service", forKey: "de1b05ee-9445-4b4c-9426-e38addd512cd".uppercased())
        UUIDtoServiceName.updateValue("WICED Smart Update Service", forKey: "9E5D1E47-5C13-43A0-8635-82AD38A1386F")
        
        
        serviceNametoUUID.updateValue("180A", forKey: "Device Info Service")
        serviceNametoUUID.updateValue("180F", forKey: "Battery Service")
        serviceNametoUUID.updateValue("62C5963D-E0F9-4BFD-9599-739C56147CF7", forKey: "Ampero Configuration Service")
        serviceNametoUUID.updateValue("B8B6B745-A99E-4B29-975E-76347005B273", forKey: "Ampero Output Data Service")
        serviceNametoUUID.updateValue("5A0E4911-AEFC-4A82-AA80-FB8A178E6FE2", forKey: "Potentio Configuration Service")
        serviceNametoUUID.updateValue("6760110a-956f-4a92-8744-64326cbee033".uppercased(), forKey: "Sensing Configuration Service")
        serviceNametoUUID.updateValue("139CDD4D-2F80-492C-ADE6-6D91F920C920", forKey: "Power Service")
        serviceNametoUUID.updateValue("BBC3A661-95DD-47DD-A4D8-9D0DADB1E47D", forKey: "Square Wave Voltemetry Data Service")
        serviceNametoUUID.updateValue("20542BD7-A8D8-418B-96CA-244B815C5BE6", forKey: "Square Wave Configuration Service")
        serviceNametoUUID.updateValue("9E5D1E47-5C13-43A0-8635-82AD38A1386F", forKey: "WICED Smart Update Service")
        serviceNametoUUID.updateValue("de1b05ee-9445-4b4c-9426-e38addd512cd".uppercased(), forKey: "Delay Configuration Service")
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

/*
 * 0: Ampero
 * 1: Potentio
 * 2: Square Wave
 */
var CHARACTERISTIC_VALUE_MIN_VALUE: [Int: [String: Int]] = [0: ["Potential": -1000,
                                                                 "Initial Delay": 0,
                                                                 "Sample Period": 100,
                                                                 "Sample Count": 0,
                                                                 "Gain": 0
                                                                ],
                                                             1: ["Initial Delay": 0,
                                                                 "Sample Period": 100,
                                                                 "Sample Count": 0,
                                                                 "Filter Level": 0
                                                                ],
                                                             2: ["Quiet Time": 0,
                                                                 "Num Steps": 0,
                                                                 "Frequency": 1,
                                                                 "Amplitude": 0,
                                                                 "Initial Potential": -1000,
                                                                 "Final Potential": -1000,
                                                                 "Gain Level": 0]
                                                            ]

/*
* 0: Ampero
* 1: Potentio
* 2: Square Wave
*/
var CHARACTERISTIC_VALUE_MAX_VALUE: [Int: [String: Int]] = [0: ["Potential": 1000,
                                                                 "Initial Delay": Int(UInt16.max),
                                                                 "Sample Period": Int(UInt16.max),
                                                                 "Sample Count": Int(UInt16.max),
                                                                 "Gain": 27
                                                                ],
                                                             1: ["Initial Delay": Int(UInt16.max),
                                                                 "Sample Period": Int(UInt16.max),
                                                                 "Sample Count": Int(UInt16.max),
                                                                 "Filter Level": 255
                                                                ],
                                                             2: ["Quiet Time": Int(UInt16.max),
                                                                 "Num Steps": 255,
                                                                 "Frequency": 100,
                                                                 "Amplitude": 1000,
                                                                 "Initial Potential": 1000,
                                                                 "Final Potential": 1000,
                                                                 "Gain Level": 255]
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
        setCharacteristicDataType()
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
        UUIDtoCharacteristicName.updateValue("Queue Complete", forKey: "b49fc394-215b-466b-95b7-e41b88c45cd7".uppercased())
        UUIDtoCharacteristicName.updateValue("Mode Select", forKey: "a27bcda3-ecac-4980-be9f-df3a69d8bf0f".uppercased())
        
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
        
        // Potentiometric Configuration Service
        UUIDtoCharacteristicName.updateValue("Electrode Mask - Potentio", forKey: "ef038284-c179-4000-a816-c282c04b29cc".uppercased())
        UUIDtoCharacteristicName.updateValue("Initial Delay - Potentio", forKey: "f73751bf-1cde-4872-b91a-4caa18fea39b".uppercased())
        UUIDtoCharacteristicName.updateValue("Sample Count - Potentio", forKey: "9be83c18-a9f8-403d-a2eb-6066ddbaf247".uppercased())
        UUIDtoCharacteristicName.updateValue("Sample Period - Potentio", forKey: "1ac6cd7c-e449-42e6-8324-029e89fec5a7".uppercased())
        UUIDtoCharacteristicName.updateValue("Filter Level - Potentio", forKey: "31EFBCE5-0036-4F83-8F34-F3FFFA31D30C")
        
        // Potentiometric Data Service
//        UUIDtoCharacteristicName.updateValue("Start/Stop Potentiometry", forKey: "2e0b45c2-e649-4591-ae5e-840960863efa".uppercased())
        UUIDtoCharacteristicName.updateValue("Data Characteristic - Potential", forKey: "3e0152be-4183-4b6b-bd13-920322432016".uppercased())
    
        // Square Wave Configuration Service
        UUIDtoCharacteristicName.updateValue("Electrode Mask - SW", forKey: "b34ef3c2-7915-4282-a18a-2e601a3ca9ee".uppercased())
        UUIDtoCharacteristicName.updateValue("Quiet Time", forKey: "a6ab1ab5-cb0d-4817-97a4-ce625a2b9fa7".uppercased())
        UUIDtoCharacteristicName.updateValue("Num Steps", forKey: "cd20384d-5dcf-4990-9828-ef9af6411e61".uppercased())
        UUIDtoCharacteristicName.updateValue("Frequency", forKey: "4185caaa-7521-495b-95f6-93c69c28ec1a".uppercased())
        UUIDtoCharacteristicName.updateValue("Amplitude", forKey: "02398c09-49ee-44a4-86b9-ad39319e2185".uppercased())
        UUIDtoCharacteristicName.updateValue("Initial Potential", forKey: "7ae197df-c5cb-432d-a74d-9a8cd1b67e3a".uppercased())
        UUIDtoCharacteristicName.updateValue("Final Potential", forKey: "d0b102f6-d279-4c49-ae98-7ecf326eccc3".uppercased())
        UUIDtoCharacteristicName.updateValue("Gain Level", forKey: "1a00d2c0-b7b9-4a19-ba2b-f7e5168439f6".uppercased())
        
        // Square Wave Data Service
        UUIDtoCharacteristicName.updateValue("Data Characteristic - SW Current", forKey: "08f720e0-318a-40bf-8769-6acf946e3b32".uppercased())
        
        
        // Delay Configuration Service
        UUIDtoCharacteristicName.updateValue("Delay Duration", forKey: "6f8a2760-fe81-43a5-b354-3dfa77f02e77".uppercased())
        
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
        characteristicNametoUUID.updateValue("b49fc394-215b-466b-95b7-e41b88c45cd7".uppercased(), forKey: "Queue Complete")
        characteristicNametoUUID.updateValue("a27bcda3-ecac-4980-be9f-df3a69d8bf0f".uppercased(), forKey: "Mode Select")
        
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
        
        // Potentiometric Configuration Service
        characteristicNametoUUID.updateValue("ef038284-c179-4000-a816-c282c04b29cc".uppercased(), forKey: "Electrode Mask - Potentio")
        characteristicNametoUUID.updateValue("f73751bf-1cde-4872-b91a-4caa18fea39b".uppercased(), forKey: "Initial Delay - Potentio")
        characteristicNametoUUID.updateValue("9be83c18-a9f8-403d-a2eb-6066ddbaf247".uppercased(), forKey: "Sample Count - Potentio")
        characteristicNametoUUID.updateValue("1ac6cd7c-e449-42e6-8324-029e89fec5a7".uppercased(), forKey: "Sample Period - Potentio")
        characteristicNametoUUID.updateValue("31EFBCE5-0036-4F83-8F34-F3FFFA31D30C", forKey: "Filter Level - Potentio")
        
        // Potentiometric Data Service
//        characteristicNametoUUID.updateValue("2e0b45c2-e649-4591-ae5e-840960863efa".uppercased(), forKey:"Start/Stop Potentiometry")
        characteristicNametoUUID.updateValue("3e0152be-4183-4b6b-bd13-920322432016".uppercased(), forKey: "Data Characteristic - Potential")
    
        // Square Wave Configuration Service
        characteristicNametoUUID.updateValue("b34ef3c2-7915-4282-a18a-2e601a3ca9ee".uppercased(), forKey: "Electrode Mask - SW")
        characteristicNametoUUID.updateValue("a6ab1ab5-cb0d-4817-97a4-ce625a2b9fa7".uppercased(), forKey: "Quiet Time")
        characteristicNametoUUID.updateValue("cd20384d-5dcf-4990-9828-ef9af6411e61".uppercased(), forKey: "Num Steps")
        characteristicNametoUUID.updateValue("4185caaa-7521-495b-95f6-93c69c28ec1a".uppercased(), forKey: "Frequency")
        characteristicNametoUUID.updateValue("02398c09-49ee-44a4-86b9-ad39319e2185".uppercased(), forKey: "Amplitude")
        characteristicNametoUUID.updateValue("7ae197df-c5cb-432d-a74d-9a8cd1b67e3a".uppercased(), forKey: "Initial Potential")
        characteristicNametoUUID.updateValue("d0b102f6-d279-4c49-ae98-7ecf326eccc3".uppercased(), forKey: "Final Potential")
        characteristicNametoUUID.updateValue("1a00d2c0-b7b9-4a19-ba2b-f7e5168439f6".uppercased(), forKey: "Gain Level")
        
        // Square Wave Data Service
        characteristicNametoUUID.updateValue("08f720e0-318a-40bf-8769-6acf946e3b32".uppercased(), forKey: "Data Characteristic - SW Current")
        
        
        // Delay Configuration Service
        characteristicNametoUUID.updateValue("6f8a2760-fe81-43a5-b354-3dfa77f02e77".uppercased(), forKey: "Delay Duration")
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
        characteristicProperty.updateValue("Read/Notify", forKey: "Queue Complete")
        characteristicProperty.updateValue("Read/Write", forKey: "Mode Select")
        
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
        
        // Potentiometric Configuration Service
        characteristicProperty.updateValue("Read/Write", forKey: "Electrode Mask - Potentio")
        characteristicProperty.updateValue("Read/Write", forKey: "Initial Delay - Potentio")
        characteristicProperty.updateValue("Read/Write", forKey: "Sample Count - Potentio")
        characteristicProperty.updateValue("Read/Write", forKey: "Sample Period - Potentio")
        characteristicProperty.updateValue("Read/Write", forKey: "Filter Level - Potentio")
        
        // Potentiometric Data Service
//        characteristicProperty.updateValue("Read/Write", forKey:"Start/Stop Potentiometry")
        characteristicProperty.updateValue("Read/Notify", forKey: "Data Characteristic - Potential")
        
        // Square Wave Configuration Service
        characteristicProperty.updateValue("Read/Write", forKey: "Electrode Mask - SW")
        characteristicProperty.updateValue("Read/Write", forKey: "Quiet Time")
        characteristicProperty.updateValue("Read/Write", forKey: "Num Steps")
        characteristicProperty.updateValue("Read/Write", forKey: "Frequency")
        characteristicProperty.updateValue("Read/Write", forKey: "Amplitude")
        characteristicProperty.updateValue("Read/Write", forKey: "Initial Potential")
        characteristicProperty.updateValue("Read/Write", forKey: "Final Potential")
        characteristicProperty.updateValue("Read/Write", forKey: "Gain Level")
        
        // Square Wave Data Service
        characteristicProperty.updateValue("Read/Notify", forKey: "Data Characteristic - SW Current")
        
        
        // Delay Configuration Service
        characteristicProperty.updateValue("Read/Write", forKey: "Delay Duration")
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
        characteristicDataType.updateValue(UInt8(), forKey: "Queue Complete")
        characteristicDataType.updateValue(UInt8(), forKey: "Mode Select")
        
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
        
        // Potentiometric Configuration Service
        characteristicDataType.updateValue(UInt8(), forKey: "Electrode Mask - Potentio")
        characteristicDataType.updateValue(UInt16(), forKey: "Initial Delay - Potentio")
        characteristicDataType.updateValue(UInt16(), forKey: "Sample Count - Potentio")
        characteristicDataType.updateValue(UInt16(), forKey: "Sample Period - Potentio")
        characteristicDataType.updateValue(UInt8(), forKey: "Filter Level - Potentio")

        
        // Potentiometric Data Service
        //        characteristicProperty.updateValue("Read/Write", forKey:"Start/Stop Potentiometry")
        characteristicDataType.updateValue(Int32(), forKey: "Data Characteristic - Potential")
        
        // Square Wave Configuration Service
        characteristicDataType.updateValue(UInt8(), forKey: "Electrode Mask - SW")
        characteristicDataType.updateValue(UInt16(), forKey: "Quiet Time")
        characteristicDataType.updateValue(UInt8(), forKey: "Num Steps")
        characteristicDataType.updateValue(UInt8(), forKey: "Frequency")
        characteristicDataType.updateValue(UInt16(), forKey: "Amplitude")
        characteristicDataType.updateValue(Int16(), forKey: "Initial Potential")
        characteristicDataType.updateValue(Int16(), forKey: "Final Potential")
        characteristicDataType.updateValue(UInt8(), forKey: "Gain Level")
        
        // Square Wave Data Service
        characteristicDataType.updateValue(Int32(), forKey: "Data Characteristic - SW Current")
        
        
        // Delay Configuration Service
        characteristicDataType.updateValue(UInt16(), forKey: "Delay Duration")
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
