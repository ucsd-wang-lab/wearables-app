//
//  BluetoothCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class BluetoothCell: UITableViewCell, UITableViewDelegate{
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var arrow_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = contentView.frame.width
        let height = contentView.frame.height
        
        let deviceNameLabelRect = CGRect(x: deviceNameLabel.frame.minX, y: deviceNameLabel.frame.minY,
                                         width: width * 0.75, height: height)
        deviceNameLabel.frame = deviceNameLabelRect
        
        let arrow_label_rect = CGRect(x: deviceNameLabel.frame.maxX, y: deviceNameLabel.frame.minY,
                                      width: width * 0.2, height: height)
        arrow_label.frame = arrow_label_rect
        
//        deviceNameLabel.backgroundColor = .red
//        arrow_label.backgroundColor = .orange
    }
}
