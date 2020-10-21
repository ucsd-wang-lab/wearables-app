//
//  TestConfigTableViewCell.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TestConfigTableViewCell: UITableViewCell {
    
    @IBOutlet weak var displayView: UIView!
    var keyLabel: UILabel!
    var valueLabel: UITextField!
    var unitsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        keyLabel = UILabel()
        valueLabel = UITextField()
        unitsLabel = UILabel()

        keyLabel.textColor = UIColor(red: 0x31/255, green: 0x30/255, blue: 0x30/255, alpha: 1)
        keyLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        
        valueLabel.textColor = UIColor(red: 0x31/255, green: 0x30/255, blue: 0x30/255, alpha: 1)
        valueLabel.font = UIFont(name: "Avenir-Regular", size: 16)
        valueLabel.textAlignment = .right
        valueLabel.keyboardType = .numbersAndPunctuation
        valueLabel.clearButtonMode = .whileEditing
        
        unitsLabel.textColor = UIColor(red: 0x31/255, green: 0x30/255, blue: 0x30/255, alpha: 1)
        unitsLabel.font = UIFont(name: "Avenir-Regular", size: 16)
        unitsLabel.textAlignment = .left
        unitsLabel.adjustsFontSizeToFitWidth = true
        
//        keyLabel.backgroundColor = .red
//        valueLabel.backgroundColor = .orange
//        unitsLabel.backgroundColor = .green
                
        let width = displayView.frame.width
        let height = displayView.frame.height
        
        let key_label_fram = CGRect(x: 0, y: 0, width: width * 0.5, height: height)
        keyLabel.frame = key_label_fram

        let value_label_frame = CGRect(x: keyLabel.frame.maxX, y: 0, width: width * 0.3, height: height)
        valueLabel.frame = value_label_frame
        valueLabel.returnKeyType = .next
        
        let suffix_label_frame = CGRect(x: valueLabel.frame.maxX, y: 0, width: width * 0.2, height: height)
        unitsLabel.frame = suffix_label_frame
        
        if self.traitCollection.userInterfaceStyle == .dark{
            keyLabel.textColor = .white
            valueLabel.textColor = .white
            unitsLabel.textColor = .white
        }
        else{
            keyLabel.textColor = .black
            valueLabel.textColor = .black
            unitsLabel.textColor = .black
        }
        
        displayView.addSubview(keyLabel)
        displayView.addSubview(valueLabel)
        displayView.addSubview(unitsLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
