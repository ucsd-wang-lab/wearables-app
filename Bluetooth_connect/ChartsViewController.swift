//
//  ChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/12/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {

    @IBOutlet weak var chartTitleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var dataSetSelectedIndex: Int?
    var chartsTitle:String?
    var testConfig: TestConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        detailLabel.text = "This is a text\nThis is another text!\nThis is another text!!"
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
        lineChartView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        chartTitleLabel.text = chartsTitle
//        print("TestConfig: \(testConfig)")
        
        navigationItem.title = testConfig?.name
        
        customizeChart()
        if chartTitleLabel.text == "Live View"{
            isLiveViewEnable = true
            canUpdateLiveGraph = true
            detailLabel.text = "Repeat Number: \(currentLoopCount)\n Start Time: 00:00:00s"
            let rightBarButtonItem = UIBarButtonItem(title: "Start/Stop", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = rightBarButtonItem
            generateLiveView()
        }
        else if chartTitleLabel.text == "Composite View"{
            detailLabel.text = "Select a trace for details"
            generateCompositeGraph()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chartsTitle = nil
        isLiveViewEnable = false
        canUpdateLiveGraph = false
        customizeChart()
        print("View Did Disappear....")
    }
    
    func customizeChart(){
        lineChartView.data = nil
        let lineChartEntry = [ChartDataEntry]()
        let line = LineChartDataSet(entries: lineChartEntry, label: nil)
        let color = UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1)
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
    
    private func generateCompositeGraph(){
        // Draw the Composite Graph
        if let test = testConfig{
//            for loopNumber in test.testData.keys.sorted(){
            for loopNumber in Array(test.testData.keys).sorted(){
                                
                // Populate the current plot
                guard let samplePeriod = test.testSettings["Sample Period"] else {
                    continue
                }
                
                for newValue in test.testData[loopNumber]!{
                    let numOfPoints = lineChartView.data?.dataSets[loopNumber - 1 ].entryCount ?? 0
                    let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                    lineChartView.data?.addEntry(newDataPoint, dataSetIndex: loopNumber - 1)
                }
                lineChartView.notifyDataSetChanged()

                
                // Add new plot
                let lineChartEntry = [ChartDataEntry]()
                let line = LineChartDataSet(entries: lineChartEntry, label: nil)

                let color = UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1)
                line.colors = [color]
                line.circleColors = [color]
                line.circleHoleColor = color
                line.circleRadius = 1.0
                line.setDrawHighlightIndicators(true)
                line.highlightEnabled = true
                line.highlightLineWidth = 1.5
                line.highlightColor = line.color(atIndex: 0)

                lineChartView.data?.dataSets.append(line)
            }
        }
    }
    
    private func generateLiveView(){
        if let test = testConfig{
            guard let samplePeriod = test.testSettings["Sample Period"] else {
                return
            }
            
            if let testData = test.testData[currentLoopCount]{
                for value in testData{
                    let numOfPoints = lineChartView.data?.dataSets[0].entryCount ?? 0
                    let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: value / 1e6)
                    lineChartView.data?.addEntry(newDataPoint, dataSetIndex: 0)
                }
                lineChartView.notifyDataSetChanged()
            }
        }
    }

    private func notifyLiveDataChange(value: Double, samplePeriod: Double){
        let numOfPoints = lineChartView.data?.dataSets[0].entryCount ?? 0
        let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: value / 1e6)
        lineChartView.data?.addEntry(newDataPoint, dataSetIndex: 0)
        lineChartView.notifyDataSetChanged()
    }
    
    private func resetGraphColor(){
        if let dataSets = lineChartView.data?.dataSets{
            for dataSet in dataSets{
                dataSet.setColor(UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1))
            }
        }
    }
}

extension ChartsViewController: BLEValueUpdateObserver, ChartViewDelegate{
    var id: Int {
        9
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
            if chartsTitle == "Live View"{
                if var test = configsList[queuePosition] as? TestConfig{
                    var existingData = test.testData[currentLoopCount] ?? [Double]()
                    existingData.append(Double(data))
                    test.testData.updateValue(existingData, forKey: currentLoopCount)
                    configsList[queuePosition] = test
                    
                    if canUpdateLiveGraph && test.name ==  navigationItem.title{
                        guard let samplePeriod = test.testSettings["Sample Period"] else{
                            return
                        }
                        notifyLiveDataChange(value: Double(data), samplePeriod: Double(samplePeriod))
                    }
                }
                
                
            }
        }
        else if characteristicUUIDString == "Queue Complete"{
            // move to next test in the queue
            print("\n\nQueue Complete....\(currentLoopCount)")
            if chartsTitle == "Live View"{
                canUpdateLiveGraph = false
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        resetGraphColor()
        lineChartView.data?.getDataSetByIndex(highlight.dataSetIndex)?.setColor(UIColor.black)
        dataSetSelectedIndex = highlight.dataSetIndex
        detailLabel.text = "Repeat Number: \(highlight.dataSetIndex + 1)\n Start Time: 00:00:00s\n End Time: 00:00:00s"
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        detailLabel.text = "Select a trace for details"
        resetGraphColor()
    }
}
