//
//  dashboardViewController.swift
//  Bluetooth_connect
//
//  Created by neel shah on 11/21/19.
//  Copyright © 2019 neel shah. All rights reserved.
//

import UIKit
//import Charts
class dashboardViewController: UIViewController {
    
//    @IBOutlet weak var lineview: LineChartView!
    
    @IBAction func devbutton(_ sender: Any) {
        let fileName = "Tasks.csv";
//        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Col1,Col2,Col3,Col4\n";
        let vc = ViewController()
//        let data_arr = vc.data_array
        print("Inside button")
//        for elem in data_arr{
//            print("Inside fo r")
//            let newline = "\(elem)"
//            csvText.append(newline)
//            }
        
        csvText.append("\(vc.data_array)");
        
        
        do {
            
//            try csvText.write(to: path?, atomically: true, encoding: NSUTF8StringEncoding)
            try csvText.write(to: path as! URL, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        
        
        

    }
    
    
    @IBAction func AddTest(_ sender: Any) {
    }
    @IBOutlet weak var BatteryLevel: UILabel!
    @IBAction func Glucose(_ sender: Any) {
    }
    @IBAction func SquareWave(_ sender: Any) {
    
    }
    @IBAction func electrode1(_ sender: Any) {
    }
    @IBAction func electrode4(_ sender: Any) {
    }
    @IBOutlet weak var DeviceName: UILabel!
    @IBAction func electrode3(_ sender: Any) {
    }
    @IBAction func electrode2(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = ViewController()
        DeviceName.text = vc.biosensorName;
        BatteryLevel.text = String(vc.BatteyLevel);
//        setChartValues()
    }
//    func setChartValues(_ count: Int = 20){
//        let values = (0..<count).map{(i) -> ChartDataEntry in
//            let val = Double(arc4random_uniform(UInt32(count))+1)
//            return ChartDataEntry(x:Double(i), y:val)
//        }
//        let set1 = LineChartDataSet(entries: values, label: "Neel test data")
//        let data = LineChartData(dataSet: set1)
//        
//        self.lineview.data = data
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
