//
//  MeasurementSelection.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/10/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class MeasurementSelection: UIViewController {

    @IBOutlet weak var measurementTableView: UITableView!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var deviceSetupLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var measurementTechniqueLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    let tableCellHeight = 65
    let measurement = ["Amperometry", "Potentiometry"]
    let key = ["Battery Level", "Firmware Revision"]
    private var switchScreen = false
    
    var deviceName: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeLayout()
        
        measurementTableView.delegate = self
        measurementTableView.dataSource = self
        
        infoTableView.delegate = self
        infoTableView.dataSource = self
                
        if let name = deviceName{
            deviceNameLabel.text = name
        }
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLECharacteristicObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableCellHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == infoTableView{
            return key.count
        }
        else{
            return measurement.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == infoTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "info_cell") as! InfoCell
            cell.keyLabel.text = key[indexPath.row]
            cell.valueLabel.text = CHARACTERISTIC_VALUE[key[indexPath.row]]
            
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "measurement_cell") as! MeasurementCell
            cell.measurement.text = measurement[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == measurementTableView{
            
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! DashboardViewController
            controller.deviceName = deviceName
            controller.measurementType = measurement[indexPath.row]
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
                BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
            }
            
        }
    }
    
    @IBAction func disconnectButtonClicked(_ sender: Any) {
        BluetoothInterface.instance.disconnect()
        switchScreen = true
        
        if !BluetoothInterface.instance.isConnected {
            let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
               let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
               controller.modalPresentationStyle = .fullScreen
               self.present(controller, animated: true) {
                   // do nothing....
                   BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                   BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
                   BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
               }
        }
    }
}

extension MeasurementSelection: UITableViewDelegate, UITableViewDataSource, BLEStatusObserver, BLEValueUpdateObserver, BLECharacteristicObserver{
    
    func customizeLayout(){
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let disconnectFrame = CGRect(x: width * 0.05, y: height * 0.05, width: disconnectButton.frame.width, height: disconnectButton.frame.height)
        disconnectButton.frame = disconnectFrame
        
        let deviceSetupFrame = CGRect(x: (width * 0.5) - (deviceSetupLabel.frame.width / 2), y: height * 0.13, width: deviceSetupLabel.frame.width, height: deviceSetupLabel.frame.height)
        deviceSetupLabel.frame = deviceSetupFrame
        
        let deviceNameFrame = CGRect(x: (width * 0.5) - (deviceNameLabel.frame.width / 2), y: deviceSetupLabel.frame.maxY + 5, width: deviceNameLabel.frame.width, height: deviceNameLabel.frame.height)
        deviceNameLabel.frame = deviceNameFrame
        
        let infoTableFrame = CGRect(x: width * 0.05, y: deviceNameLabel.frame.maxY + 10, width: width * 0.9, height: CGFloat(tableCellHeight * 2))
        infoTableView.frame = infoTableFrame
        
        let measurementTechniqueFrame = CGRect(x: (width * 0.5) - (measurementTechniqueLabel.frame.width / 2), y: infoTableView.frame.maxY + 30, width: measurementTechniqueLabel.frame.width, height: measurementTechniqueLabel.frame.height)
        measurementTechniqueLabel.frame = measurementTechniqueFrame
        
        let measurementTableFrame = CGRect(x: width * 0.15, y: measurementTechniqueLabel.frame.maxY + 10, width: width * 0.7, height: CGFloat(tableCellHeight * 2))
        measurementTableView.frame = measurementTableFrame
        
        let infoLabelFrame = CGRect(x: (width * 0.5) - (infoLabel.frame.width / 2), y: measurementTableView.frame.maxY + 50, width: infoLabel.frame.width, height: infoLabel.frame.height)
        infoLabel.frame = infoLabelFrame
    }
    
    
    var id: Int {
        1
    }
    
    func characteristicDiscovered(with characteristicUUIDString: String) {
        if let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString) {

           if CHARACTERISTIC_VALUE[name] != nil{
                let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
           }
        }
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if CHARACTERISTIC_VALUE[characteristicUUIDString] != nil {
            let decodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristicUUIDString)
           
            if decodingType is UInt8{
                let data = value.uint8
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.infoTableView.reloadData()
            }
            else if decodingType is UInt16{
                let data = value.uint16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.infoTableView.reloadData()
            }
            else if decodingType is Int16{
                let data = value.int16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.infoTableView.reloadData()
            }
            else if decodingType is Int32{
                let data = value.int32
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.infoTableView.reloadData()
            }
            else if decodingType is String.Encoding.RawValue{
                let data = String.init(data: value , encoding: String.Encoding.utf8) ?? "nil"
                CHARACTERISTIC_VALUE.updateValue(data, forKey: characteristicUUIDString)
                self.infoTableView.reloadData()
            }
            
            if characteristicUUIDString == "Electrode Mask"{
                let data = value.uint8
                CHARACTERISTIC_VALUE.updateValue(String(data, radix: 2), forKey: characteristicUUIDString)
            }
        }
    }
    
    func deviceDisconnected(with device: String) {
        if device == self.deviceName{
            if switchScreen{
                let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
                let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true) {
                    // do nothing....
                    BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                    BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
                    BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
                }
            }
            else{
                BluetoothInterface.instance.disconnect()
                BluetoothInterface.instance.autoConnect = true
                BluetoothInterface.instance.startScan()
            }
        }
    }
    
}
