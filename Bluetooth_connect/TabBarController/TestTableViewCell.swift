//
//  TestTableViewCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell, UITableViewDelegate {

    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellRuntime: UILabel!
    
    @IBOutlet weak var orangeView: UIView!
    @IBOutlet weak var fillerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fillerView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
