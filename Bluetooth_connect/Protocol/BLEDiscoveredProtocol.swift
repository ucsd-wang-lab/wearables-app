//
//  BLEDiscoveredProtocol.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 4/1/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Foundation

protocol BLEDiscoveredObserver{
    var id : Int { get } // property to get an id
    func update<T>(with name: String, with device: T)
    func deviceConnected<T>(with device: T)
    func didBTEnable(with value: Bool)
}
