//
//  LeadSelectionViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/12/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class LeadSelectionViewController: UIViewController {

    @IBOutlet weak var leadSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var E1Button: UIButton!
    @IBOutlet weak var E4Button: UIButton!
    @IBOutlet weak var E3Button: UIButton!
    @IBOutlet weak var E2Button: UIButton!
    @IBOutlet weak var reButton: UIButton!
    
    let notSelectedAlpha:CGFloat = 0.7
    let selectedAlpha:CGFloat = 1
    var isUpdate:Bool?
    var updateIndex:Int?
    var maskString: String!
    var testConfig: TestConfig?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = nextButton.layer.bounds.height / 3
        E1Button.layer.cornerRadius = E1Button.layer.bounds.height / 2
        E4Button.layer.cornerRadius = E4Button.layer.bounds.height / 2
        E3Button.layer.cornerRadius = E3Button.layer.bounds.height / 2
        E2Button.layer.cornerRadius = E2Button.layer.bounds.height / 2
        reButton.layer.cornerRadius = reButton.layer.bounds.height / 2
        
        E1Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        E4Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        E3Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        E2Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        E1Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
        E4Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
        E3Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
        E2Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
        
        let frame = leadSelectionSegmentedControl.frame
        leadSelectionSegmentedControl.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height + 50)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if testConfig?.testMode == 1{
            leadSelectionSegmentedControl.isHidden = true
        }
        
        if testConfig?.testMode == 0{
            maskString = "Electrode Mask"
        }
        else if testConfig?.testMode == 1{
            maskString = "Electrode Mask - Potentio"
        }
        else{
            maskString = "Electrode Mask - SW"
        }
        
        E1Button.tag = 1
        E2Button.tag = 2
        E3Button.tag = 4
        E4Button.tag = 8
        resetButtonColor()

        leadSelectionSegmentedControl.selectedSegmentIndex = 0
    }
    
    @IBAction func segmentedControlIndexChanged(_ sender: Any) {
        switch leadSelectionSegmentedControl.selectedSegmentIndex
        {
        case 0:
            E1Button.tag = 1
            E2Button.tag = 2
            E3Button.tag = 4
            E4Button.tag = 8
            resetButtonColor()
            
        case 1:
            E1Button.tag = 16
            E2Button.tag = 32
            E3Button.tag = 64
            E4Button.tag = 128
            resetButtonColor()
            
        default:
            break
        }
    }
    
    @objc func leadSelectionButtonClicked(sender: UIButton){
        let index = Int(testConfig!.testMode)
        if sender.backgroundColor?.isEqual(UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)) ?? false{
            // Button selected
            sender.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
//        if sender.alpha == notSelectedAlpha{
//            sender.alpha = selectedAlpha
            if let mask = testConfig?.testSettings2[index]?[maskString]{
                let electrodeMask = mask | sender.tag
                testConfig?.testSettings2[index]?[maskString] = electrodeMask

            }
            else{
                testConfig?.testSettings2[index]?[maskString] = sender.tag

            }
        }
        else{
            // Button unselected
            sender.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
//            sender.alpha = notSelectedAlpha
            if let mask = testConfig?.testSettings2[index]?[maskString]{

                let electrodeMask = mask - sender.tag
                testConfig?.testSettings2[index]?[maskString] = electrodeMask

            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toNameConfig", sender: self)
    }
    
    private func resetButtonColor(){
        if let electrodeMask = testConfig?.testSettings2[Int(testConfig!.testMode)]?[maskString]{
            if electrodeMask & E1Button.tag != 0{
                // Selected
                E1Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)   // Yellow
//                E1Button.alpha = selectedAlpha
            }
            else{
                // Not Selected
                E1Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)     // Orange
//                E1Button.alpha = notSelectedAlpha
            }
            
            if electrodeMask & E4Button.tag != 0{
                E4Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
//                E4Button.alpha = selectedAlpha
            }
            else{
                E4Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
//                E4Button.alpha = notSelectedAlpha
            }
            
            if electrodeMask & E3Button.tag != 0{
                E3Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
//                E3Button.alpha = selectedAlpha
            }
            else{
                E3Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
//                E3Button.alpha = notSelectedAlpha
            }
            
            if electrodeMask & E2Button.tag != 0{
                E2Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
//                E2Button.alpha = selectedAlpha
            }
            else{
                E2Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
//                E2Button.alpha = notSelectedAlpha
            }
        }
//        else{
//            E1Button.alpha = notSelectedAlpha
//            E2Button.alpha = notSelectedAlpha
//            E3Button.alpha = notSelectedAlpha
//            E4Button.alpha = notSelectedAlpha
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TestNameConfigViewController
        controller.isUpdate = isUpdate
        controller.updateIndex = updateIndex
        
        if testConfig?.testSettings2[Int(testConfig!.testMode)]?[maskString] == nil{
            let index = Int(testConfig!.testMode)
            testConfig?.testSettings2[index]?[maskString] = 0
        }
        controller.testConfig = testConfig
    }
}
