//
//  TestNameConfigViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/9/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestNameConfigViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var testNameTextField: UITextField!
    @IBOutlet weak var addTestButton: UIButton!
    
    var isUpdate:Bool?
    var updateIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        testNameTextField.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: testNameTextField.frame.height - 1, width: testNameTextField.frame.width * 0.9, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        testNameTextField.borderStyle = .none
        testNameTextField.layer.addSublayer(bottomLine)
        
        addTestButton.layer.cornerRadius = addTestButton.layer.bounds.height / 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        testNameTextField.text = tempTestConfig?.name
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
        self.view.endEditing(true)
    }
        
    // when hitting enter on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("\n\nTextfield end editing....\(textField.text ?? "nil")\n\n")
        tempTestConfig?.name = textField.text
        
    }
    
    @IBAction func addTestButtonPressed(_ sender: Any) {
        if let viewController = self.navigationController?.viewControllers[3]{
            tempTestConfig?.name = testNameTextField.text
            if let _ = isUpdate, let index = updateIndex{
                configsList[index] = tempTestConfig!
            }
            else{
                configsList.append(tempTestConfig!)
                tempTestConfig = nil
            }
            
            
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
}
