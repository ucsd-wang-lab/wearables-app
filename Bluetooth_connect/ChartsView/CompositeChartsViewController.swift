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
    @IBOutlet weak var xAxisLabel: UILabel!
    
    var testConfig: TestConfig?
    var queueIndex: Int?
    var chartsColor = [UIColor]()
    var selectedGraph: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lineChartView.delegate = self
        BluetoothInterface.instance.attachBLEValueRecordedObserver(id: id, observer: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Selected", style: .plain, target: self, action: #selector(deleteButtonClicked))
        
        if self.traitCollection.userInterfaceStyle == .dark{
            floatingLabel.textColor = .white
            detailLabel.textColor = .white
            chartsLabel.textColor = .white
            xAxisLabel.textColor = .white
        }
        else{
            floatingLabel.textColor = .black
            detailLabel.textColor = .black
            chartsLabel.textColor = .black
            xAxisLabel.textColor = .black
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = testConfig?.name
        if testConfig?.testMode == 0 || testConfig?.testMode == 2{
            chartsLabel.text = "Current (uA)"
        }
        else if testConfig?.testMode == 1{
            chartsLabel.text = "Potential (mV)"
        }
        
        customizeChart()
        generateCompositeGraph()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touched on screent
        let touch = touches.first!
        let location = touch.location(in: self.view)
        if location.y < lineChartView.frame.minY{
            chartValueNothingSelected(lineChartView)
            lineChartView.highlightValue(nil)
        }
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
            for loopNumber in Array(test.testData.keys).sorted(){
                if test.testMode == 0 || test.testMode == 1{
                    // Ampero or Potentio Test
                    guard let samplePeriod = test.testSettings2[Int(test.testMode)]?["Sample Period"]  else { continue }
                    
                    if let numOfDataSet = lineChartView.data?.dataSets.count{
                        // Measurement Missing, fill with empty data to preserve measurement number on select
                        if numOfDataSet != loopNumber{
                            let difference = Swift.abs(loopNumber - numOfDataSet)
                            for _ in 0..<difference{
                                addNewEmptyPlot()
                            }
                            
                            for newValue in test.testData[loopNumber]!{
                                let numOfPoints = lineChartView.data?.dataSets[numOfDataSet + difference - 1].entryCount ?? 0
                                let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                                lineChartView.data?.addEntry(newDataPoint, dataSetIndex: numOfDataSet + difference - 1)
                            }
                        }
                        else{
                            for newValue in test.testData[loopNumber]!{
                                let numOfPoints = lineChartView.data?.dataSets[numOfDataSet - 1 ].entryCount ?? 0
                                let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                                lineChartView.data?.addEntry(newDataPoint, dataSetIndex: numOfDataSet - 1)
                            }
                        }
                    }
                }
                else if test.testMode == 2{
                    // Square Wave Test
                    guard let samplePeriod = test.testSettings2[Int(test.testMode)]?["Frequency"]  else { continue }
                                        
                    if let numOfDataSet = lineChartView.data?.dataSets.count{
                        if numOfDataSet != loopNumber{
                            let difference = Swift.abs(loopNumber - numOfDataSet)
                            for _ in 0..<difference{
                                addNewEmptyPlot()
                            }
                            
                            for newValue in test.testData[loopNumber]!{
                                let numOfPoints = lineChartView.data?.dataSets[numOfDataSet + difference - 1].entryCount ?? 0
                                let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                                lineChartView.data?.addEntry(newDataPoint, dataSetIndex: numOfDataSet + difference - 1)
                            }
                        }
                        else{
                            for newValue in test.testData[loopNumber]!{
                                let numOfPoints = lineChartView.data?.dataSets[numOfDataSet - 1 ].entryCount ?? 0
                                let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                                lineChartView.data?.addEntry(newDataPoint, dataSetIndex: numOfDataSet - 1)
                            }
                        }
                    }
                }
                
                lineChartView.notifyDataSetChanged()

                
                // Add new plot
                addNewEmptyPlot()
            }
        }
    }
    
    private func addNewEmptyPlot(){
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
    
    @objc func deleteButtonClicked(){
        if let index = selectedGraph{
//            lineChartView.data?.dataSets.remove(at: index)
            
            // Add new plot
            let lineChartEntry = [ChartDataEntry]()
            let line = LineChartDataSet(entries: lineChartEntry, label: nil)
            lineChartView.data?.dataSets[index] = line
            
            if let queueIndex = queueIndex{
                testQueue.deleteData(fromTestAtIndex: queueIndex, measurementNumber: index + 1)
            }
            lineChartView.notifyDataSetChanged()
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
        detailLabel.text = "Measurement: \(highlight.dataSetIndex + 1)\n Start Time: \(testConfig?.startTimeStamp[highlight.dataSetIndex + 1] ?? "")s\n End Time: \(testConfig?.endTimeStamp[highlight.dataSetIndex + 1] ?? "")s"
        
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
        selectedGraph = highlight.dataSetIndex
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        floatingLabel.isHidden = true
        
        // Reset graph color
        let numOfDataset = lineChartView.data?.dataSets.count ?? 0
        for i in 0..<numOfDataset{
            lineChartView.data?.dataSets[i].setColor(chartsColor[i])
        }
        
        detailLabel.text = "Select a trace for details"
        selectedGraph = nil
    }
}
