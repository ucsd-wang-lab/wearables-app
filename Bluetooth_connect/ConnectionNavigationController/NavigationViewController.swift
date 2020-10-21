//
//  NavigationViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/15/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    public static var instance: NavigationViewController = NavigationViewController()
    
    var timer:Timer!
    var timeElapsed: UInt64!
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let textAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 20), NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        
        NavigationViewController.instance = self
        
        BluetoothInterface.instance.attachBLEStatusObserver(id: id, observer: self)
        BluetoothInterface.instance.attachBLEValueObserver(id: id, observer: self)
        
//        testQueue.enqueue(newTest: TestConfig(name: "Test 3"))
//        testQueue.enqueue(newTest: DelayConfig(name: "Delay 1"))
//        testQueue.enqueue(newTest: TestConfig(name: "Test 1"))
//        testQueue.enqueue(newTest: DelayConfig(name: "Delay 1"))
//        testQueue.enqueue(newTest: TestConfig(name: "Test 2"))
//        testQueue.enqueue(newTest: DelayConfig(name: "Delay 2"))
//        testQueue.enqueue(newTest: TestConfig(name: "Test 3"))
//        testQueue.enqueue(newTest: DelayConfig(name: "Delay 3"))
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
        if characteristicUUIDString == "Data Characteristic - current" || characteristicUUIDString == "Data Characteristic - Potential" ||
            characteristicUUIDString == "Data Characteristic - SW Current"{
            let data = value.int32
            print("data = \(data)")
            
            if var test = testQueue.peek() as? TestConfig{
                var existingData = test.testData[testQueue.getQueuetIterationCounter()] ?? [Double]()
                if existingData.count == 0{
                    testQueue.updateStartTime(value: updateTimeElapsedLabel(timeInMS: testTimeElapsed), loopCount: testQueue.getQueuetIterationCounter())
                }
                
                existingData.append(Double(data))
                test.testData.updateValue(existingData, forKey: testQueue.getQueuetIterationCounter())
                
                testQueue.updateData(newData: test.testData)
            }
            BluetoothInterface.instance.notifyBLEValueRecordedObserver(with: characteristicUUIDString, with: value)
        }
        else if characteristicUUIDString == "Queue Complete"{
            // move to next test in the queue
            print("\n\nQueue Complete....\(testQueue.queueIterator)")
            if (testQueue.peek() as? TestConfig) != nil{
                testQueue.updateEndTime(value: updateTimeElapsedLabel(timeInMS: testTimeElapsed), loopCount: testQueue.getQueuetIterationCounter())

            }
            BluetoothInterface.instance.notifyBLEValueRecordedObserver(with: characteristicUUIDString, with: nil)
            sendNextTest()
        }
        else{
            print("\n\nUpdate Received: \(characteristicUUIDString)\n\n")
        }
    }
    
    // Get called every 50 ms when Microneedle in Delay Mode
    @objc func delayUpdated(){
        let timeInMS = 50
        
        // Check if delay time met
        globalTimerDuration += UInt64(timeInMS)
        BluetoothInterface.instance.notifyDelayUpdate(by: UInt64(timeInMS))
        
        // Delay finished.....reset timer
        if globalTimerDuration >= testQueue.peek()!.totalDuration{
            globalTimerDuration = 0
            globalTimer?.invalidate()
            globalTimer = nil
            sendNextTest()
        }
    }
}
