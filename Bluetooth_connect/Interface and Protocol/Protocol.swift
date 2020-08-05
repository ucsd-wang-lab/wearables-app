//
//  BLEProtocol.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 4/1/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Foundation

/*
 * Protocol for when the BLE is being discovered for connection purpose
 */
protocol BLEDiscoveredObserver{
    var id : Int { get } // property to get an id
    func update<T>(with name: String, with device: T)   // when new BLE device discovered
    func didBTEnable(with value: Bool)          // to see if Bluetooth is ON/OFF
}

/*
 * Protocol for when a BLE device gets connected or disconnected
 */
@objc protocol BLEStatusObserver{
    var id: Int{ get }
    @objc optional func deviceDisconnected(with device: String)
    @objc optional func deviceConnected(with device: String)
    @objc optional func deviceFailToConnect(with device: String, error err: Error?)
}

protocol BLECharacteristicObserver {
    var id : Int { get } // property to get an id
    func characteristicDiscovered(with characteristicUUIDString: String)   // didDiscoveredCharacteristics
}

/*
 * Protocol for when new data in coming in through BLE
 */
@objc protocol BLEValueUpdateObserver {
    var id : Int { get } // property to get an id
    func update(with characteristicUUIDString: String, with value: Data)   // valueUpdatedforCharacteristics
    @objc optional func writeResponseReceived(with characteristicUUIDString: String)
}

protocol BLEValueRecordedObserver {
    var id: Int{ get }
    func valueRecorded(with characteristicUUIDString: String, with value: Data?)
}

protocol DelayUpdatedObserver {
    var id: Int{ get }
    func delayUpdate(by value: UInt64)
    func testFinish()
}
