//
//  TestNameConfigViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/9/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestNameConfigViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var testNameTextField: UITextField!
    @IBOutlet weak var addTestButton: UIButton!
    
    var isUpdate:Bool?
    var updateIndex:Int?
    var testConfig:TestConfig?
    override func viewDidLoad() {
        super.viewDidLoad()

        testNameTextField.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: testNameTextField.frame.height - 1, width: testNameTextField.frame.width * 0.9, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        testNameTextField.borderStyle = .none
        testNameTextField.layer.addSublayer(bottomLine)
        testNameTextField.returnKeyType = .done
        
        addTestButton.layer.cornerRadius = addTestButton.layer.bounds.height / 3
        
        if self.traitCollection.userInterfaceStyle == .dark{
            testNameTextField.textColor = .white
            questionLabel.textColor = .white
        }
        else{
            testNameTextField.textColor = .black
            questionLabel.textColor = .black
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        testNameTextField.text = testConfig?.name
        if isUpdate == true{
            addTestButton.setTitle("Update Test", for: .normal)
        }
        calculateTestDuration()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
        self.view.endEditing(true)
    }
        
    // when hitting enter on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTestButtonPressed(textField)
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        testConfig?.name = textField.text

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
    
    private func calculateTestDuration(){
        if testConfig?.testMode == 0 || testConfig?.testMode == 1{
            // Amperometric and Potentiometric Test
            
            // Runtime of test in ms
            var testRunTime = (testConfig?.testSettings2[Int(testConfig!.testMode)]!["Initial Delay"]!)! +
                                ((testConfig?.testSettings2[Int(testConfig!.testMode)]!["Sample Period"]!)! * (testConfig?.testSettings2[Int(testConfig!.testMode)]!["Sample Count"]!)!)
            
            testConfig?.hour = testRunTime / 3600000
            testRunTime = testRunTime % 3600000
            
            testConfig?.min = testRunTime / 60000
            testRunTime = testRunTime % 60000
            
            testConfig?.sec = testRunTime / 1000
            testRunTime = testRunTime % 1000
            
            testConfig?.milSec = testRunTime
        }
        else if testConfig?.testMode == 2{
            // Square Wave Test
            let quietTime = (testConfig?.testSettings2[Int(testConfig!.testMode)]!["Quiet Time"]!)!
            let numSteps = (testConfig?.testSettings2[Int(testConfig!.testMode)]!["Num Steps"]!)!
            let frequency = (testConfig?.testSettings2[Int(testConfig!.testMode)]!["Frequency"]!)!
            
            // Runtime of test in ms
            var testRunTime = Int(CGFloat(quietTime) + (CGFloat(numSteps) * CGFloat((1000 / (CGFloat(frequency))))))
        
            
            testConfig?.hour = testRunTime / 3600000
            testRunTime = testRunTime % 3600000
            
            testConfig?.min = testRunTime / 60000
            testRunTime = testRunTime % 60000
            
            testConfig?.sec = testRunTime / 1000
            testRunTime = testRunTime % 1000
            
            testConfig?.milSec = testRunTime
        }
        
    }
    
    @IBAction func addTestButtonPressed(_ sender: Any) {
        if let viewController = self.navigationController?.viewControllers[3]{
            testConfig?.name = testNameTextField.text
            testConfig?.updateTotalDuration()
            if let _ = isUpdate, let index = updateIndex{
                testQueue[index] = testConfig!
            }
            else{
                testQueue.enqueue(newTest: testConfig!)
            }
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
}
