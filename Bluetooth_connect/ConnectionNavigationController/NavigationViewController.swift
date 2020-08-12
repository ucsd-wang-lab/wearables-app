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
            print("data = \(data)")
            
            if var test = configsList[queuePosition] as? TestConfig{
                var existingData = test.testData[currentLoopCount] ?? [Double]()
                if existingData.count == 0{
                    test.startTimeStamp.updateValue(updateTimeElapsedLabel(timeInMS: testTimeElapsed), forKey: currentLoopCount)
                }
                existingData.append(Double(data))
                test.testData.updateValue(existingData, forKey: currentLoopCount)
                configsList[queuePosition] = test
            }
            BluetoothInterface.instance.notifyBLEValueRecordedObserver(with: characteristicUUIDString, with: value)
        }
        else if characteristicUUIDString == "Queue Complete"{
            // move to next test in the queue
            print("\n\nQueue Complete....\(currentLoopCount)")
            if var test = configsList[queuePosition] as? TestConfig{
                test.endTimeStamp.updateValue(updateTimeElapsedLabel(timeInMS: testTimeElapsed), forKey: currentLoopCount)
            }
            BluetoothInterface.instance.notifyBLEValueRecordedObserver(with: characteristicUUIDString, with: nil)
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
            testTimeElapsed = scaledTotalRunTime
            BluetoothInterface.instance.notifyQueueComplete()
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
        
        BluetoothInterface.instance.notifyDelayUpdate(by: 50)
        
        print("Queue Position: \(queuePosition)")
        if timeElapsed >= (configsList[queuePosition] as! DelayConfig).totalDuration{
            timer.invalidate()
            sendNextTest()
        }
    }
}
