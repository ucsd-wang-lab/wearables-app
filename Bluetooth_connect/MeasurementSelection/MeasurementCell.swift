//
//  MeasurementCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/10/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class MeasurementCell: UITableViewCell {
    
    @IBOutlet weak var measurement: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
