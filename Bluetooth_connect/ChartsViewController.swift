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
        print("TestConfig: \(testConfig)")
        
        customizeChart()
        if chartTitleLabel.text == "Live View"{
            detailLabel.text = "Repeat Numder: \(currentLoopCount)\n Start Time: 00:00:00s"
        }
        else if chartTitleLabel.text == "Composite View"{
            detailLabel.text = "Select a trace for details"
            generateCompositeGrap()
        }
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
    
    private func generateCompositeGrap(){
        // Draw the Composite Graph
        if let test = testConfig{
//            for loopNumber in test.testData.keys.sorted(){
            for loopNumber in Array(test.testData.keys).sorted(){
                                
                // Populate the current plot
                guard let samplePeriod = test.testSettings["Sample Period"]else {
                    continue
                }
                print("Sample Period: \(samplePeriod)")
                for newValue in test.testData[loopNumber]!{
                    print("loop: \(loopNumber)\t value: \(newValue)")
                    let numOfPoints = lineChartView.data?.dataSets[loopNumber - 1 ].entryCount ?? 0
                    let newDataPoint = ChartDataEntry(x: Double(numOfPoints) * Double(samplePeriod) / 1000, y: newValue / 1e6)
                    lineChartView.data?.addEntry(newDataPoint, dataSetIndex: loopNumber - 1)
                    lineChartView.notifyDataSetChanged()
                }
                
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChartsViewController: BLEValueUpdateObserver, ChartViewDelegate{
    var id: Int {
        9
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
            print("data from chartsView = \(data)")
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        lineChartView.data?.getDataSetByIndex(highlight.dataSetIndex)?.setColor(UIColor.black)
        dataSetSelectedIndex = highlight.dataSetIndex
        detailLabel.text = "Repeat Numder: \(highlight.dataSetIndex)\n Start Time: 00:00:00s\n End Time: 00:00:00s"
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        detailLabel.text = "Select a trace for details"
        if let selectedIndex = dataSetSelectedIndex{
            lineChartView.data?.getDataSetByIndex(selectedIndex)?.setColor(UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1))
        }
    }
}
