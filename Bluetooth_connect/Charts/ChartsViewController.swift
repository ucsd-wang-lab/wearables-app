//
//  ChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Charts
import MessageUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChartsViewController: UIViewController {
    var id: Int = 3

    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var stopStartButton: UIButton!
    @IBOutlet weak var chartsTitle: UILabel!
    
    var chartData = [Double]()
    let db = Firestore.firestore()
    var spinner: UIActivityIndicatorView!
    
    var deviceName: String?
    var chartTitle: String?
    var doQuit: Bool!
    var sampleCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeChart()
        customizeLoadingIcon()
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: self.id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: self.id, observer: self)
        
        if let title = chartTitle{
            chartsTitle.text = title
        }
    }
    
    func customizeLoadingIcon(){
        if traitCollection.userInterfaceStyle == .dark{
            spinner = UIActivityIndicatorView(style: .white)
        }
        else{
            spinner = UIActivityIndicatorView(style: .gray)
        }
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func customizeChart(){
        graphView.data = nil
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry)
        line.colors = [.orange]
        line.circleColors = [.orange]
        line.circleHoleColor = .orange
        line.circleRadius = 2.5
        
        // User the following lines of code to enable background color
//        line.fill = Fill.fillWithColor(.orange)
//        line.drawFilledEnabled = true
        
       
        let data = LineChartData()
        data.addDataSet(line)
       
        graphView.data = data
        graphView.data?.setDrawValues(false)
        
        graphView.noDataText = "Chart data needs to be provided"
        graphView.noDataTextColor = .orange
        graphView.leftAxis.drawGridLinesEnabled = false
        graphView.leftAxis.labelTextColor = .orange
        graphView.rightAxis.enabled = false
        graphView.xAxis.drawGridLinesEnabled = false
        graphView.xAxis.labelPosition = .bottom
        graphView.xAxis.labelTextColor = .orange
        graphView.legend.enabled = false
//        graphView.data?.setDrawValues(false)
    }
    
    func updatChart(value: Double){
        doQuit = false
        chartData.append(value)
        let newValue = ChartDataEntry(x: Double(chartData.count - 1), y: value)
        graphView.data?.addEntry(newValue, dataSetIndex: 0)
        graphView.notifyDataSetChanged()
    }
    
    @IBAction func repeatButtonClicked(_ sender: Any) {
        stopStartButton.tag = 0
        stopStartButton.setTitle("Stop", for: .normal)

        let data: UInt8 = 1
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print("Save Button clicked....")
        spinner.startAnimating()

        // Preparing for storage
        var data:[String:Any] = [:]
        var int_data:[Int: Any] = [:]
        let timestamp = get_current_time()
        data.updateValue(timestamp, forKey: "Timestamp")
        for i in 0..<chartData.count{
            print("data: ", i, "\t", chartData[i])
            data.updateValue(chartData[i], forKey: String(i))
            int_data.updateValue(chartData[i], forKey: i)
        }
        
        // Updating the database
        var ref: DocumentReference? = nil
        ref = db.collection("Data").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
                self.spinner.stopAnimating()
                let alert = UIAlertController(title: "Error!!", message: "Error Saving Data! Ensure internet is accessible.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("Document added with ID: \(ref!.documentID)")

                self.spinner.stopAnimating()
                self.customizeChart()
                self.chartData.removeAll()
                data["Timestamp"] = nil
                let csvString = self.createCSV(from: int_data, currentTime: timestamp)
                
                guard MFMailComposeViewController.canSendMail() else{
                    let alert = UIAlertController(title: "Error!!", message: "Cannot sent email! Ensure the Mail app is functioning properly!", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }

                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
//                composer.setToRecipients(["rap004@ucsd.edu"])
                composer.setSubject("Data Collected: \(timestamp)")
                composer.setMessageBody("Attached is the \(self.chartsTitle.text!) data collected on: \(timestamp)", isHTML: true)
                composer.addAttachmentData(csvString.data(using: .ascii)!, mimeType: "text/csv", fileName: "\(self.chartsTitle.text!)_data_\(timestamp).csv")

                self.present(composer, animated: true)
            }
        }
        
    }
    
    private func createCSV(from dataArray:[Int: Any], currentTime: String) -> String{
        var csvString = "\("Timestamp"),\(currentTime)\n\n"
        csvString.append("Potential,\(CHARACTERISTIC_VALUE["Potential"]!),mV\n")
        csvString.append("Initial Delay,\(CHARACTERISTIC_VALUE["Initial Delay"]!),ms\n")
        csvString.append("Sample Period,\(CHARACTERISTIC_VALUE["Sample Period"]!),ms\n")
        csvString.append("Sample Count,\(CHARACTERISTIC_VALUE["Sample Count"]!)\n")
        csvString.append("Gain,\(CHARACTERISTIC_VALUE["Gain"]!),x\n")
        csvString.append("Electrode Mask,\(CHARACTERISTIC_VALUE["Electrode Mask"]!)\n\n")
        csvString.append("x,y\n")
        
        let sortedKeys = Array(dataArray.keys).sorted(by: <)
                
        for key in sortedKeys {
            print("keys = ", key)
            csvString.append("\(key),\(String(describing: dataArray[key]!))\n")
            
        }
        print("csvString = \n\(csvString)")
        
        return csvString
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        doQuit = true
        let data: UInt8 = 0
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }

    @IBAction func startStopClicked(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            sender.setTitle("Start", for: .normal)
            let data: UInt8 = 0
            var d: Data = Data(count: 1)
    //        d[0] = data
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else {
            sender.tag = 0
            sender.setTitle("Stop", for: .normal)
            let data: UInt8 = 1
            var d: Data = Data(count: 1)
    //        d[0] = data
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
    }
    
    private func readCharacteristicValue(characteristicName: String){
           let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: characteristicName)!
           BluetoothInterface.instance.readData(characteristicUUIDString: charUUID)
       }
    
    func get_current_time() -> String {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        var current_hour = ""
        
        if hour < 10 {
            current_hour = String("0") + String(hour)
        }
        else if hour > 12 {
            current_hour = String(hour - 12)
        }
        else{
            current_hour = String(hour)
        }
        
        let current_minute = minutes < 10 ? String("0") + String(minutes) : String(minutes)
                    
        var current_time = ""
        current_time = String(month) + "/" + String(day) + "/" + String(year) + ": "
        current_time = current_time + String(current_hour) + ":" + String(current_minute)
        
        if hour >= 12 {
            current_time = current_time + " PM"
        }
        else{
            current_time = current_time + " AM"
        }
        
        return current_time
    }
}

extension ChartsViewController: BLEStatusObserver, BLEValueUpdateObserver, MFMailComposeViewControllerDelegate{
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
    
    func deviceDisconnected(with device: String) {
        if device == self.deviceName{
            let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
            }
        }
    }
    
    // For when current data is recorded
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
            print("data = ", data)
            updatChart(value: Double(data))
        }
        
        if CHARACTERISTIC_VALUE[characteristicUUIDString] != nil {
            print("Incoming data.....")
            let decodingType = CharacteristicsUUID.instance.getCharacteristicDataType(characteristicName: characteristicUUIDString)
            
            if decodingType is UInt8{
                let data = value.uint8
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
            }
            else if decodingType is UInt16{
                let data = value.uint16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
            }
            else if decodingType is Int16{
                let data = value.int16
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
            }
            else if decodingType is Int32{
                let data = value.int32
                CHARACTERISTIC_VALUE.updateValue(String(data), forKey: characteristicUUIDString)
            }
            else if decodingType is String.Encoding.RawValue{
                let data = String.init(data: value , encoding: String.Encoding.utf8) ?? "nil"
                CHARACTERISTIC_VALUE.updateValue(data, forKey: characteristicUUIDString)
            }
        }
    }
    
    // For sending the stop command when quit is pressed
    func writeResponseReceived(with characteristicUUIDString: String){
        let name = CharacteristicsUUID.instance.getCharacteristicName(characteristicUUID: characteristicUUIDString)
        if name == "Start/Stop Queue" && doQuit == true{
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! DashboardViewController
            controller.deviceName = deviceName
            controller.measurementType = chartTitle
            controller.modalPresentationStyle = .fullScreen
            controller.deviceName = self.deviceName
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
            }
        }
    }
}
