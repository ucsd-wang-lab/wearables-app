//
//  TestConfigurationViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var testConfigTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var measurementTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var leadConfigSegmentedControl: UISegmentedControl!
    
    var valueTextField:[Int: UITextField] = [:]
    
    var unitsMapping: [Int: [String: String]] = [0: ["Potential": " mV"],
                                                 1: ["Initial Delay": " ms"],
                                                 2: ["Sample Period": " ms"],
                                                 3: ["Sample Count": ""],
                                                 4: ["Gain": " k\u{2126}"]
                                                ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to change view when keyboard appeards
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)

        nextButton.layer.cornerRadius = nextButton.layer.bounds.height / 3

        testConfigTableView.delegate = self
        testConfigTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tempTestConfig == nil{
//            tempTestConfig = TestConfig(name: nil, hour: 0, min: 0, sec: 0, testSettings: [:], measurementTypeIndex: measurementTypeSegmentedControl.selectedSegmentIndex, leadConfigIndex: leadConfigSegmentedControl.selectedSegmentIndex)
            tempTestConfig = TestConfig(name: nil, hour: 0, min: 0, sec: 0, milSec: 0, testSettings: [:], measurementTypeIndex: measurementTypeSegmentedControl.selectedSegmentIndex, leadConfigIndex: leadConfigSegmentedControl.selectedSegmentIndex)
        }
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
        self.view.frame.origin.y = -(self.view.frame.width * 0.48)
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
//        print("\n\nTextfield end editing....\(textField.text ?? "nil")\n\n")
        for key in valueTextField.keys{
            let tf = valueTextField[key]
            if textField == tf {
                let name = unitsMapping[key]![0].key
                let isValid = checkValidity(value: textField.text, characteristicName: name, textField: textField)
                if isValid{
                    tempTestConfig?.testSettings[name] = Int(textField.text!)
                    calculateDuration(characteristicName: name, value: textField.text!)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return unitsMapping.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1.0))
        view.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testConfigCell") as! TestConfigTableViewCell
        cell.keyLabel.text = "\(unitsMapping[indexPath.section]![0].key)"
        
        if let value = tempTestConfig?.testSettings[unitsMapping[indexPath.section]![0].key]{
            cell.valueLabel.text = String(value)
        }
        else{
            cell.valueLabel.text = "xxxx xxxx"
        }
        
        cell.valueLabel.delegate = self
        valueTextField[indexPath.section] = cell.valueLabel
        cell.unitsLabel.text = " \(unitsMapping[indexPath.section]![0].value)"
//        print("Section = \(indexPath.section)\t \(unitsMapping[indexPath.section]![0].key)")
        return cell
    }
    
    private func checkValidity(value: String?, characteristicName: String, textField: UITextField?) -> Bool {
        let minVal = CHARACTERISTIC_VALUE_MIN_VALUE[characteristicName]!
        let maxVal = CHARACTERISTIC_VALUE_MAX_VALUE[characteristicName]!
                        
        if let value = value{
            if value == ""{
                let message = "Value field cannot be empty"
                showErrorMessage(message: message, textField: textField)
                return false
            }
            else if Int(value) == nil{
                showErrorMessage(message: "Value Field Must be a number", textField: textField)
                return false
            }
            else{
                let val = Int(value) ?? nil
                if val! < minVal || val! > maxVal{
                    let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
                    showErrorMessage(message: message, textField: textField)
                    return false
                }
                return true
            }
        }
        else{
            let message = "Value Out of Range\nRange: " + String(minVal) + " to " + String(maxVal)
            showErrorMessage(message: message, textField: textField)
            return false
        }
    }
    
    private func calculateDuration(characteristicName: String, value: String){
        if let initialDelay = tempTestConfig?.testSettings["Initial Delay"]{
            tempTestConfig?.milSec += initialDelay
        }
        if let samplePeriod = tempTestConfig?.testSettings["Sample Period"], let sampleCount = tempTestConfig?.testSettings["Sample Count"]{
            let delay = samplePeriod * sampleCount
            tempTestConfig?.milSec += delay
        }
    }
    
    private func showErrorMessage(message: String, textField: UITextField?){
        let alert = UIAlertController(title: "Error!!", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true) {
            if let tf = textField{
                tf.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toTestName", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tempTestConfig?.measurementTypeIndex = measurementTypeSegmentedControl.selectedSegmentIndex
        tempTestConfig?.leadConfigIndex = leadConfigSegmentedControl.selectedSegmentIndex
    }

}
