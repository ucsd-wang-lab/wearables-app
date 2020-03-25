//
//  ChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {

    @IBOutlet weak var graphView: LineChartView!
    
    
    var chartData = [Double]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeChart()
    }

    
    func updatChart(value: Double){
        chartData.append(value)
        let newValue = ChartDataEntry(x: Double(chartData.count - 1), y: value)
        graphView.data?.addEntry(newValue, dataSetIndex: 0)
        graphView.notifyDataSetChanged()
    }
    
    func customizeChart(){
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry)
        line.colors = [.orange]
       
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
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            // do nothing....
        }
    }

}
