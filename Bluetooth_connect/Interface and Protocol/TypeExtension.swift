//
//  TypeExtension.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 4/3/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Foundation
import UIKit

func toDataObject<T>(value: T) -> Data{
    return withUnsafeBytes(of: value) { Data($0) }
}

extension Data {
    
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            let i16array = self.withUnsafeBytes { $0.load(as: UInt16.self) }
            return i16array
        }
    }
    
    var uint32: UInt32 {
        get {
            let i32array = self.withUnsafeBytes { $0.load(as: UInt32.self) }
            return i32array
        }
    }
    
    var int32: Int32 {
        get {
            let i32array = self.withUnsafeBytes { $0.load(as: Int32.self) }
            return i32array
        }
    }
    
    var int16: Int16{
        get {
            let i16array = self.withUnsafeBytes { $0.load(as: Int16.self) }
            return i16array
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
        }
    }
    var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
    
    var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    func toByteArray() -> [UInt8] {
        var byteData = [UInt8](repeating:0, count: self.count)
        self.copyBytes(to: &byteData, count: self.count)
        return byteData
    }
}


extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        return self[index(startIndex, offsetBy: i)]
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    static var colorArray: [UIColor] = [
        UIColor.orange,
        UIColor.red,
        UIColor.black,
        UIColor.blue,
        UIColor.green,
        UIColor.gray,
        UIColor.cyan,
        UIColor.magenta,
        UIColor.brown,
        UIColor.purple,
        UIColor(red: 0.064582, green: 0.705481, blue: 0.874373, alpha: 1),
        UIColor(red: 1, green: 0xb6/255, blue: 0x9d/255, alpha: 1)
    ]
}
