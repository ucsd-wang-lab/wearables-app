//
//  DashboardViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BLEStatusObserver, BLEValueUpdateObserver, BLECharacteristicObserver{

    var id: Int = 1
    
    // Status Observer
    func deviceDisconnected(with device: String) {
        if device == self.deviceName{
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
    
    func characteristicDiscovered(with characteristicUUIDString: String) {
        if let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString) {
        
            if name == "Battery Level"{
                readBatteryLevel()
            }
            else if name == "Firmware Revision"{
                readFirmwareVersion()
            }
            else if name == "Potential"{
                readBiasPotential()
            }
            else if name == "Sample Period"{
                readSamplePeriod()
            }
            else if name == "Sample Count"{
                readSampleCount()
            }
            else if name == "Gain"{
                readGain()
            }
        }
    }
    
    // Characteristic Value Update Observer
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Battery Level" {
            let batteryLevel = value.uint8
            self.value[0] = String(batteryLevel)
            self.dashboardTableView.reloadData()
        }
        else if characteristicUUIDString == "Firmware Revision"{
            let firmwareVersion = String.init(data: value , encoding: .utf8) ?? "nil"
            self.value[1] = firmwareVersion
            self.dashboardTableView.reloadData()
        }
        else if characteristicUUIDString == "Potential"{
            let test = value.toByteArray()
            for byte in test{
                print("byte = ", byte)
            }
            let biasPotential = value.uint16
            self.value[2] = String(biasPotential)
            self.dashboardTableView.reloadData()
        }
        else if characteristicUUIDString == "Sample Period"{
            let samplingPeriod = value.uint16
            self.value[3] = String(samplingPeriod)
            self.dashboardTableView.reloadData()
        }
        else if characteristicUUIDString == "Sample Count"{
            let sampleCount = value.uint16
            self.value[4] = String(sampleCount)
            self.dashboardTableView.reloadData()
        }
        else if characteristicUUIDString == "Gain"{
            let gain = value.uint8
            self.value[5] = String(gain)
            self.dashboardTableView.reloadData()
        }
    }
    
    func writeResponseReceived(with characteristicUUIDString: String){
        let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString)
        if name == "Start/Stop Queue"{
            let storyboard = UIStoryboard(name: "Charts", bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! ChartsViewController
            controller.modalPresentationStyle = .fullScreen
            controller.deviceName = self.deviceName
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
                BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
            }
        }
    }
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    
    var deviceName: String?
    
    let keys = ["Battery Level", "Firmware Version", "Bias Potential", "Sampling Time", "Sample Count", "Gain", "Electrode Mask"]
    var value = ["xx", "x.x.x", "0/1", "xxxx", "xx", "xxx", "xxxx xxxx"]
    let suffix = [" %", "", " mV", " ms", "", " x", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to change view when keyboard appeards
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        
        deviceNameLabel.text = deviceName
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLECharacteristicObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
    }
    
    // when touched anywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touched somewhere on the screen...")
        self.view.endEditing(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // do nothing
    }
    
    // objective-c function for when keyboard appears
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -(self.view.frame.width * 0.40)
    }
    
    // objective-c function for when keyboard disappear
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    // when hitting enter on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected: ", indexPath.row)
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editable_cell") as! DashboardEditableCell
        cell.key_label.text = keys[indexPath.row]
//        cell.value_label.text = value[indexPath.row]
        cell.value_label.placeholder = value[indexPath.row]
        cell.value_label.delegate = self
        cell.suffix_label.text = suffix[indexPath.row]
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == keys.count - 1{
            cell.value_label.isUserInteractionEnabled = false
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    private func readBatteryLevel(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Battery Level")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    
    private func readFirmwareVersion(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Firmware Revision")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    
    private func readBiasPotential(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Potential")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    
    private func readSamplePeriod(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Sample Period")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    
    private func readSampleCount(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Sample Count")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    
    private func readGain(){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Gain")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    

    
    @IBAction func startMeasurementClicked(_ sender: Any) {
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)        
    }
    
    @IBAction func disconnectClicked(_ sender: Any) {
        BluetoothInterface.instance.disconnect()
    }
}
