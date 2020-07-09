//
//  DelayViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/6/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DelayConfigurationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var delayNameTextfield: UITextField!
    @IBOutlet weak var addDelayButton: UIButton!
    @IBOutlet weak var delayPickerView: UIPickerView!
    @IBOutlet weak var nameQuestionLabel: UILabel!
    
    var delayName:String?
    var delayHour:Int?
    var delayMin:Int?
    var delaySec:Int?
    var isUpdate:Bool?
    var updateIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delayPickerView.delegate = self
        delayPickerView.dataSource = self
        
        delayNameTextfield.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: delayNameTextfield.frame.height - 1, width: self.view.frame.width * 0.9, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        delayNameTextfield.borderStyle = .none
        delayNameTextfield.layer.addSublayer(bottomLine)
        
        addDelayButton.layer.cornerRadius = addDelayButton.layer.bounds.height / 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let name = delayName{
            delayNameTextfield.text = name
        }
        
        if let hr = delayHour{
            delayPickerView.selectRow(hr, inComponent: 0, animated: true)
        }
        
        if let min = delayMin{
            delayPickerView.selectRow(min, inComponent: 1, animated: true)
        }
        
        if let sec = delaySec{
            delayPickerView.selectRow(sec, inComponent: 2, animated: true)
        }
        
        if let _ = isUpdate{
            addDelayButton.setTitle("Update", for: .normal)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
        self.view.endEditing(true)
    }
        
        // objective-c function for when keyboard appears
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -(self.view.frame.width * 0.22)
    }
    
    // objective-c function for when keyboard disappear
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    // when hitting enter on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return 24
        }
        else{
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return "\(row) hr"
        }
        else if component == 1{
            return "\(row) min"
        }
        else if component == 2{
            return "\(row) sec"
        }
        return nil
    }
    
    
    @IBAction func addDelayButtonClicked(_ sender: Any) {
        if let _ = isUpdate, let index = updateIndex{
            // do nothing....
            configsList[index].name = delayNameTextfield.text
            configsList[index].hour = delayPickerView.selectedRow(inComponent: 0)
            configsList[index].min = delayPickerView.selectedRow(inComponent: 1)
            configsList[index].sec = delayPickerView.selectedRow(inComponent: 2)
            self.navigationController?.popViewController(animated: true)
        }
        else{
            let delayConfig = DelayConfig(name: delayNameTextfield.text, hour: delayPickerView.selectedRow(inComponent: 0), min: delayPickerView.selectedRow(inComponent: 1), sec: delayPickerView.selectedRow(inComponent: 2))
            configsList.append(delayConfig)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}
