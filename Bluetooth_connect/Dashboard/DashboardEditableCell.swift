//
//  DashboardEditableCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DashboardEditableCell: UITableViewCell, UITableViewDelegate{
    
    @IBOutlet weak var key_label: UILabel!
    @IBOutlet weak var value_label: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        value_label.textColor = .lightGray
        
    }
}
