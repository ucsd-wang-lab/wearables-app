//
//  TestConfigurationViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var testConfigTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var measurementTypeSegmentedControl: UISegmentedControl!
    
    var valueTextField:[Int: UITextField] = [:]
    var valueTextFieldMapping:[String: UITextField] = [:]
    
    var unitsMapping: [Int: [String: String]] = [0: ["Potential": " mV"],
                                                 1: ["Initial Delay": " ms"],
                                                 2: ["Sample Period": " ms"],
                                                 3: ["Sample Count": ""],
                                                ]
    
    
    /*
    * 0: Ampero
    * 1: Potentio
    * 2: Square Wave
    */
    var tableMapping: [Int: [Int : [String: String]]] = [0: [0: ["Potential": " mV"],
                                                             1: ["Initial Delay": " ms"],
                                                             2: ["Sample Period": " ms"],
                                                             3: ["Sample Count": ""]
                                                            ],
                                                         1: [0: ["Initial Delay": " ms"],
                                                             1: ["Sample Period": " ms"],
                                                             2: ["Sample Count": ""],
                                                             3: ["Filter Level": ""]
                                                            ],
                                                         2: [0: ["Quiet Time": " ms"],
                                                             1: ["Num Steps": ""],
                                                             2: ["Frequency": " hz"],
                                                             3: ["Amplitude": " mV"],
                                                             4: ["Initial Potential": " mV"],
                                                             5: ["Final Potential": " mV"],
                                                             6: ["Gain Level": " \u{2126}"]
                                                            ]
                                                        ]
    var isUpdate:Bool?
    var updateIndex:Int?
    var testConfig:TestConfig?
    
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
        
        if testConfig == nil{
            testConfig = TestConfig()
        }
        else{
            measurementTypeSegmentedControl.selectedSegmentIndex = Int(testConfig!.testMode)
            measurementTypeChanged(measurementTypeSegmentedControl)
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
        for key in valueTextField.keys{
            let tf = valueTextField[key]
            if textField == tf {
                let nextKey = key + 1
                if let nextTF = valueTextField[nextKey]{
                    nextTF.becomeFirstResponder()
                }
                else{
                    textField.resignFirstResponder()
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for key in valueTextFieldMapping.keys{
            print("Keys = \(key)")
            let tf = valueTextFieldMapping[key]
            if textField == tf {
                print("TF with Key: \(key)")
//                let _key = tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]![key]![0].key
//                let _key = key
                let isValid = checkValidity(value: textField.text, characteristicName: key, textField: textField)
                if isValid{
                    var dict = testConfig?.testSettings2[measurementTypeSegmentedControl.selectedSegmentIndex]
                    if dict != nil{
                        dict!.updateValue(Int(textField.text!)!, forKey: key)
                    }
                    else{
                        dict = [key: Int(textField.text!)!]
                    }
                    print("Updating Dictionary: \(dict)")
                    testConfig?.testSettings2.updateValue(dict!, forKey: measurementTypeSegmentedControl.selectedSegmentIndex)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testConfigCell") as! TestConfigTableViewCell

        let _key = tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]![indexPath.section]![0].key
        let _units = tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]![indexPath.section]![0].value

        cell.keyLabel.text = _key

        if let value = testConfig?.testSettings2[measurementTypeSegmentedControl.selectedSegmentIndex]?[_key]{
            cell.valueLabel.text = "\(value)"
        }
        else{
            cell.valueLabel.text = "xxxx xxxx"
        }

        cell.valueLabel.delegate = self
        valueTextField[indexPath.section] = cell.valueLabel
//        valueTextFieldMapping[_key] = cell.valueLabel
        valueTextFieldMapping.updateValue(cell.valueLabel, forKey: _key)
        cell.unitsLabel.text = _units
        cell.selectionStyle = .none

        return cell
    }
    
    @IBAction func measurementTypeChanged(_ sender: UISegmentedControl) {
        valueTextFieldMapping.removeAll()
        testConfigTableView.reloadData()

//        if sender.selectedSegmentIndex == 0{
//            leadConfigSegmentedControl.selectedSegmentIndex = 1
//        }
//        else if sender.selectedSegmentIndex == 1{
//            leadConfigSegmentedControl.selectedSegmentIndex = 0
//        }
//        else if sender.selectedSegmentIndex == 2{
//            leadConfigSegmentedControl.selectedSegmentIndex = 1
//        }
    }
    
    
    private func checkValidity(value: String?, characteristicName: String, textField: UITextField?) -> Bool {
        let minVal = CHARACTERISTIC_VALUE_MIN_VALUE[measurementTypeSegmentedControl.selectedSegmentIndex]![characteristicName]!
        let maxVal = CHARACTERISTIC_VALUE_MAX_VALUE[measurementTypeSegmentedControl.selectedSegmentIndex]![characteristicName]!

        
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
        var canSegue = true
        
        if isUpdate == true {
            if testConfig?.testSettings2[measurementTypeSegmentedControl.selectedSegmentIndex]?.count != tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]!.count + 1{
                
                canSegue = false
            }
        }
        else if testConfig?.testSettings2[measurementTypeSegmentedControl.selectedSegmentIndex]?.count != tableMapping[measurementTypeSegmentedControl.selectedSegmentIndex]?.count{
            canSegue = false
        }
        
//        canSegue = true
        if canSegue{
            performSegue(withIdentifier: "toLeadConfig", sender: self)
        }
        else{
            showErrorMessage(message: "Must set all characteristics for the selected measurement type!", textField: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! LeadSelectionViewController
        controller.isUpdate = isUpdate
        controller.updateIndex = updateIndex
        
        testConfig?.testMode = Int8(measurementTypeSegmentedControl.selectedSegmentIndex)
        controller.testConfig = testConfig
    }

}
