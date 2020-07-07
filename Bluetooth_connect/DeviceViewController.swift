//
//  DelayViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/6/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var addDelayButton: UIButton!
    @IBOutlet weak var loopCountTextField: UITextField!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var listOfTestTableView: UITableView!
    
    var sensorName:String?
    var listOfHrDelay:[Int] = []
    var listOfMinDelay:[Int] = []
    var listofSecDelay:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loopCountTextField.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: loopCountTextField.frame.height - 1, width: loopCountTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        loopCountTextField.borderStyle = .none
        loopCountTextField.layer.addSublayer(bottomLine)

        addTestButton.layer.cornerRadius = addTestButton.layer.bounds.height / 3
        addDelayButton.layer.cornerRadius = addDelayButton.layer.bounds.height / 3
        
        listOfTestTableView.delegate = self
        listOfTestTableView.dataSource = self
        listOfTestTableView.dragDelegate = self
        
        for i in 1...10{
            listOfHrDelay.append(i)
            listOfMinDelay.append(i)
            listofSecDelay.append(i)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let name = sensorName{
            deviceNameLabel.text = name
        }
    }
       
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
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
        self.view.endEditing(true)
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listOfHrDelay.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.cellForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
            listOfHrDelay.remove(at: indexPath.section)
            listOfMinDelay.remove(at: indexPath.section)
            listofSecDelay.remove(at: indexPath.section)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testTableViewCell") as! TestTableViewCell
        cell.cellTitleLabel.text = "Delay \(indexPath.section + 1)"
        cell.runtimeLabel.text = "Run Time: " + "000:00:00"
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    @IBAction func addTestButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toTestConfiguration", sender: self)
    }
    
    @IBAction func addDelayButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toDelayConfiguration", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
