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
    
    var hour:Int!
    var min:Int!
    var sec:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delayPickerView.delegate = self
        delayPickerView.dataSource = self
        
        delayNameTextfield.delegate = self
//        let nameTextFieldFrame = CGRect(x: delayNameTextfield.frame.minX, y: nameQuestionLabel.frame.maxY + 40, width: self.view.frame.width * 0.8, height: delayNameTextfield.frame.height)
//        delayNameTextfield.frame = nameTextFieldFrame
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: delayNameTextfield.frame.height - 1, width: self.view.frame.width * 0.9, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        delayNameTextfield.borderStyle = .none
        delayNameTextfield.layer.addSublayer(bottomLine)
        
        addDelayButton.layer.cornerRadius = addDelayButton.layer.bounds.height / 3
        
        hour = 0
        min = 0
        sec = 0
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            hour = row
        }
        else if component == 1{
            min = row
        }
        else if component == 2{
            sec = row
        }
    }
    
    @IBAction func addDelayButtonClicked(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
