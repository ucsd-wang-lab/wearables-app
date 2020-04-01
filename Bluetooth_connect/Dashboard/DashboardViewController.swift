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
    let value = ["00", "0.1.4", "000", "0000", "00", "000", "0000 1111"]
    let suffix = ["%", "", "mV", "ms", "", "x", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to change view when keyboard appeards
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        
        deviceNameLabel.text = deviceName
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
        if indexPath.row == 2{
            return 80
        }
        else{
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected: ", indexPath.row)
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 || indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "read_only_cell") as! DashboardReadOnlyCell
            cell.key_label.text = keys[indexPath.row]
            cell.value_label.text = value[indexPath.row] + suffix[indexPath.row]
            cell.selectionStyle = .none
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "editable_cell") as! DashboardEditableCell
            cell.key_label.text = keys[indexPath.row]
            cell.value_label.text = value[indexPath.row] + suffix[indexPath.row]
            cell.value_label.delegate = self
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    @IBAction func startMeasurementClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Charts", bundle: nil)
        if #available(iOS 13.0, *) {
            let controller = storyboard.instantiateViewController(identifier: "charts_view") as! ChartsViewController
            controller.modalPresentationStyle = .fullScreen
            
            self.present(controller, animated: true) {
                // do nothing....
            }
            
        } else {
            // Fallback on earlier versions
        }
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
