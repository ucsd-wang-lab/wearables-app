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
    
    static let instance = BluetoothInterface.init()
    
    override init() {
        super.init()
        print("Bluetooth Manager init")
    }
    
    func initVar() {
        print("init vars for BTInterface")
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        peripheral = nil
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
        
        if peripheral.name != nil {
            print("Peripheral name: ", peripheral.name)
            self.discoveredPeripheral.updateValue(peripheral, forKey: peripheral.name!)
            notifyBLEObserver(bleName: peripheral.name!, device: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        if nil == self.connectedPeripheral {
            self.connectedPeripheral = peripheral
            self.connectedPeripheral.delegate = self        //Allowing the peripheral to discover services
            print("connected to: \(peripheral.name!)")
            self.notifyConnectedDevice(bleName: peripheral.name!)
            self.connectedPeripheral.discoverServices(nil)      //look for services for the specified peripheral
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        initVar()
        //Do Something
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Do nothing for now
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Listing all available services")
        print(peripheral.services)
        if let services = peripheral.services {
            for service in services{
                self.connectedPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            self.serviceDictionary[service] = service.characteristics
            for characteristic in characteristics{
                self.connectedPeripheral.setNotifyValue(true, for: characteristic)
                
                //                let data = "a\n".data(using: .utf8)!
                //                writeData(data: data, characteristic: characteristic)
            }
            print(serviceDictionary);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            notifyObservers(data: data)
            let val = String.init(data: data, encoding: .utf8) ?? "nil"
            //            print("val = ", val)
        }
        //        print(serviceDictionary)
    }
    
    private func notifyObservers(data: Data) {
        //        print("notifying observer")
        
    }
    
    func writeData(data: Data, characteristic: CBCharacteristic) {
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
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
    
    private var peripheral_Name = "Microneedle"
    private var centralManager: CBCentralManager!
    private var serviceDictionary: [CBService: [CBCharacteristic]]!
    private var discoveredPeripheral: [String: CBPeripheral] = [:]
    
    // Observer pattern
    private var bleObserver: [Int:BLEDiscoveredObserver] = [:]
    
    func attachBLEDiscoveredObserver(id: Int, observer: BLEDiscoveredObserver){
        bleObserver.updateValue(observer, forKey: id)
    }
    
    func detachBLEDiscoveredObserver(id: Int, observer: BLEDiscoveredObserver){
        bleObserver.removeValue(forKey: id)
    }
    
    private func notifyBLEObserver(bleName: String, device: CBPeripheral){
        for (_, observer) in bleObserver{
            observer.update(with: bleName, with: device)
        }
    }
    
    private func notifyConnectedDevice(bleName: String){
        for (_, observer) in bleObserver{
            observer.deviceConnected(with: bleName)
        }
    }
    
    private func notifyBTStatus(statue: Bool){
        for (_, observer) in bleObserver{
            observer.didBTEnable(with: statue)
        }
    }
}
