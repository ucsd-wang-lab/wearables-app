//
//  DashboardViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController{
    
    var id: Int = 2
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    
    var deviceName: String?
    var measurementType: String?

    var suffix_mapping: [String: String] = ["Battery Level": " %",
                                            "Firmware Revision": "",
                                            "Potential": " mV",
                                            "Initial Delay": " ms",
                                            "Sample Period": " ms",
                                            "Sample Count": "",
                                            "Gain": " x",
                                            "Electrode Mask": ""
                                             ]
    
    
    // Section 0: read-only value; Section 1: modifiable values
    var section_mapping: [Int: [String]] = [0:["Battery Level", "Firmware Revision"],
                                        1: ["Potential", "Initial Delay", "Sample Period",
                                            "Sample Count", "Gain", "Electrode Mask"]
                                        ]
    
    
    var getMeasurementID: [String: String] = ["Amperometry": "Start/Stop Queue",
                                              "Potentiometry": "Start/Stop Potentiometry"]
    
    
    var valueTextField:[Int: UITextField] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to change view when keyboard appeards
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        
        if let measurement = measurementType{
            deviceNameLabel.text = measurement
        }
        else{
            deviceNameLabel.text = "Amperometry"
        }
        
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
        self.view.frame.origin.y = -(self.view.frame.width * 0.45)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("Textfield end editing....\(textField.text)")
        for key in valueTextField.keys{
            let tf = valueTextField[key]
            if textField == tf {
                let name = section_mapping[1]![key]
                print("name = ", name)
                let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: name)
                let value = textField.text
                updateValue(name: name, encodingType: encodingType, value: value)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! DashboardEditableCell
            cell.value_label.becomeFirstResponder()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section_mapping[section]?.count ?? 0
//        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editable_cell") as! DashboardEditableCell
        cell.key_label.text = section_mapping[indexPath.section]![indexPath.row]
        cell.value_label.text = CHARACTERISTIC_VALUE[section_mapping[indexPath.section]![indexPath.row]]

        cell.value_label.delegate = self
        cell.suffix_label.text = suffix_mapping[section_mapping[indexPath.section]![indexPath.row]]

        if indexPath.section == 0{
            cell.value_label.isUserInteractionEnabled = false
        }
        else{
            valueTextField[indexPath.row] = cell.value_label
        }
        
        cell.selectionStyle = .none
//        addDoneButtonOnKeyboard(txtNumber: cell.value_label, tag: indexPath.row)
        cell.value_label.selectAll(nil)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        section_mapping.keys.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: dashboardTableView.frame.width, height: 0))
            view.backgroundColor = .clear
            return view
        }
        else{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            view.backgroundColor = .clear
            return view
        }
    }
    
    func addDoneButtonOnKeyboard(txtNumber: UITextField, tag: Int)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
      
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.done, target: self, action: #selector(saveClicked))
        done.tag = tag
      
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
      
        doneToolbar.items = items
        doneToolbar.sizeToFit()
      
        txtNumber.inputAccessoryView = doneToolbar
    }

    @objc func saveClicked(_ sender: Any){
        let button = sender as! UIBarButtonItem
        let name = section_mapping[1]![button.tag]
        print("name = ", name)
        let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: name)
        let indexPath = IndexPath(item: button.tag, section: 1)
        let cell = dashboardTableView.cellForRow(at: indexPath) as! DashboardEditableCell
                
        if let value = cell.value_label.text{
            if value == ""{
                showErrorMessage(message: "Value Field Cannot be empty")
                cell.value_label.becomeFirstResponder()
            }
            else if Int(value) == nil{
                showErrorMessage(message: "Value Field Must be a number")
                cell.value_label.becomeFirstResponder()
            }
            else{
                if name == "Electrode Mask"{
                    let data = UInt8(value, radix: 2) ?? nil
                    if data == nil {
                        let message = "Value Field must be valid 8-bit binary input"
                        showErrorMessage(message: message)
                    }
                    else{
                        var d = Data(count: 1)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else if encodingType is UInt8{
                    let data = UInt8(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 1)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                        
                    }
                }
                else if encodingType is UInt16{
                    let data = UInt16(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 2)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else if encodingType is Int16{
                    let data = Int16(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 2)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else{
                    showErrorMessage(message: "Error Sending Data to Firmware\nInvalid Data Type")
                    cell.value_label.becomeFirstResponder()
                }
            }
            
        }
        else{
            showErrorMessage(message: "Error Sending Data to Firmware...Contact Developer")
        }
        self.view.endEditing(true)
    }
    
    private func updateValue(name: String, encodingType: Any?, value: String?){
        if let value = value{
            if value == ""{
                showErrorMessage(message: "Value Field Cannot be empty")
            }
            else if Int(value) == nil{
                showErrorMessage(message: "Value Field Must be a number")
            }
            else{
                if name == "Electrode Mask"{
                    let data = UInt8(value, radix: 2) ?? nil
                    if data == nil {
                        let message = "Value Field must be valid 8-bit binary input"
                        showErrorMessage(message: message)
                    }
                    else{
                        var d = Data(count: 1)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else if encodingType is UInt8{
                    let data = UInt8(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 1)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                        
                    }
                }
                else if encodingType is UInt16{
                    let data = UInt16(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 2)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else if encodingType is Int16{
                    let data = Int16(value) ?? nil
                    if isValidValue(value: data, characteristicName: name){
                        var d = Data(count: 2)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else{
                    showErrorMessage(message: "Error Sending Data to Firmware\nInvalid Data Type")
                }
            }
            
        }
        else{
            showErrorMessage(message: "Error Sending Data to Firmware...Contact Developer")
        }
    }
    
    private func isValidValue(value: Any?, characteristicName: String) -> Bool {
        let type = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristicName)
        let minVal = CHARACTERISTIC_VALUE_MIN_VALUE[characteristicName]!
        let maxVal = CHARACTERISTIC_VALUE_MAX_VALUE[characteristicName]!
                
        if value == nil{
            let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
            showErrorMessage(message: message)
            return false
        }
        
        if type is UInt8{
            let val = value as! UInt8
            if val < minVal || val > maxVal{
                let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
                showErrorMessage(message: message)
                return false
            }
        }
        else if type is UInt16{
            let val = value as! UInt16
            if val < minVal || val > maxVal{
                let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
                showErrorMessage(message: message)
                return false
            }
        }
        else if type is Int16{
            let val = value as! Int16
            if val < minVal || val > maxVal{
                let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
                showErrorMessage(message: message)
                return false
            }
        }
        return true
    }
    
    private func sendDataToFirmware(data: Any, numOfBytes: Int, characteristicName name: String){
        var d = Data(count: numOfBytes)
        d = withUnsafeBytes(of: data) { Data($0) }
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        CHARACTERISTIC_VALUE.updateValue(data as! String, forKey: name)
    }
    
    @IBAction func startMeasurementClicked(_ sender: Any) {
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
//        d[0] = data
        d = withUnsafeBytes(of: data) { Data($0) }
//        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
//        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        if let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: getMeasurementID[deviceNameLabel.text!]!){
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else{
            showErrorMessage(message: "Enable to start measurement\nContact Developer")
        }
    }
    
    @IBAction func disconnectClicked(_ sender: Any) {
//        BluetoothInterface.instance.disconnect()
       
        let storyboard = UIStoryboard(name: "MeasurementSelection", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! MeasurementSelection
        controller.deviceName = deviceName
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true) {
            BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
            BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
            BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
        }
    
    }
    
    private func showErrorMessage(message: String){
        let alert = UIAlertController(title: "Error!!", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}


extension DashboardViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BLEStatusObserver, BLEValueUpdateObserver, BLECharacteristicObserver{
    
    // Status Observer
    func deviceDisconnected(with device: String) {
        if device == self.deviceName{
            BluetoothInterface.instance.disconnect()
            BluetoothInterface.instance.autoConnect = true
            BluetoothInterface.instance.startScan()
            
//           let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
//           let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
//           controller.modalPresentationStyle = .fullScreen
//           self.present(controller, animated: true) {
//               // do nothing....
//               BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
//               BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
//               BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
//           }
        }
    }
       
    func characteristicDiscovered(with characteristicUUIDString: String) {
        if let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString) {

           if CHARACTERISTIC_VALUE[name] != nil{
                let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
           }
        }
    }
       
    // Characteristic Value Update Observer
    func update(with characteristicUUIDString: String, with value: Data) {
        if CHARACTERISTIC_VALUE[characteristicUUIDString] != nil {
            let decodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristicUUIDString)
           
            if decodingType is UInt8{
                let data = value.uint8
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is UInt16{
                let data = value.uint16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is Int16{
                let data = value.int16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is Int32{
                let data = value.int32
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is String.Encoding.RawValue{
                let data = String.init(data: value , encoding: String.Encoding.utf8) ?? "nil"
                CHARACTERISTIC_VALUE.updateValue(data, forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            
            if characteristicUUIDString == "Electrode Mask"{
                let data = value.uint8
                CHARACTERISTIC_VALUE.updateValue(String(data, radix: 2), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
        }
    }
       
    func writeResponseReceived(with characteristicUUIDString: String){
        let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString)
        if name == "Start/Stop Queue" || name == "Start/Stop Potentiometry"{
            let storyboard = UIStoryboard(name: "Charts", bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! ChartsViewController
            controller.modalPresentationStyle = .fullScreen
            controller.deviceName = self.deviceName
            controller.chartTitle = measurementType
            
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                BluetoothInterface.instance.detachBLECharacteristicObserver(id: self.id)
                BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
            }
        }
    }
}
