//
//  BTSelectionScreen.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class BTSelectionScreen: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var bluetoothTableView: UITableView!
    
    let deviceList = ["Device 0", "Device 1", "Device 2", "Device 3", "Device 4", "Device 5", "Device 6", "Device 7", "Device 8", "Device 9", "Device 10", "Device 11", "Device 12", "Device 13", "Device 14", "Device 15"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load....")

        bluetoothTableView.delegate = self
        bluetoothTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bluetooth_cell") as! BluetoothCell
        cell.deviceNameLabel.text = deviceList[indexPath.row]
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        if #available(iOS 13.0, *) {
            let controller = storyboard.instantiateViewController(identifier: "dashboard") as! DashboardViewController
            controller.modalPresentationStyle = .fullScreen
            controller.deviceName = deviceList[indexPath.row]
            
            self.present(controller, animated: true) {
                // do nothing....
            }
            
        } else {
            // Fallback on earlier versions
            
        }
        
    }
    
}
