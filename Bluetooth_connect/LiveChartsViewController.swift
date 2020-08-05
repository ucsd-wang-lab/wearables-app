//
//  LiveChartViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 8/4/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts

class LiveChartsViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var chartsLabel: UILabel!
    
    
    var testConfig: TestConfig?
    var canUpdate: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lineChartView.delegate = self
        BluetoothInterface.instance.attachBLEValueRecordedObserver(id: id, observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = testConfig?.name
        detailLabel.text = "Repeat Number: \(currentLoopCount)\n Start Time: \(testConfig?.startTimeStamp[currentLoopCount] ?? "")s"
        
        if testConfig?.testMode == 0{
            chartsLabel.text = "Current (uA)"
        }
        else if testConfig?.testMode == 1{
            chartsLabel.text = "Potential (mV)"
        }
        customizeChart()
        canUpdate = true
    }
    
    func customizeChart(){
        lineChartView.data = nil
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry, label: nil)
        let color = UIColor.colorArray[0]
        line.colors = [color]
        line.circleColors = [color]
        line.circleHoleColor = color
        line.circleRadius = 1.0
        line.setDrawHighlightIndicators(true)
        line.highlightEnabled = true
        line.highlightLineWidth = 1.5
        line.highlightColor = line.color(atIndex: 0)
        
        // Use the following lines of code to enable background color
//        line.fill = Fill.fillWithColor(.orange)
//        line.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line)
        
        lineChartView.data = data
        lineChartView.data?.setDrawValues(false)
        
        lineChartView.noDataText = "Chart data needs to be provided"
        lineChartView.noDataTextColor = .orange
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.labelTextColor = .orange
        lineChartView.leftAxis.labelPosition = .insideChart
        lineChartView.rightAxis.enabled = false
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .orange
        
        lineChartView.legend.enabled = false
    }
    
    private func notifyLiveDataChange(value: Double, samplePeriod: Double){
        let numOfPoints = lineChartView.data?.dataSets[0].entryCount ?? 0
        let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: value / 1e6)
        lineChartView.data?.addEntry(newDataPoint, dataSetIndex: 0)
        lineChartView.notifyDataSetChanged()
    }
}

extension LiveChartsViewController: ChartViewDelegate, BLEValueRecordedObserver{
    var id: Int {
        45
    }
    
    func valueRecorded(with characteristicUUIDString: String, with value: Data?) {
        // incoming data....update chart
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            
            guard let samplePeriod = (testConfig?.testMode == 0) ? testConfig?.testSettings["Sample Period"]  : testConfig?.testSettings["Sample Period - Potentio"] else { return }
            
            let data = value!.int32
            detailLabel.text = "Repeat Number: \(currentLoopCount)\n Start Time: \(testConfig?.startTimeStamp[currentLoopCount] ?? "")s"
            
            if canUpdate == true{
                notifyLiveDataChange(value: Double(data), samplePeriod: Double(samplePeriod))
            }
        }
        else if characteristicUUIDString == "Queue Complete"{
            canUpdate = false
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        floatingLabel.isHidden = false
        floatingLabel.text = "(\(entry.x), \(entry.y))"
        floatingLabel.frame = CGRect(x: highlight.xPx, y: chartView.frame.minY - 5, width: 120, height: 15)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        floatingLabel.isHidden = true
//        detailLabel.text = "Select a trace for details"
    }
}
