//
//  ChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Charts
import MessageUI
import MobileCoreServices

class ChartsViewController: UIViewController {
    var id: Int = 3

    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var chartsTitle: UILabel!
    @IBOutlet weak var yAxisTitleLabel: UILabel!
    @IBOutlet weak var startStopLabel: UIButton!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var chartData = [Double]()
    var chartsColor = [UIColor]()
    var spinner: UIActivityIndicatorView!
    
    var deviceName: String?
    var chartTitle: String?
    var doQuit: Bool!
    var sampleCount = 0
    var currentTime: String!
    var samplePeriod: Double?
    var selectedIndex: Int = -1
    var numOfMeasurement = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let value = CHARACTERISTIC_VALUE["Sample Period"]!
//        samplePeriod = Double(value) ?? -1
        
        customizeChart()
        customizeLoadingIcon()
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: self.id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: self.id, observer: self)
        
        if let title = chartTitle{
            chartsTitle.text = title
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        currentTime = df.string(from: Date())
        
        yAxisTitleLabel.transform = CGAffineTransform(rotationAngle: 3 * CGFloat.pi / 2)
        
        graphView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if chartTitle == "Amperometry"{
            yAxisTitleLabel.text = "Current (uA)"
        }
        else if chartTitle == "Potentiometry"{
            yAxisTitleLabel.text = "Potential (mV)"
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
        numOfMeasurement += 1
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry, label: "Measurement \(numOfMeasurement)")
        let color = UIColor.colorArray[0]
        line.colors = [color]
        line.circleColors = [color]
        line.circleHoleColor = color
        line.circleRadius = 1.0
        line.setDrawHighlightIndicators(true)
        line.highlightEnabled = true
        line.highlightLineWidth = 1.5
        line.highlightColor = line.color(atIndex: 0)
        chartsColor.append(.orange)
        
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
        graphView.leftAxis.labelPosition = .insideChart
        graphView.rightAxis.enabled = false
        
        graphView.xAxis.drawGridLinesEnabled = false
        graphView.xAxis.labelPosition = .bottom
        graphView.xAxis.labelTextColor = .orange
        
        graphView.legend.enabled = true
        if traitCollection.userInterfaceStyle == .dark{
            graphView.legend.textColor = .white
        }
    }
    
    func updatChart(value: Double){
        doQuit = false
        let num_of_lines = graphView.data?.dataSetCount ?? 1
        chartData.append(value / 1e6)   // from for electronic is in pA, or divide by 1E6
        
        if samplePeriod != -1{
            let numOfPoints = graphView.data?.dataSets[num_of_lines - 1 ].entryCount ?? 0
            let newValue = ChartDataEntry(x: Double(numOfPoints) * samplePeriod! / 1000, y: value / 1e6)
            graphView.data?.addEntry(newValue, dataSetIndex: num_of_lines - 1)
            timeLabel.text = "Time (sec): \(Double(numOfPoints) * samplePeriod! / 1000)"
            yValueLabel.text = yAxisTitleLabel.text! + ":  \(String(value / 1e6).prefix(8))"
            graphView.notifyDataSetChanged()
        }
        else{
            let newValue = ChartDataEntry(x: Double(graphView.data?.dataSets[num_of_lines - 1 ].entryCount ?? 0), y: value / 1e6)
            graphView.data?.addEntry(newValue, dataSetIndex: num_of_lines - 1)
            timeLabel.text = "Time (sec): \(Double(graphView.data?.dataSets[num_of_lines - 1 ].entryCount ?? 0))"
            yValueLabel.text = yAxisTitleLabel.text! + ": \(String(value / 1e6).prefix(8))"
            graphView.notifyDataSetChanged()
        }
    }
    
    // This function creates a new line to be added to the line chart data
    func updateChart(){
        numOfMeasurement += 1
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry, label: "Measurement \(numOfMeasurement)")
        var color = UIColor.random
        
        if let num_of_lines = graphView.data?.dataSetCount {
            if num_of_lines < UIColor.colorArray.count{
                color = UIColor.colorArray[num_of_lines]
            }
        }
        print("Measurement: \(numOfMeasurement)\tColor: \(color)")
       
        line.colors = [color]
        line.circleColors = [color]
        line.circleHoleColor = color
        line.circleRadius = 1.0
        line.setDrawHighlightIndicators(true)
        line.highlightEnabled = true
        line.highlightLineWidth = 1.5
        line.highlightColor = line.color(atIndex: 0)
        chartsColor.append(color)
       
        graphView.data?.dataSets.append(line)
        graphView.data?.setDrawValues(false)
    }
    
    @IBAction func repeatButtonClicked(_ sender: Any) {
        startStopLabel.setTitle("Stop", for: .normal)
        let data: UInt8 = 1
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        updateChart()
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print("Save Button clicked....")
        spinner.startAnimating()
        
        self.spinner.stopAnimating()
        self.chartData.removeAll()
        let csvStrings = self.createCSV(currentTime: currentTime)
//        self.customizeChart()
        
        var count = 1
        for csvString in csvStrings{
            let fileName = "\(self.chartsTitle.text!)_data_mesaurement\(count)_\(currentTime ?? "Couldn't get current time")"
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("csv")
            
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .ascii)
                print("File saved: \(fileURL.absoluteURL)")
            } catch  {
                let alert = UIAlertController(title: "Error!!", message: "Cannot save File! \(error.localizedDescription))", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            count += 1
        }
        
        guard MFMailComposeViewController.canSendMail() else{
            let alert = UIAlertController(title: "Error!!", message: "Cannot sent email! Ensure the Mail app is functioning properly!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
//        composer.setToRecipients(["rap004@ucsd.edu"])
        composer.setSubject("Data Collected: \(currentTime ?? "Couldn't get current time")")
        composer.setMessageBody("Attached is the \(self.chartsTitle.text!) data collected on: \(currentTime ?? "Couldn't get current time")", isHTML: true)
        count = 1
        for csvString in csvStrings{
            composer.addAttachmentData(csvString.data(using: .ascii)!, mimeType: "text/csv", fileName: "\(self.chartsTitle.text!)_data_mesaurement\(count)_\(currentTime ?? "Couldn't get current time").csv")
        }
        self.present(composer, animated: true)
        
    }
    
    private func createCSV(currentTime: String) -> [String]{
        let num_of_lines = graphView.data?.dataSetCount ?? 0
        var csvStrings:[String] = []
        for i in 0..<num_of_lines{
            var csvString = "\("Timestamp"),\(currentTime)\n\n"
            
            if chartTitle == "Potentiometry" {
                csvString.append("Initial Delay,\(CHARACTERISTIC_VALUE["Initial Delay - Potentio"]!),ms\n")
                csvString.append("Sample Period,\(CHARACTERISTIC_VALUE["Sample Period - Potentio"]!),ms\n")
                csvString.append("Sample Count,\(CHARACTERISTIC_VALUE["Sample Count - Potentio"]!)\n")
                csvString.append("Electrode Mask,\(CHARACTERISTIC_VALUE["Electrode Mask - Potentio"]!)\n\n")
            }
            else{
                csvString.append("Potential,\(CHARACTERISTIC_VALUE["Potential"]!),mV\n")
                csvString.append("Initial Delay,\(CHARACTERISTIC_VALUE["Initial Delay"]!),ms\n")
                csvString.append("Sample Period,\(CHARACTERISTIC_VALUE["Sample Period"]!),ms\n")
                csvString.append("Sample Count,\(CHARACTERISTIC_VALUE["Sample Count"]!)\n")
                csvString.append("Gain,\(CHARACTERISTIC_VALUE["Gain"]!),x\n")
                csvString.append("Electrode Mask,\(CHARACTERISTIC_VALUE["Electrode Mask"]!)\n\n")
            }
            
            csvString.append("Measurement,\(i + 1)\n")
            csvString.append("Time (sec),Current (uA)\n")
            
            let data = graphView.data?.dataSets[i]
            let num_of_points = data?.entryCount ?? 0
            for j in 0..<num_of_points{
                let x = data?.entryForIndex(j)!.x
                let y = data?.entryForIndex(j)!.y
                csvString.append("\(String(describing: x!)),\(String(describing: y!))\n")
            }
            csvStrings.append(csvString)
        }
        
        print("csvString = \n\(csvStrings)")
        return csvStrings
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        doQuit = true
        let data: UInt8 = 0
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        if deleteButton.titleLabel?.text == "Delete All"{
            customizeChart()
        }
        else if deleteButton.titleLabel?.text == "Delete Selected" && selectedIndex != -1{
            graphView.data?.dataSets.remove(at: selectedIndex)
            chartsColor.remove(at: selectedIndex)
            let numOfDataset = graphView.data?.dataSets.count ?? 0
            for i in 0..<numOfDataset{
                graphView.data?.dataSets[i].setColor(chartsColor[i])
            }
            graphView.notifyDataSetChanged()
        }
    }
    

    @IBAction func startStopClicked(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            sender.setTitle("Start", for: .normal)
            let data: UInt8 = 0
            var d: Data = Data(count: 1)
            d = withUnsafeBytes(of: data) { Data($0) }
            let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
            BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
        }
        else {
            sender.tag = 0
            sender.setTitle("Stop", for: .normal)
            let data: UInt8 = 1
            var d: Data = Data(count: 1)
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

extension ChartsViewController: BLEStatusObserver, BLEValueUpdateObserver, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate, ChartViewDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // do nothing.....
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
    
    func deviceDisconnected(with device: String) {
        if device == self.deviceName{
            BluetoothInterface.instance.disconnect()
            BluetoothInterface.instance.autoConnect = true
            BluetoothInterface.instance.startScan()
            
//            let storyboard = UIStoryboard(name: "BTSelectionScreen", bundle: nil)
//            let controller = storyboard.instantiateInitialViewController() as! BTSelectionScreen
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true) {
//                // do nothing....
//                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
//            }
        }
    }
    
    // For when current data is recorded
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
            print("data = ", data)
            updatChart(value: Double(data))
        }
        else if characteristicUUIDString == "Queue Complete"{
            // do nothing.....
            print("Queue Complete....")
            self.startStopLabel.setTitle("Start", for: .normal)
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
        else{
            print("Write response received: \(name ?? "nil")")
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        timeLabel.text = "Time (sec): \(entry.x)"
        yValueLabel.text = yAxisTitleLabel.text! + ": " + String(entry.y)
        
        floatingLabel.isHidden = false
        floatingLabel.text = "(\(entry.x), \(entry.y))"
        floatingLabel.frame = CGRect(x: highlight.xPx, y: chartView.frame.minY, width: 120, height: 15)
        
        if floatingLabel.frame.maxX >= self.view.frame.maxX{
            let difference = floatingLabel.frame.maxX - self.view.frame.maxX
            floatingLabel.frame.origin.x -= difference
        }
        
        print("DatasetIndex: \(highlight.dataSetIndex)")
        let numOfDataset = graphView.data?.dataSets.count ?? 0
        for i in 0..<numOfDataset{
            if i != highlight.dataSetIndex{
                graphView.data?.dataSets[i].setColor(UIColor.clear)
            }
            else{
                graphView.data?.dataSets[i].setColor(chartsColor[i])
                selectedIndex = highlight.dataSetIndex
            }
        }
        deleteButton.setTitle("Delete Selected", for: .normal)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Nothing selected.....")
        floatingLabel.isHidden = true
        let numOfDataset = graphView.data?.dataSets.count ?? 0
        for i in 0..<numOfDataset{
            graphView.data?.dataSets[i].setColor(chartsColor[i])
        }
        deleteButton.setTitle("Delete All", for: .normal)
        selectedIndex = -1
    }
}
