//
//  NavigationViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/15/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    var timer:Timer!
    var timeElapsed: UInt64!
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let textAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 20), NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
    }
    
    public func attachDelayObserver(){
        print("Delay observer attached.....")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NavigationViewController: BLEStatusObserver, BLEValueUpdateObserver{
    var id: Int {
        20
    }
    
    func deviceDisconnected(with device: String) {
        if BluetoothInterface.instance.autoConnect{
            BluetoothInterface.instance.startScan()
        }
        
    }
    
    func deviceConnected(with device: String) {
        BluetoothInterface.instance.autoConnect = true
    }
    
    func update(with characteristicUUIDString: String, with value: Data) {
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential"{
            let data = value.int32
//            print("data = \(data)")
            
            if isLiveViewEnable == false{
                if var test = configsList[queuePosition] as? TestConfig{
                    var existingData = test.testData[currentLoopCount] ?? [Double]()
                    existingData.append(Double(data))
                    test.testData.updateValue(existingData, forKey: currentLoopCount)
                    configsList[queuePosition] = test
                }
            }
        }
        else if characteristicUUIDString == "Queue Complete"{
            // move to next test in the queue
            print("\n\nQueue Complete....\(currentLoopCount)")
            sendNextTest()
        }
        else{
            print("\n\nUpdate Received: \(characteristicUUIDString)\n\n")
        }
    }
    
    private func sendNextTest(){
        queuePosition += 1
        if queuePosition == configsList.count{
            currentLoopCount += 1
            queuePosition = 0
            
            for i in 0..<configsList.count{
                configsList[i].numSettingSend = 0
            }
        }
        if currentLoopCount <= loopCount!{
            let test = configsList[queuePosition]
            if test is TestConfig{
                sendTestConfiguration(testCofig: test as! TestConfig, viewController: self)
            }
            else if test is DelayConfig{
                startTime = DispatchTime.now()
                timeElapsed = 0
                timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerFired(sender:)), userInfo: nil, repeats: true)
                timeElapsed = 0
                timer.fire()
            }
        }
        else{
            queuePosition = 0
            currentLoopCount = -1
            isTestRunning = false
            startStopQueueButton?.layer.backgroundColor = UIColor(red: 0xfd/255, green: 0x5c/255, blue: 0x3c/255, alpha: 1).cgColor
            startStopQueueButton?.setTitle("Start Queue", for: .normal)
            startStopQueueButton?.tag = 0
            print("Finished Testing!!!")
            let alert = UIAlertController(title: "Done!", message: "Finished Testing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @objc func timerFired(sender: Timer){
        endTime = DispatchTime.now()
        timeElapsed += (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / UInt64(1e6)
        startTime = endTime
        
        print("Delay: \(timeElapsed)")
        testTimeElapsed += (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / UInt64(1e6)
        globalTimeElapsedLabel?.text = updateTimeElapsedLabel() + " of " + constructDelayString(hour: totalHr, min: totalMin, sec: totalSec, milSec: totalMilSec)
        globalProgressView?.progress = Float(testTimeElapsed) / Float(totalRunTime)
        
//        print("Delay: \(timeElapsed)\t updatedLabel: \(updateTimeElapsedLabel())")
        if timeElapsed >= (configsList[queuePosition] as! DelayConfig).totalDuration{
            timer.invalidate()
            sendNextTest()
        }
    }
}
