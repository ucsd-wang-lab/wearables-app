//
//  BLEProtocol.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 4/1/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

protocol BLEDiscoveredObserver{
    var id : Int { get } // property to get an id
    func update<T>(with name: String, with device: T)   // when new BLE device discovered
    func deviceConnected<T>(with device: T)     // onConnect to BLE device
    func didBTEnable(with value: Bool)          // to see if Bluetooth is ON/OFF
}

protocol BLEServiceObserver {
    var id : Int { get } // property to get an id
    func update<T>(with uuid: String, with service: T)   // didDiscoveredService
}

protocol BLECharacteristicObserver {
    var id : Int { get } // property to get an id
    func update<T>(with uuid: String, with characteristic: T)   // didDiscoveredCharacteristics
}

protocol BLEValueUpdateObserver {
    var id : Int { get } // property to get an id
    func update<T>(with name: String, with device: T)   // valueUpdatedforCharacteristics
}
