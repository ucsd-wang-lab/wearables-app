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
    
    var chartsTitle:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        detailLabel.text = "This is a text\nThis is another text!\nThis is another text!!"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chartTitleLabel.text = chartsTitle
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

extension ChartsViewController: BLEValueUpdateObserver{
    var id: Int {
        9
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        // do nothing....
    }
    
    
}
