//
//  BTSelectionScreen.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 3/24/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTSelectionScreen: UIViewController, UITableViewDataSource, UITableViewDelegate, BLEDiscoveredObserver, BLEStatusObserver{
    var id: Int = 0
        
    func update<T>(with name: String, with device: T){
        bleDeviceList.updateValue(device as! CBPeripheral, forKey: name)
        bluetoothTableView.reloadData()
    }
    
    func deviceConnected(with device: String) {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! DashboardViewController
        controller.modalPresentationStyle = .fullScreen
        controller.deviceName = (device as! String)
        self.present(controller, animated: true) {
            self.bleDeviceList.removeAll()
            BluetoothInterface.instance.detachBLEDiscoveredObserver(id: self.id)
            BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
            BluetoothInterface.instance.stopScan()
        }
    }
    
    func didBTEnable(with value: Bool) {
        if value == false{
            let alert = UIAlertController(title: "Error: Bluetooth Off!!", message: "Please turn on Bluetooth on phone!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }


    @IBOutlet weak var bluetoothTableView: UITableView!
    
    var bleDeviceList: [String: CBPeripheral] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bluetoothTableView.delegate = self
        bluetoothTableView.dataSource = self
        BluetoothInterface.instance.attachBLEDiscoveredObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLEStatusObserver(id: id, observer: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bleDeviceList.removeAll()
        bluetoothTableView.reloadData()
        BluetoothInterface.instance.initVar()
        BluetoothInterface.instance.startScan()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleDeviceList.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bluetooth_cell") as! BluetoothCell
        cell.deviceNameLabel.text = bleDeviceList[indexPath.row].key
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BluetoothInterface.instance.connect(peripheral: bleDeviceList[indexPath.row].value)
    }
    
}
