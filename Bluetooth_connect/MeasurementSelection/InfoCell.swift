//
//  InfoCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/10/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell, UITableViewDelegate {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let width = contentView.frame.width
//        let height = contentView.frame.height
//
//        keyLabel.backgroundColor = .red
//        valueLabel.backgroundColor = .orange
//
//        let key_label_fram = CGRect(x: 0, y: 0, width: width * 0.7, height: height)
//        keyLabel.frame = key_label_fram
//
//        let value_label_frame = CGRect(x: keyLabel.frame.maxX, y: 0, width: width * 0.3, height: height)
//        valueLabel.frame = value_label_frame
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
