//
//  BluetoothViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/17/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Lottie

class BluetoothViewController: UIViewController {
    

    @IBOutlet weak var messageText: UILabel!
    
    var pulse1:PulseAnimation!
    var pulse2:PulseAnimation!
    private var isPulsing:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButtton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
        BluetoothInterface.instance.initVar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.messageText.text = "Click to find nearby devices"
        isPulsing = false
    }
    
    @IBAction func bluetoothButtonClicked(_ sender: UIButton) {
        if !isPulsing{
            isPulsing = !isPulsing
            pulse1 = PulseAnimation(numberOfPulse: Float.infinity, radius: 150, postion: sender.center)
            pulse1.animationDuration = 2
            pulse1.backgroundColor = UIColor(red: 0xfa/255, green: 0x78/255, blue: 0x5f/255, alpha: 1).cgColor
            self.view.layer.insertSublayer(pulse1, below: sender.layer)
            
            pulse2 = PulseAnimation(numberOfPulse: Float.infinity, radius: 100, postion: sender.center)
            pulse2.animationDuration = 2
            pulse2.backgroundColor = UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1).cgColor
            self.view.layer.insertSublayer(pulse2, below: sender.layer)
            
            self.messageText.text = "Searching for nearby devices"
            BluetoothInterface.instance.attachBLEStatusObserver(id: self.id, observer: self)
            BluetoothInterface.instance.attachBLEDiscoveredObserver(id: self.id, observer: self)
            BluetoothInterface.instance.startScan()
        }
        else{
            isPulsing = !isPulsing
            self.messageText.text = "Click to find nearby devices"
            pulse1.removeFromSuperlayer()
            pulse2.removeFromSuperlayer()
            pulse1 = nil
            pulse2 = nil
            BluetoothInterface.instance.stopScan()
        }
        
    }
}

extension BluetoothViewController: BLEDiscoveredObserver, BLEStatusObserver{
    var id: Int {
        1
    }
    
    func update<T>(with name: String, with device: T) {
        BluetoothInterface.instance.detachBLEStatusObserver(id: self.id)
        BluetoothInterface.instance.detachBLEDiscoveredObserver(id: self.id)
        BluetoothInterface.instance.stopScan()
        performSegue(withIdentifier: "toBLETableViewController", sender: self)
    }
    
    func didBTEnable(with value: Bool) {
        if value == false{
            let alert = UIAlertController(title: "Error: Bluetooth Off!!", message: "Please turn on Bluetooth on phone!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
        }
    }
    
}
