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

class ChartsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var graphView: LineChartView!
    
    var chartData = [Double]()
    let db = Firestore.firestore()
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeChart()
        
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
    
    func updatChart(value: Double){
        chartData.append(value)
        let newValue = ChartDataEntry(x: Double(chartData.count - 1), y: value)
        graphView.data?.addEntry(newValue, dataSetIndex: 0)
        graphView.notifyDataSetChanged()
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
        graphView.rightAxis.enabled = false
        graphView.xAxis.drawGridLinesEnabled = false
        graphView.xAxis.labelPosition = .bottom
        graphView.legend.enabled = false
//        graphView.data?.setDrawValues(false)
    }
    
    @IBAction func repeatButtonClicked(_ sender: Any) {
        print("Repeate Button clicked....")
        updatChart(value: Double(chartData.count * chartData.count))
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
        
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients(["rap004@ucsd.edu"])
//            mail.setMessageBody("<p> You're so aweson! </p>", isHTML: true)
//
//            self.present(mail, animated: true)
//        }
//        else{
//            print("Can't sent email.....")
//        }
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            // do nothing....
        }
    }

}
