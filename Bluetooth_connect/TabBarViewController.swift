//
//  TabBarViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/8/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let newBackButton = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }

    @objc func backButtonPressed(sender: UIBarButtonItem){
        if let bluetoothTableViewController = self.navigationController?.viewControllers[1]{
            self.navigationController?.popToViewController(bluetoothTableViewController, animated: true)
        }
    }
}
