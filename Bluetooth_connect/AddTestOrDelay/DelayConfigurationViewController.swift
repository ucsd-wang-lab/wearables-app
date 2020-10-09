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
    var delayMS: Int?
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
        
        if let min = delayMin{
            delayPickerView.selectRow(min, inComponent: 0, animated: true)
        }
        
        if let sec = delaySec{
            delayPickerView.selectRow(sec, inComponent: 1, animated: true)
        }
        
        if let ms = delayMS{
            delayPickerView.selectRow(ms, inComponent: 2, animated: true)
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
        if component == 0 || component == 1{
            return 60
        }
        else if  component == 2{
            return 1000
        }
        else{
            return 1000
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return "\(row) min"
        }
        else if component == 1{
            return "\(row) sec"
        }
        else if component == 2{
            return "\(row) ms"
        }
        return nil
    }
    
    
    @IBAction func addDelayButtonClicked(_ sender: Any) {
        if let _ = isUpdate, let index = updateIndex{
            // do nothing....
            var delayConfig = testQueue[index] as? DelayConfig
            if delayConfig != nil{
                delayConfig!.name = delayNameTextfield.text
                delayConfig!.hour = 0
                delayConfig!.min = delayPickerView.selectedRow(inComponent: 0)
                delayConfig!.sec = delayPickerView.selectedRow(inComponent: 1)
                delayConfig!.milSec = delayPickerView.selectedRow(inComponent: 2)
                delayConfig!.testMode = 4
                delayConfig!.updateTotalDuration()
                testQueue[index] = delayConfig!
            }
        }
        else{
            var delayConfig = DelayConfig()
            delayConfig.name = delayNameTextfield.text
            delayConfig.hour = 0
            delayConfig.min = delayPickerView.selectedRow(inComponent: 0)
            delayConfig.sec = delayPickerView.selectedRow(inComponent: 1)
            delayConfig.milSec = delayPickerView.selectedRow(inComponent: 2)
            delayConfig.testMode = 4
            delayConfig.updateTotalDuration()
            testQueue.enqueue(newTest: delayConfig)
        }
        print("TestQueue after adding Delay = \(testQueue)")
        self.navigationController?.popViewController(animated: true)
    }

}
