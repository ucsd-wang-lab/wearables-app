//
//  ViewController.swift
//  Bluetooth_connect
//
//  Created by neel shah on 7/16/19.
//  Copyright © 2019 neel shah. All rights reserved.
//

import UIKit
import CoreBluetooth
//import Charts

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //UI Related
    let defaultInitialPotential = -9999
    var lastPotential: Int!
    var keepScanning = false
    let timerScanInterval:TimeInterval = 10.0
    let timerPauseInterval:TimeInterval = 2.0
    let BatteyLevel = 0;
    var data_array = [Data]()
    //CoreBluetoothProperties
    var centralManager:CBCentralManager!
    var biosensor:CBPeripheral?
    var potentialCharacteristic: CBCharacteristic?
    let biosensorName = "HiThere"


   
    
    @IBOutlet weak var btLabel: UILabel!
    @IBAction func btConnect(_ sender: Any) {
        print("WORKING!!!")
        centralManager = CBCentralManager(delegate: self, queue: nil) //Starts scanning using ble
        
        
    }
    //Generic write function
    //UI 
    override func viewDidLoad() {
        super.viewDidLoad()
        lastPotential = defaultInitialPotential
        
        // Create our CBCentral Manager
        // delegate: The delegate that will receive central role events. Typically self.
        // queue:    The dispatch queue to use to dispatch the central role events.
        //           If the value is nil, the central manager dispatches central role events using the main queue.
       
    }
    override func viewWillAppear(_ animated:Bool){
        if lastPotential != defaultInitialPotential{
            
        }
    }
    
    @objc func pauseScan(){
        print("*** Pausing Scan...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
        //enable disconnect button
    }
    
    @objc func resumeScan(){
        if keepScanning{
            print("*** Resuming Scan!")
            //disconnectButton.enabled = false
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices:nil, options: nil)
            
        }else{
            
            //disconnectButton.enabled = true
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var showAlert = true
        var message = ""
        
        switch central.state{
            
        case.poweredOff:
            message = "Bluetooth Device is currently off"
            
        case.unknown:
            message = "The state of Bluetooth is unknown"
            
        case.resetting:
            message = "currently resetting"
            
        case.unsupported:
            message = "This device doesn't currently support Bluetooth communications"
            btLabel.text = "This device doesn't currently support Bluetooth communications"
            
        case.unauthorized:
            message = "This app is not authorized to use Bluetooth"
            
        case.poweredOn:
            showAlert = false
            message = "Bluetooth is ready for communication"
            print(message)
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            //Ask for service cbuuid, if only one device needs to be scanned
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        if showAlert{
            print(message)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String{
//            print("NEXT PERIPHERAL NAME: \(peripheralName)")
//            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            if peripheralName == biosensorName{
                print("Microneedle Found! Now Connecting")
                keepScanning = false
                //enable the disconnect button = True
                
                biosensor = peripheral
                biosensor!.delegate = self
                
                // Request a CONNECTION to the peripheral
                centralManager.connect(biosensor!, options: nil)
            }
        }
       
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected")
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "nextView") as! NextViewController
//        self.present(nextViewController, animated:true, completion:nil)
        //Now that we're connected to the sensor we can discover the bluetooth services
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connection FAILED!")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected From BioSensor")
        biosensor = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil{
            print("Error Discovering Services")
            return
        }
        if let services = peripheral.services{
            for service in services{
                print("Discovered Service\(service)")
                //DISCOVERING AN EXAMPLE SERVICE
                if (service.uuid == CBUUID(string: "B8B6B745-A99E-4B29-975E-76347005B273")){
                    print("I GOT THE SERVICE")
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                // CHEKC FOR UUID's
                //BASED ON SERVICE THAT NEEDS TO BE EXTRACTED
                // BASED ON CHARACTERSTIC
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil{
            print("Error Discovering Characteristics")
            return
        }
        
        if let characteristics = service.characteristics {
            print("I GET HERE ")
            for characteristic in characteristics{
//                print(characteristic)
                if characteristic.uuid == CBUUID(string: "808C72E4-175E-4595-8CF1-AB07E49A8331"){
                    print("Inside amperoservice char")
                    biosensor?.setNotifyValue(true, for: characteristic)
                    print(measureAmpero(from: characteristic))
                    print("printed_value")
                    
                    }
            }
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription)")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: "808C72E4-175E-4595-8CF1-AB07E49A8331"){
                print("Microneedle, updatedValue")

            }
        //ADD CHARACTER UUID
                print(dataBytes)
            }
        }
    private func measureAmpero(from characteristic: CBCharacteristic) -> Int{
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        let firstBitValue = byteArray[0] & 0x01
        return (Int(byteArray[0]) << 8) + Int(byteArray[1])
    }
}

    
    

    
    
    

  
    
//    @IBAction func handleDisconnectButtonTapped(sender: AnyObject){
//        if biosensor == nil{
//            keepscanning = true
//            resumeScan()
//            return
//        } else{
//            disconnect()
//        }
//    }
    




