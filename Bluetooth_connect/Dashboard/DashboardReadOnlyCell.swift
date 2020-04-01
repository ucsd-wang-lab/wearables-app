//
//  DashboardReadOnlyCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardReadOnlyCell: UITableViewCell, UITableViewDelegate{
    
    @IBOutlet weak var key_label: UILabel!
    @IBOutlet weak var value_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let key_label_fram = CGRect(x: 0, y: 0, width: 0, height: 0)
        key_label.frame = key_label_fram
        
        let value_label_frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        value_label.frame = value_label_frame
    }
}
