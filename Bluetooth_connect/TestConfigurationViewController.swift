//
//  TestConfigurationViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var testConfigTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var measurementTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var leadConfigSegmentedControl: UISegmentedControl!
    
    var unitsMapping: [Int: [String: String]] = [0: ["Bias Potential": " mV"],
                                                 1: ["Initial Delay": " ms"],
                                                 2: ["Sample Period": " ms"],
                                                 3: ["Sample Count": ""],
                                                 4: ["Gain": " k\u{2126}"],
                                                 5: ["Electrode Mask": ""]
                                                ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = nextButton.layer.bounds.height / 3

        testConfigTableView.delegate = self
        testConfigTableView.dataSource = self
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
        cell.valueLabel.text = "xxxx xxxx"
        cell.unitsLabel.text = " \(unitsMapping[indexPath.section]![0].value)"
//        print("Section = \(indexPath.section)\t \(unitsMapping[indexPath.section]![0].key)")
        return cell
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toTestName", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TestNameConfigViewController
        destination.leadConfig = leadConfigSegmentedControl.selectedSegmentIndex
        destination.measurementType = measurementTypeSegmentedControl.selectedSegmentIndex
    }

}
