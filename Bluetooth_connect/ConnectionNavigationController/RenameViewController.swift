//
//  RenameViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/16/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class RenameViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        
        let nameTextFieldFrame = CGRect(x: self.view.frame.width * 0.1, y: infoLabel.frame.maxY + 40, width: self.view.frame.width * 0.8, height: nameTextField.frame.height)
        nameTextField.frame = nameTextFieldFrame
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: nameTextField.frame.height - 1, width: nameTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        nameTextField.borderStyle = .none
        nameTextField.layer.addSublayer(bottomLine)
        
        nextButton.layer.cornerRadius = 10
        nextButton.alpha = 0.7
        
        let backBarButtton = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen begain
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
        if nameTextField.text != ""{
            nextButton.alpha = 1.0
       }
       else{
            nextButton.alpha = 0.7
       }
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
        if textField.text != ""{
            nextButton.alpha = 1.0
        }
        else{
            nextButton.alpha = 0.7
        }
        nextButtonClicked(textField)
        self.view.endEditing(true)
        return true
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toTesting", sender: self)
//        if self.nameTextField.text != ""{
//            let storyboard = UIStoryboard(name: "TestingNavigationController", bundle: nil)
//            let controller = storyboard.instantiateInitialViewController() as! TabBarViewController
//            connectedDeiviceName = self.nameTextField.text
//            self.navigationController?.pushViewController(controller, animated: true)
//        }        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        BluetoothInterface.instance.disconnect()
        BluetoothInterface.instance.stopScan()
    }

}
