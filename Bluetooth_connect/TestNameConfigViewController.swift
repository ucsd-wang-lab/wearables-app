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
    
    var measurementType: Int?
    var leadConfig: Int?
    
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
    
    @IBAction func addTestButtonPressed(_ sender: Any) {
        if let viewController = self.navigationController?.viewControllers[3]{
            var testConfig = TestConfig(hour: 0, min: 0, sec: 0, measurementTypeIndex: measurementType ?? 0, leadConfigIndex: leadConfig ?? 0, biasPotential: 0, initialDelay: 0, samplePeriod: 0, sampleCount: 0, gain: 0, electrodeMast: 0)
            testConfig.name = testNameTextField.text
            configsList.append(testConfig)
            
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
}
