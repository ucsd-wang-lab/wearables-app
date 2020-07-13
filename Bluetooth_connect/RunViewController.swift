//
//  RunViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class RunViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var loopCountTextField: UITextField!
    @IBOutlet weak var saveDataButton: UIButton!
    @IBOutlet weak var runControlButton: UIButton!
    @IBOutlet weak var listOfTestTableView: UITableView!
    
    var testOrderList: [TestConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        deviceNameLabel.text = connectedDeiviceName
        
        loopCountTextField.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: loopCountTextField.frame.height - 1, width: loopCountTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        loopCountTextField.borderStyle = .none
        loopCountTextField.layer.addSublayer(bottomLine)
        loopCountTextField.addDoneButton(onDone: (target: self, action: #selector(self.doneButtonPressed)))
        loopCountTextField.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
        let tabBarItem = UITabBarItem(title: "Run", image: UIImage(named: "2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "2sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
       self.tabBarItem = tabBarItem

       UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
       UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0x31/255, green: 0x30/255, blue: 0x30/255, alpha: 1)], for: .selected)
        
        saveDataButton.layer.cornerRadius = saveDataButton.layer.bounds.height / 3
        runControlButton.layer.cornerRadius = runControlButton.layer.bounds.height / 3
        
        listOfTestTableView.tableFooterView = UIView()  // Show no empty cell at the bottom
        listOfTestTableView.delegate = self
        listOfTestTableView.dataSource = self
        
        BluetoothInterface.instance.attachBLEValueObserver(id: self.id, observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let lCount = loopCount{
            loopCountTextField.text = String(lCount)
        }
        
        timeRemainingLabel.text = constructDelayString(hour: totalHr, min: totalMin, sec: totalSec)
        testOrderList = []
        constructTestOrder()
        listOfTestTableView.reloadData()
    }
    
    @objc func doneButtonPressed(){
        loopCount = Int(loopCountTextField.text ?? "0")
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return testOrderList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.backgroundColor = UIColor(red: 0xef/255, green: 0xef/255, blue: 0xf4/255, alpha: 1)
        
        let titleLabel = UILabel(frame: CGRect(x: deviceNameLabel.frame.minX, y: 0, width: self.view.frame.width, height: 40))
        titleLabel.text = "Test - " + (testOrderList[section].name ?? "")
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return testOrderList[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chartTitle = ""
        if indexPath.row == 0{
            chartTitle = "Live View"
        }
        else{
            chartTitle = "Composite View"
        }
        
        let storyboard = UIStoryboard(name: "TestingNavigationController", bundle: nil)
        if #available(iOS 13.0, *) {
            let controller = storyboard.instantiateViewController(identifier: "chartsView") as! ChartsViewController
            controller.chartsTitle = chartTitle
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            performSegue(withIdentifier: "toChartsView", sender: self)
        }
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testViewCell", for: indexPath) as! TestDisplayModeTableViewCell
        if indexPath.row == 0{
            cell.deviceNameLabel.text = "Live"
        }
        else{
            cell.deviceNameLabel.text = "Composite"
        }
        
        return cell
    }
    
    private func constructTestOrder(){
        for test in configsList{
            if test is TestConfig{
                testOrderList.append(test as! TestConfig)
            }
        }
    }
    @IBAction func startStopQueueButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 0{
            // Test is not running
            if listOfTestTableView.numberOfSections == 0{
                showErrorMessage(message: "There must be a test present to start queue!")
            }
            else if loopCount == nil{
                showErrorMessage(message: "Loop count must be provided!")
            }
            else if loopCount! < 0{
                showErrorMessage(message: "Loop count must be non-negative!")
            }
            else{
                if currentLoopCount == -1{
                    currentLoopCount = loopCount!
                }
                sendTestConfiguration(testCofig: testOrderList[0] )
                button.layer.backgroundColor = UIColor(red: 1, green: 0x3b/255, blue: 0x30/255, alpha: 1).cgColor
                button.setTitle("Stop Queue", for: .normal)
                button.tag = 1
            }
        }
        else{
            // Test is running
            button.layer.backgroundColor = UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1).cgColor
            button.setTitle("Start Queue", for: .normal)
            button.tag = 0
        }
    }
    
    @IBAction func saveDataButtonPressed(_ sender: Any) {
        
    }
    
    private func showErrorMessage(message: String){
        let alert = UIAlertController(title: "Error!!", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func sendTestConfiguration(testCofig: TestConfig){
        for characteristics in testCofig.testSettings.keys{
            let encodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristics)
            let value = testCofig.testSettings[characteristics]!
            updateValue(name: characteristics, encodingType: encodingType, value: String(value))
        }
        
        // Sending Start Signal
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
        d = withUnsafeBytes(of: data) { Data($0) }
        let measurementTypeIndex = testCofig.measurementTypeIndex

        if measurementTypeIndex == 0{
            // Ampero
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else if measurementTypeIndex == 1{
            // Potentio
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Potentiometry")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else{
            showErrorMessage(message: "Enable to start measurement\nContact Developer")
        }
    }
    
    private func updateValue(name: String, encodingType: Any?, value: String?){
        if let value = value{
            if value == ""{
                showErrorMessage(message: "Value Field Cannot be empty")
            }
            else if Int(value) == nil{
                showErrorMessage(message: "Value Field Must be a number")
            }
            else{
                if name == "Electrode Mask"{
                    let data = UInt8(value, radix: 2) ?? nil
                    if data == nil {
                        let message = "Value Field must be valid 8-bit binary input"
                        showErrorMessage(message: message)
                    }
                    else{
                        var d = Data(count: 1)
                        d = withUnsafeBytes(of: data!) { Data($0) }
                        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                        CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    }
                }
                else if encodingType is UInt8{
                    let data = UInt8(value) ?? nil
                    var d = Data(count: 1)
                    d = withUnsafeBytes(of: data!) { Data($0) }
                    let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                    CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                }
                else if encodingType is UInt16{
                    let data = UInt16(value) ?? nil
                    var d = Data(count: 2)
                    d = withUnsafeBytes(of: data!) { Data($0) }
                    let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                    CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    
                }
                else if encodingType is Int16{
                    let data = Int16(value) ?? nil
                    var d = Data(count: 2)
                    d = withUnsafeBytes(of: data!) { Data($0) }
                    let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: name)!
                    BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
                    CHARACTERISTIC_VALUE.updateValue(String(data!), forKey: name)
                    
                }
                else{
                    showErrorMessage(message: "Error Sending Data to Firmware\nInvalid Data Type")
                }
            }
            
        }
        else{
            showErrorMessage(message: "Error Sending Data to Firmware...Contact Developer")
        }
    }
}

extension RunViewController: BLEValueUpdateObserver{
    var id: Int {
        10
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
            print("data = ", data)
        }
    }
    
    
}
