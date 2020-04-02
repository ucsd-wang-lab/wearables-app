//
//  DashboardViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    
    var deviceName: String?
    
    let keys = ["Battery Level", "Firmware Version", "Start/Stop", "Sampling Time", "Sample Count", "Sensitivity", "Electrode Mask"]
    let value = ["xx", "x.x.x", "xxx", "xxxx", "xx", "xxx", "xxxx xxxx"]
    let suffix = [" %", "", " mV", " ms", "", " x", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to change view when keyboard appeards
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        
        deviceNameLabel.text = deviceName
        
        BluetoothInterface.instance.printServiceDictionary()
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
        
        if indexPath.row == 0 || indexPath.row == 1{
            cell.value_label.isUserInteractionEnabled = false
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    @IBAction func startMeasurementClicked(_ sender: Any) {
//        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Potential")!
//        BluetoothInterface.instance.writeData(data: "1".data(using: .utf8)!, characteristicUUIDString: charUUID, withReapose: true)
        
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Firmware Revision")!
        BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
        
        
        // TODO: Write '1' to 'Start/Stop Queue' Characteristics
//        let storyboard = UIStoryboard(name: "Charts", bundle: nil)
//        let controller = storyboard.instantiateInitialViewController() as! ChartsViewController
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true) {
//            // do nothing....
//        }
    }
    
    @IBAction func disconnectClicked(_ sender: Any) {
        BluetoothInterface.instance.disconnect()
        let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true) {
            // do nothing....
        }
        
    }
}
