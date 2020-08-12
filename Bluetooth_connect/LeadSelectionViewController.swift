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
    
    var isUpdate:Bool?
    var updateIndex:Int?
    var maskString: String!
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
        if tempTestConfig?.testMode == 1{
            leadSelectionSegmentedControl.isHidden = true
        }
        
        if tempTestConfig?.testMode == 0{
            maskString = "Electrode Mask"
        }
        else{
            maskString = "Electrode Mask - Potentio"
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
        print("\nTag = \(sender.tag)")
        if sender.backgroundColor?.isEqual(UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)) ?? false{
            // Button selected
            sender.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
            if let mask = tempTestConfig?.testSettings[maskString]{
                let electrodeMask = mask | sender.tag
                tempTestConfig?.testSettings[maskString] = electrodeMask
                print("New mask: \(String(electrodeMask, radix: 2))")
            }
            else{
                tempTestConfig?.testSettings[maskString] = sender.tag
                print("New mask: \(String(tempTestConfig?.testSettings[maskString] ?? 0, radix: 2))")
            }
        }
        else{
            // Button unselected
            sender.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
            if let mask = tempTestConfig?.testSettings[maskString]{
                let electrodeMask = mask - sender.tag
                tempTestConfig?.testSettings[maskString] = electrodeMask
                print("New mask: \(String(electrodeMask, radix: 2))")
            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toNameConfig", sender: self)
    }
    
    private func resetButtonColor(){
        if let electrodeMask = tempTestConfig?.testSettings["Electrode Mask"]{
            if electrodeMask & E1Button.tag != 0{
                E1Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
            }
            else{
                E1Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
            }
            
            if electrodeMask & E4Button.tag != 0{
                E4Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
            }
            else{
                E4Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
            }
            
            if electrodeMask & E3Button.tag != 0{
                E3Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
            }
            else{
                E3Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
            }
            
            if electrodeMask & E2Button.tag != 0{
                E2Button.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
            }
            else{
                E2Button.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TestNameConfigViewController
        controller.isUpdate = isUpdate
        controller.updateIndex = updateIndex
        
        if tempTestConfig?.testSettings[maskString] == nil{
            tempTestConfig?.testSettings[maskString] = 0
        }
    }
}
