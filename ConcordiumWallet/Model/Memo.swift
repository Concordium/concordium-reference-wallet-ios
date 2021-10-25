//
//  Memo.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import SwiftCBOR

protocol MemoDataType {
    /// Display value of a memo
    var displayValue: String { get set }
    /// Data representation of a memo
    var data: Data { get }
    /// Size of a memo
    var size: Int { get }
    /// Validity of a memo size
    var hasValidSize: Bool { get }
}

struct Memo: MemoDataType {
    private enum Constants {
        static let maxSize = 256
    }
    
    var data: Data {
        Data(bytes: encoded, count: encoded.count)
    }
    
    var displayValue: String
    
    var size: Int { encoded.count }
    
    var hasValidSize: Bool { size <= Memo.Constants.maxSize }
    
    init(_ rawValue: String) {
        self.displayValue = rawValue
    }
    
    init?(hex: String?) {
        guard
            let hex = hex,
            let data = Data(hex: hex)
        else {
            return nil
        }
        
        if case .utf8String(let decodedValue) = try? CBOR.decode(data.bytes) {
            /// Since the SwiftCBOR cannot ensure that the entire input was decoded
            /// we double check it by comparing the hex value of a successfuly
            /// decoded hex which was yet again encoded and the original hex
            let encodedDecodedValue = decodedValue.encode()
            let decodedValueHex = Data(bytes: encodedDecodedValue, count: encodedDecodedValue.count).hexDescription
            let displayValue = decodedValueHex == hex ? decodedValue : hex
            self.displayValue = displayValue
        } else {
            self.displayValue = hex
        }
    }
}

// MARK: - CBOREncodable
extension Memo: CBOREncodable {
    var encoded: [UInt8] { displayValue.encode() }
}
