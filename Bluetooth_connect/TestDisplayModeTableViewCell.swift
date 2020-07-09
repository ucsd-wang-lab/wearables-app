//
//  TestDisplayModeTableViewCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestDisplayModeTableViewCell: UITableViewCell, UITableViewDelegate {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var arrow_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let width = contentView.frame.width
//        let height = contentView.frame.height
//        
//        let deviceNameLabelRect = CGRect(x: deviceNameLabel.frame.minX, y: deviceNameLabel.frame.minY,
//                                         width: width * 0.75, height: height)
//        deviceNameLabel.frame = deviceNameLabelRect
//
//
//        let arrow_label_rect = CGRect(x: deviceNameLabel.frame.maxX, y: deviceNameLabel.frame.minY,
//                                      width: width * 0.2, height: height)
//        arrow_label.frame = arrow_label_rect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
