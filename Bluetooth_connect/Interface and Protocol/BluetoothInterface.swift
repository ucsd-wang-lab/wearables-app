//
//  BluetoothInterface.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothInterface: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    static var instance = BluetoothInterface.init()
    
    override init() {
        super.init()
        print("Bluetooth Manager init")
//        ServiceUUID.instance.doNothig()
//        CharacteristicsUUID.instance.doNothin()
    }
    
    func initVar() {
        print("init vars for BTInterface")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        connectedPeripheral = nil
        self.serviceDictionary = [:]
    }
    
    //This is a required function of the CBCentralManager
    //Called when state of CBCentralanager is updated (when it is initialized)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Starting Scan")
            notifyBTStatus(statue: true)
            startScan()
        }
        else {
            notifyBTStatus(statue: false)
            print("Turn on Bluetooth on phone and Microneedle")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = peripheral.name  {
//            notifyBLEObserver(bleName: name, device: peripheral)
            if name.contains("Microneedle"){
                // do nothing
                notifyBLEObserver(bleName: name, device: peripheral)
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        if nil == self.connectedPeripheral {
            self.connectedPeripheral = peripheral
            self.connectedPeripheral.delegate = self        //Allowing the peripheral to discover services
            print("connected to: \(peripheral.name!)")
            self.notifyBLEStatusConnect(bleName: peripheral.name!)
            self.connectedPeripheral.discoverServices(nil)      //look for services for the specified peripheral
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect with device...", error.debugDescription)
        notifyBLEFailToConnect(bleName: peripheral.name!, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //Do Nothing for now
        if let name = peripheral.name{
            print("Peripheral Disconnected: ", name)
            notifyBLEStatusDisconnect(bleName: name)
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Do nothing for now
        if peripheral.state == .poweredOff{
            notifyBLEFailToConnect(bleName: "", error: nil)
            print("peripheral is poweroff")
        }
        else if peripheral.state == .unsupported{
            print("peripheral is unsupported")
        }
        else if peripheral.state == .unknown{
            print("peripheral is unknown")
        }
        else if peripheral.state == .unauthorized{
            print("peripheral is unauthorized")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {

            for service in services{
//                print("service = ", ServiceUUID.instance.getServiceName(serviceUUID: service.uuid.uuidString))
                self.connectedPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            self.serviceDictionary[service] = service.characteristics

            for characteristic in characteristics{
//                print("Characteristics = ", characteristic.uuid.uuidString)
                if let _ = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristic.uuid.uuidString) {
//                    print("characteristics = ", name)
//
//                    if name == "Electrode Selection"{
//                        print("Found Electrode Mast Selection")
//                    }
                    
                    characteristicDictionary.updateValue(characteristic, forKey: characteristic.uuid.uuidString)
                    notifyBLECharacteristicObserver(characteristicUUIDString: characteristic.uuid.uuidString)
                    
                    if (characteristic.properties.rawValue & CHARACTERISTICS_PROPERTIES.NOTIFY.rawValue) != 0{
//                        print("characteristics notify = ", name)
                        self.connectedPeripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    }
    

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("write update received...")
        notifyBLEWriteResponseReceived(characteristicUUIDString: characteristic.uuid.uuidString)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didUpdateValueFor: ", characteristic)
        if let data = characteristic.value {
            let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristic.uuid.uuidString)!
            notifyBLEValueUpdate(bleName: name, data: data)
        }
    }
    
    func readData(characteristicUUIDString characteristicUUID: String){
//        print("reading from characteristic = ", characteristicUUID)
        let characteristic = characteristicDictionary[characteristicUUID]!
        self.connectedPeripheral.readValue(for: characteristic)
    }
    
    func writeData(data: Data, characteristicUUIDString: String) {
        print("writing to uuid: ", characteristicUUIDString)
        let characteristic = characteristicDictionary[characteristicUUIDString]!
        
        print("writing to ", CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString) ?? "nil")
        
        if (characteristic.properties.rawValue & CHARACTERISTICS_PROPERTIES.WRITE_WITHOUT_RESPONSE.rawValue) != 0 {
            self.connectedPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        }
        else{
            self.connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    public func startScan() {
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopScan(){
        centralManager?.stopScan()
    }
    
    public func connect(peripheral: CBPeripheral){
        self.centralManager.connect(peripheral, options: nil)
    }
    
    public func disconnect(){
        self.centralManager.cancelPeripheralConnection(self.connectedPeripheral)
    }
    
    var connectedPeripheral: CBPeripheral!
    var deviceName = "Microneedle"
    
    private var centralManager: CBCentralManager!
    private var serviceDictionary: [CBService: [CBCharacteristic]]!
    private var characteristicDictionary: [String: CBCharacteristic] = [:]
    
    /// #################################################################################
    /// #################################################################################
    /// #################################################################################
    // Observer pattern
    private var bleObserver: [Int:BLEDiscoveredObserver] = [:]
    private var bleStatusObserver: [Int: BLEStatusObserver] = [:]
    private var bleCharacteristicObserver: [Int: BLECharacteristicObserver] = [:]
    private var bleValueUpdateObserver: [Int: BLEValueUpdateObserver] = [:]
    
    // START: BLEDiscoveredObserver
    func attachBLEDiscoveredObserver(id: Int, observer: BLEDiscoveredObserver){
        bleObserver.updateValue(observer, forKey: id)
    }
    
    func detachBLEDiscoveredObserver(id: Int){
        bleObserver.removeValue(forKey: id)
    }
    
    private func notifyBLEObserver(bleName: String, device: CBPeripheral){
        for (_, observer) in bleObserver{
            observer.update(with: bleName, with: device)
        }
    }
    
    private func notifyBTStatus(statue: Bool){
        for (_, observer) in bleObserver{
            observer.didBTEnable(with: statue)
        }
    }
    // END: BLEDiscoveredObserver
    
    // START: BLEStatusObserver
    func attachBLEStatusObserver(id: Int, observer: BLEStatusObserver){
        bleStatusObserver.updateValue(observer, forKey: id)
    }
    
    func detachBLEStatusObserver(id: Int){
        bleStatusObserver.removeValue(forKey: id)
    }
    
    private func notifyBLEStatusDisconnect(bleName: String){
        for (_, observer) in bleStatusObserver{
            observer.deviceDisconnected?(with: bleName)
        }
    }
    
    private func notifyBLEStatusConnect(bleName: String){
        for (_, observer) in bleStatusObserver{
            observer.deviceConnected?(with: bleName)
        }
    }
    
    private func notifyBLEFailToConnect(bleName: String, error: Error?){
        for (_, observer) in bleStatusObserver{
            observer.deviceFailToConnect?(with: bleName, error: error)
        }
    }
    // END: BLEStatusObserver
    
    // START BLECharacteristicObserver
    func attachBLECharacteristicObserver(id: Int, observer: BLECharacteristicObserver){
        bleCharacteristicObserver.updateValue(observer, forKey: id)
    }
    
    func detachBLECharacteristicObserver(id: Int){
        bleCharacteristicObserver.removeValue(forKey: id)
    }
    
    private func notifyBLECharacteristicObserver(characteristicUUIDString: String){
        for (_, observer) in bleCharacteristicObserver{
            observer.characteristicDiscovered(with: characteristicUUIDString)
        }
    }
    // END: BLECharacteristicObserver
    
    // START: BLEValueUpdateObserver
    func attachBLEValueObserver(id: Int, observer: BLEValueUpdateObserver){
        bleValueUpdateObserver.updateValue(observer, forKey: id)
    }
    
    func detachBLEValueObserver(id: Int){
        bleValueUpdateObserver.removeValue(forKey: id)
    }
    
    private func notifyBLEValueUpdate(bleName: String, data: Data){
        for (_, observer) in bleValueUpdateObserver{
            observer.update(with: bleName, with: data)
        }
    }
    
    private func notifyBLEWriteResponseReceived(characteristicUUIDString: String){
        for (_, observer) in bleValueUpdateObserver{
            observer.writeResponseReceived?(with: characteristicUUIDString)
        }
    }
    // END: BLEValueUpdateObserver

}
