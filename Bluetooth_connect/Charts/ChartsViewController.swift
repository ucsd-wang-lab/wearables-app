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

class ChartsViewController: UIViewController, BLEStatusObserver, BLEValueUpdateObserver {
    var id: Int = 2
    
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
        if characteristicUUIDString == "Data Characteristic - current"{
            let data = value.int32
            print("data = ", data)
            updatChart(value: Double(data))
        }
        
        if CHARACTERISTIC_VALUE[characteristicUUIDString] != nil {
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
            controller.modalPresentationStyle = .fullScreen
            controller.deviceName = self.deviceName
            self.present(controller, animated: true) {
                // do nothing....
                BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
                BluetoothInterface.instance.detachBLEValueObserver(id: self.id)
            }
        }
    }

    @IBOutlet weak var graphView: LineChartView!
    
    var chartData = [Double]()
    let db = Firestore.firestore()
    var spinner: UIActivityIndicatorView!
    
    var deviceName: String?
    var doQuit: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeChart()
        customizeLoadingIcon()
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: self.id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: self.id, observer: self)
        
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
//        print("Repeate Button clicked....")
//        updatChart(value: Double(chartData.count * chartData.count))
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
        
        data.updateValue(FirebaseFirestore.Timestamp(), forKey: "Timestamp")
        for i in 0..<chartData.count{
            print("data: ", i, "\t", chartData[i])
            data.updateValue(chartData[i], forKey: String(i))
        }
        
        // Updating the database
        var ref: DocumentReference? = nil
        ref = db.collection("Data").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                self.spinner.stopAnimating()
                self.customizeChart()
                self.chartData.removeAll()
                let alert = UIAlertController(title: "Success!!", message: "Successfully saved data to database!", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                self.present(alert, animated: true)

            }
        }
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        doQuit = true
        let data: UInt8 = 0
        var d: Data = Data(count: 1)
        d[0] = data
        let charUUID = CharacteristicsUUID.instance.getCharacteristicUUID(characteristicName: "Start/Stop Queue")!
        BluetoothInterface.instance.writeData(data: d, characteristicUUIDString: charUUID)
    }

}
