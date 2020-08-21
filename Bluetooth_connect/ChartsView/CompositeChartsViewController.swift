//
//  CompositeChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 8/4/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts

class CompositeChartsViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var chartsLabel: UILabel!
    
    var testConfig: TestConfig?
    var chartsColor = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lineChartView.delegate = self
        BluetoothInterface.instance.attachBLEValueRecordedObserver(id: id, observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = testConfig?.name
        if testConfig?.testMode == 0{
            chartsLabel.text = "Current (uA)"
        }
        else if testConfig?.testMode == 1{
            chartsLabel.text = "Potential (mV)"
        }
        
        customizeChart()
        generateCompositeGraph()
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
        chartsColor.append(color)
        
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
                guard let samplePeriod = (test.testMode == 0) ? test.testSettings["Sample Period"]  : test.testSettings["Sample Period - Potentio"] else { continue }
                
                for newValue in test.testData[loopNumber]!{
                    let numOfPoints = lineChartView.data?.dataSets[loopNumber - 1 ].entryCount ?? 0
                    let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                    lineChartView.data?.addEntry(newDataPoint, dataSetIndex: loopNumber - 1)
                }
                lineChartView.notifyDataSetChanged()

                
                // Add new plot
                let lineChartEntry = [ChartDataEntry]()
                let line = LineChartDataSet(entries: lineChartEntry, label: nil)

                var color = UIColor.random
                if let num_of_lines = lineChartView.data?.dataSetCount {
                    if num_of_lines < UIColor.colorArray.count{
                        color = UIColor.colorArray[num_of_lines]
                    }
                }
                
                line.colors = [color]
                line.circleColors = [color]
                line.circleHoleColor = color
                line.circleRadius = 1.0
                line.setDrawHighlightIndicators(true)
                line.highlightEnabled = true
                line.highlightLineWidth = 1.5
                line.highlightColor = line.color(atIndex: 0)
                chartsColor.append(color)

                lineChartView.data?.dataSets.append(line)
                lineChartView.data?.setDrawValues(false)
            }
        }
    }
}

extension CompositeChartsViewController: ChartViewDelegate, BLEValueRecordedObserver{
    var id: Int {
        35
    }
    
    func valueRecorded(with characteristicUUIDString: String, with value: Data?) {
        // incoming data....update chart
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        lineChartView.data?.getDataSetByIndex(highlight.dataSetIndex)?.setColor(UIColor.black)
        detailLabel.text = "Repeat Number: \(highlight.dataSetIndex + 1)\n Start Time: \(testConfig?.startTimeStamp[highlight.dataSetIndex + 1] ?? "")s\n End Time: \(testConfig?.endTimeStamp[highlight.dataSetIndex + 1] ?? "")s"
        
        floatingLabel.isHidden = false
        floatingLabel.text = "(\(entry.x), \(entry.y))"
        floatingLabel.frame = CGRect(x: highlight.xPx, y: chartView.frame.minY - 5, width: 120, height: 15)
        
        if floatingLabel.frame.maxX >= self.view.frame.maxX{
            let difference = floatingLabel.frame.maxX - self.view.frame.maxX
            floatingLabel.frame.origin.x -= difference
        }
        
        let numOfDataset = lineChartView.data?.dataSets.count ?? 0
        for i in 0..<numOfDataset{
            if i != highlight.dataSetIndex{
                lineChartView.data?.dataSets[i].setColor(UIColor.clear)
            }
            else{
                lineChartView.data?.dataSets[i].setColor(chartsColor[i])
            }
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        floatingLabel.isHidden = true
        
        // Reset graph color
        let numOfDataset = lineChartView.data?.dataSets.count ?? 0
        for i in 0..<numOfDataset{
            lineChartView.data?.dataSets[i].setColor(chartsColor[i])
        }
        
        detailLabel.text = "Select a trace for details"
    }
}
