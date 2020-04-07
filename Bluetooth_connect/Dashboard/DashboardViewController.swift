//
//  DashboardViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BLEStatusObserver, BLEValueUpdateObserver, BLECharacteristicObserver{

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
        
            if self.value_mapping[name] != nil{
                readCharacteristicValue(characteristicName: name)
            }
        }
    }
    
    // Characteristic Value Update Observer
    func update(with characteristicUUIDString: String, with value: Data) {
        if self.value_mapping[characteristicUUIDString] != nil {
            let decodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristicUUIDString)
            
            if decodingType is UInt8{
                let data = value.uint8
                self.value_mapping.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is UInt16{
                let data = value.uint16
                self.value_mapping.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is Int32{
                let data = value.int32
                self.value_mapping.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
            else if decodingType is String.Encoding.RawValue{
                let data = String.init(data: value , encoding: String.Encoding.utf8) ?? "nil"
                self.value_mapping.updateValue(String(data), forKey: characteristicUUIDString)
                self.dashboardTableView.reloadData()
            }
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
    
    let keys = ["Battery Level", "Firmware Revision", "Potential", "Initial Delay", "Sample Period", "Sample Count", "Gain", "Electrode Mask"]

    var value_mapping: [String: String] = ["Battery Level": "xx",
                                           "Firmware Revision": "x.x.x",
                                           "Potential": "-1 to +1",
                                           "Initial Delay": "xxx",
                                           "Sample Period": "xxxx",
                                           "Sample Count": "xxx",
                                           "Gain": "xxxx",
                                           "Electrode Mask": "xxxx xxxx"
                                            ]
    var suffix_mapping: [String: String] = ["Battery Level": " %",
                                            "Firmware Revision": "",
                                            "Potential": " mV",
                                            "Initial Delay": " ms",
                                            "Sample Period": " ms",
                                            "Sample Count": "",
                                            "Gain": " x",
                                            "Electrode Mask": ""
                                             ]

    
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
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        print("ending row...", indexPath?.row as Any)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        print("Will begin editing row...", indexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editable_cell") as! DashboardEditableCell
        cell.key_label.text = keys[indexPath.row]
        cell.value_label.placeholder = value_mapping[keys[indexPath.row]]


        cell.value_label.delegate = self
        cell.suffix_label.text = suffix_mapping[keys[indexPath.row]]


        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == (keys.count - 1){
            cell.value_label.isUserInteractionEnabled = false
        }
        cell.selectionStyle = .none
        addDoneButtonOnKeyboard(txtNumber: cell.value_label, tag: indexPath.row)
        
        return cell
    }
    
    private func readCharacteristicValue(characteristicName: String){
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: characteristicName)!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
    }
    

    @objc func saveClicked(_ sender: Any){
        let button = sender as! UIBarButtonItem
        let name = keys[button.tag]
        let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: name)
        let indexPath = IndexPath(item: button.tag, section: 0)
        let cell = dashboardTableView.cellForRow(at: indexPath) as! DashboardEditableCell
        
        if encodingType is UInt8{
            let data = UInt8(cell.value_label.text!)!
            var d = Data(count: 1)
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else if encodingType is UInt16{
            let data = UInt16(cell.value_label.text!)!
            var d = Data(count: 2)
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else{
            let alert = UIAlertController(title: "Error!!", message: "Error Sending Data to Firmware", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)

        }
        self.view.endEditing(true)
    }
    
    @IBAction func startMeasurementClicked(_ sender: Any) {
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
//        d[0] = data
        d = withUnsafeBytes(of: data) { Data($0) }
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)        
    }
    
    @IBAction func disconnectClicked(_ sender: Any) {
        BluetoothInterface.instance.disconnect()
    }
}
