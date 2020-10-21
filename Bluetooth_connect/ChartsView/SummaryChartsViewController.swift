//
//  SummaryChartsViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 8/21/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts

class SummaryChartsViewController: UIViewController {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var chartsLabel: UILabel!
    @IBOutlet weak var xAxisLabel: UILabel!
    
    var testConfig: TestConfig?
    override func viewDidLoad() {
        super.viewDidLoad()

        lineChartView.delegate = self
        
        if self.traitCollection.userInterfaceStyle == .dark{
            floatingLabel.textColor = .white
            chartsLabel.textColor = .white
            xAxisLabel.textColor = .white
        }
        else{
            floatingLabel.textColor = .black
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
        drawChart()
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
    
    private func drawChart(){
        if let testData = testConfig?.testData{
//            let newDataPoint = ChartDataEntry(x: 0, y: 0)
//            lineChartView.data?.addEntry(newDataPoint, dataSetIndex: 0)
            for loopNumber in Array(testData.keys).sorted(){
                if let lastElement = testData[loopNumber]?.last{
                    let numOfPoints = (lineChartView.data?.dataSets[0].entryCount ?? 0) + 1
                    let newDataPoint = ChartDataEntry(x: Double(numOfPoints), y: lastElement / 1e6)
                    lineChartView.data?.addEntry(newDataPoint, dataSetIndex: 0)
                }
            }
            lineChartView.notifyDataSetChanged()
            lineChartView.xAxis.setLabelCount(testData.keys.count + 1, force: true)
        }
    }
}

extension SummaryChartsViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        floatingLabel.isHidden = false
        floatingLabel.text = "(\(entry.x), \(entry.y))"
        floatingLabel.frame = CGRect(x: highlight.xPx, y: chartView.frame.minY - 5, width: 120, height: 15)
        
        if floatingLabel.frame.maxX >= self.view.frame.maxX{
            let difference = floatingLabel.frame.maxX - self.view.frame.maxX
            floatingLabel.frame.origin.x -= difference
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        floatingLabel.isHidden = true
    }
}
