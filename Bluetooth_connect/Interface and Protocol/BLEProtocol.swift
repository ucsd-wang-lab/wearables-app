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
}

protocol BLEServiceObserver {
    var id : Int { get } // property to get an id
    func update<T>(with uuid: String, with service: T)   // didDiscoveredService
}

protocol BLECharacteristicObserver {
    var id : Int { get } // property to get an id
    func characteristicDiscovered(with characteristicUUIDString: String)   // didDiscoveredCharacteristics
}

protocol BLEValueUpdateObserver {
    var id : Int { get } // property to get an id
    func update<T>(with characteristicUUIDString: String, with value: T)   // valueUpdatedforCharacteristics
}
