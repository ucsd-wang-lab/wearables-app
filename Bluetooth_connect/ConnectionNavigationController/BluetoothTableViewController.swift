//
//  BluetoothTableViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/15/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothTableViewController: UITableViewController {
        
    var bluetoothDeviceList: [String: CBPeripheral] = [:]

    override func viewDidLoad() {
        // viewDidLoad() only gets called once
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()       // Show no empty cell at the bottom
        self.clearsSelectionOnViewWillAppear = true
        self.refreshControl = UIRefreshControl()
        
        
        self.refreshControl?.addTarget(self, action: #selector(refreshBluetoothTableView), for: .valueChanged)
        
        let backBarButtton = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bluetoothDeviceList.removeAll()
        self.tableView.reloadData()
        
        BluetoothInterface.instance.autoConnect = false
        BluetoothInterface.instance.attachBLEStatusObserver(id: self.id, observer: self)
        BluetoothInterface.instance.attachBLEDiscoveredObserver(id: self.id, observer: self)
        BluetoothInterface.instance.initVar()
        BluetoothInterface.instance.startScan()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UIScreen.main.bounds.height * 0.065
        }
        return UIScreen.main.bounds.height * 0.08
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothDeviceList.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath)
            cell.backgroundColor = UIColor(red: 0xef/255, green: 0xef/255, blue: 0xf4/255, alpha: 1)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell", for: indexPath) as! BluetoothCell
        cell.deviceNameLabel.text = bluetoothDeviceList[indexPath.row - 1].key
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0{
            BluetoothInterface.instance.connect(peripheral: bluetoothDeviceList[indexPath.row - 1].value)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.bluetoothDeviceList.removeAll()
        BluetoothInterface.instance.detachBLEDiscoveredObserver(id: self.id)
        BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
        BluetoothInterface.instance.stopScan()
    }
    
    @objc func refreshBluetoothTableView(_ sender: Any){
        bluetoothDeviceList.removeAll()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        BluetoothInterface.instance.startScan()
    }
}

extension BluetoothTableViewController: BLEDiscoveredObserver, BLEStatusObserver{
    var id: Int {
        2
    }
    
    // This function is called when the phone connect to a peripheral
    func deviceConnected(with device: String) {
        BluetoothInterface.instance.autoConnect = true
        performSegue(withIdentifier: "toRenameController", sender: self)
    }
    
    // This function is called when a new peripheral is discovered
    func update<T>(with name: String, with device: T) {
        bluetoothDeviceList.updateValue(device as! CBPeripheral, forKey: name)
        self.tableView.reloadData()
    }
    
    // Checking to see if Bluetooth is enbaled or disabled
    func didBTEnable(with value: Bool) {
        if value == false{
            let alert = UIAlertController(title: "Error: Bluetooth Off!!", message: "Please turn on Bluetooth on phone!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
