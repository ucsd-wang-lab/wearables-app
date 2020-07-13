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
    @IBOutlet weak var we1Button: UIButton!
    @IBOutlet weak var we2Button: UIButton!
    @IBOutlet weak var we3Button: UIButton!
    @IBOutlet weak var ceButton: UIButton!
    @IBOutlet weak var reButton: UIButton!
    
    var isUpdate:Bool?
    var updateIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = nextButton.layer.bounds.height / 3
        we1Button.layer.cornerRadius = we1Button.layer.bounds.height / 2
        we2Button.layer.cornerRadius = we2Button.layer.bounds.height / 2
        we3Button.layer.cornerRadius = we3Button.layer.bounds.height / 2
        ceButton.layer.cornerRadius = ceButton.layer.bounds.height / 2
        reButton.layer.cornerRadius = reButton.layer.bounds.height / 2
        
        we1Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        we2Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        we3Button.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        ceButton.addTarget(self, action: #selector(leadSelectionButtonClicked(sender:)), for: .touchUpInside)
        
        let frame = leadSelectionSegmentedControl.frame
        leadSelectionSegmentedControl.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height + 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func leadSelectionButtonClicked(sender: UIButton){
        print("\nTag = \(sender.tag)")
        if sender.backgroundColor?.isEqual(UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)) ?? false{
            sender.backgroundColor = UIColor(red: 249/255, green: 211/255, blue: 122/255, alpha: 1)
        }
        else{
            sender.backgroundColor = UIColor(red: 253/255, green: 92/255, blue: 60/255, alpha: 1)
        }
        
        if let mask = tempTestConfig?.testSettings["Electrode Mask"]{
            let electrodeMask = mask | sender.tag
            tempTestConfig?.testSettings["Electrode Mask"] = electrodeMask
            print("New mask: \(electrodeMask)")
        }
        else{
            tempTestConfig?.testSettings["Electrode Mask"] = sender.tag
            print("New mask: \(tempTestConfig?.testSettings["Electrode Mask"] ?? 0)")
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toNameConfig", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TestNameConfigViewController
        controller.isUpdate = isUpdate
        controller.updateIndex = updateIndex
    }
}
