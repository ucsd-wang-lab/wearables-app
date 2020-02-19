//
//  GraphViewController.swift
//  Bluetooth_connect
//
//  Created by neel shah on 2/16/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Charts
class GraphViewController: UIViewController {
    @IBOutlet weak var linechart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setChartValue(_ count: Int = 20){
        let values = (0..<count).map{ (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(count))+3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let set1 = LineChartDataSet(entries: values, label: "Neel Test Data")
        let data = LineChartData(dataSet: set1)
        
        self.linechart.data = data
        
        
    }
    

}
