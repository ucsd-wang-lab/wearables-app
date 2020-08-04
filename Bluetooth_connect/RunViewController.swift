//
//  RunViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import MessageUI
import MobileCoreServices

class RunViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var loopCountTextField: UITextField!
    @IBOutlet weak var saveDataButton: UIButton!
    @IBOutlet weak var runControlButton: UIButton!
    @IBOutlet weak var listOfTestTableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    
    var testOrderList: [TestConfig] = []
    var testIndexMapping: [Int: Int] = [:]     // Mapping from testOrderList --> configList
    var chartTitle: String?
    var selectdTest: TestConfig?
    
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
        
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        globalProgressView = progressView
        globalTimeElapsedLabel = timeElapsedLabel
        
        if let lCount = loopCount{
            loopCountTextField.text = String(lCount)
        }
        
        timeRemainingLabel.text = constructDelayString(hour: totalHr, min: totalMin, sec: totalSec, milSec: totalMilSec)
        testOrderList = []
        constructTestOrder()
        listOfTestTableView.reloadData()
        startStopQueueButton = runControlButton
        timeElapsedLabel.text = updateTimeElapsedLabel() + " of " + timeRemainingLabel.text!
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
        if indexPath.row == 0{
            chartTitle = "Live View"
        }
        else{
            chartTitle = "Composite View"
        }
        selectdTest = configsList[testIndexMapping[indexPath.section]!] as? TestConfig
        
        performSegue(withIdentifier: "toChartsView", sender: self)
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
        var count = 0
        for test in configsList{
            if test is TestConfig{
                testOrderList.append(test as! TestConfig)
                testIndexMapping.updateValue(count, forKey: testOrderList.count - 1)
            }
            count += 1
        }
    }
    @IBAction func startStopQueueButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 0{
            // Test is not running
            if listOfTestTableView.numberOfSections == 0{
                showErrorMessage(message: "There must be a test present to start queue!", viewController: self)
            }
            else if loopCount == nil{
                showErrorMessage(message: "Loop count must be provided!", viewController: self)
            }
            else if loopCount! < 0{
                showErrorMessage(message: "Loop count must be non-negative!", viewController: self)
            }
            else{
                if currentLoopCount == -1{
                    currentLoopCount = loopCount!
                    currentLoopCount = 1
                }
                let test = configsList[queuePosition]
                if test is TestConfig{
                    sendTestConfiguration(testCofig: test as! TestConfig, viewController: self)
                }
                else{
                    // perform delay
                }
                
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
            isTestRunning = false
            
            // Sending Stop Signal
            let data: UInt8 = 0
            var d: Data = Data(count: 1)
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
    }
    
    @IBAction func saveDataButtonPressed(_ sender: Any) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let currentTime = df.string(from: Date())
        print("currentTime: \(currentTime)")
        let csvStrings = generateCSVString()
        
        var index = 0
        for test in configsList{
            if test is TestConfig{
                let csvString = csvStrings[index]
                let fileName = "\(test.name ?? "NULL")"
                var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                directoryURL.appendPathComponent(currentTime, isDirectory: true)

                do{
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)

                } catch let error as NSError{
                    print("Unable to create directory \(error.debugDescription)")
                }


                let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("csv")

                do {
                    try csvString.write(to: fileURL, atomically: true, encoding: .ascii)
                    print("File saved: \(fileURL.absoluteURL)")
                } catch  {
                    let alert = UIAlertController(title: "Error!!", message: "Cannot save File! \(error.localizedDescription))", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                index += 1
            }
        }

        guard MFMailComposeViewController.canSendMail() else{
            let alert = UIAlertController(title: "Error!!", message: "Cannot sent email! Ensure the Mail app is functioning properly!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
            composer.setToRecipients(["rap004@ucsd.edu"])
        composer.setSubject("Data Collected on: \(currentTime)")
        composer.setMessageBody("Attached is the data collected on: \(currentTime)", isHTML: true)
        
        index = 0
        for test in configsList{
            if test is TestConfig{
                let csvString = csvStrings[index]
                let fileName = "\(test.name ?? "NULL")"
                composer.addAttachmentData(csvString.data(using: .ascii)!, mimeType: "text/csv", fileName: "\(fileName).csv")
                index += 1
            }
        }
        self.present(composer, animated: true)
    }
    
    private func generateCSVString() -> [String]{
        var csvStringArray: [String] = []
        for test in configsList{
            if test is TestConfig{
                let t = test as! TestConfig
                var csvString = ""
                if t.testMode == 0{
                    csvString.append("Amperometric Measurement\n\n")
                }
                else{
                    csvString.append("Potentiometric Measurement\n\n")
                }
                print("testData: \(t.testData)")
                for testSettingKey in Array(t.testSettings.keys).sorted(){
                    csvString.append("\(testSettingKey), \(t.testSettings[testSettingKey]!)\n")
                }
                csvString.append("\n\n")
                
                if t.testMode == 1{
                    csvString.append("\n")  // one extra space for potentiometric measurement
                }
                
                var maxCount = 0
                for testDataKey in Array(t.testData.keys).sorted(){
                    csvString.append("Loop \(testDataKey),")
                    if t.testData[testDataKey]!.count >= maxCount{
                        maxCount = t.testData[testDataKey]!.count
                    }
                }
                csvString.append("\n")
                
                for i in 0..<maxCount{
                    for testDataKey in Array(t.testData.keys).sorted(){
                        if let data = t.testData[testDataKey]![exist: i]{
                            csvString.append("\(data),")
                        }
                        else{
                            csvString.append(",")
                        }
                    }
                    csvString.append("\n")
                }
                
                csvStringArray.append(csvString)
            }
        }
        print("csvStringArray: \(csvStringArray)")
        return csvStringArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChartsViewController
        destination.chartsTitle = chartTitle
        destination.testConfig = selectdTest
    }
    
    private func updateProgressBar(){
        progressView.progress = Float(testTimeElapsed) / Float(totalRunTime)
        timeElapsedLabel.text = updateTimeElapsedLabel() + " of " + timeRemainingLabel.text!
        print("Percentage Finished: \(Float(testTimeElapsed) / Float(totalRunTime))")
    }
}

extension RunViewController: BLEValueUpdateObserver, MFMailComposeViewControllerDelegate{
    var id: Int {
        15
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let err = error{
            print("Error: ", err)
            let alert = UIAlertController(title: "Error!!", message: "Cannot sent email: \(err)", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            controller.dismiss(animated: true, completion: nil)
        }
        
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            print("Cancelled!")
        case .failed:
            print("Failed!")
            let alert = UIAlertController(title: "Error!!", message: "Failed to sent email!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .saved:
            print("Email Saved!")
            let alert = UIAlertController(title: "Success!!", message: "Email saved to Drafts!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .sent:
            print("Email Sent!")
            let alert = UIAlertController(title: "Success!!", message: "Email Sent! It may take a few minutes to arrive.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        @unknown default:
            print("Unknown Default!")
        }
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            if let test = configsList[queuePosition] as? TestConfig{
                if let mode = test.testSettings["Mode Select"]{
                    if mode == 0{
                        if let samplePeriod = test.testSettings["Sample Period"]{
                            testTimeElapsed += UInt64(samplePeriod)
                        }
                    }
                    else if mode == 1{
                        if let samplePeriod = test.testSettings["Sample Period - Potentio"]{
                            testTimeElapsed += UInt64(samplePeriod)
                        }
                    }
                    updateProgressBar()
                }
            }
        }
    }
}
