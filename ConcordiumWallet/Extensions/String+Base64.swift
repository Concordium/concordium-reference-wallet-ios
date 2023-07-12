//
//  String+Base64.swift
//  ConcordiumWallet
//

import Foundation

/// The fixedBase64Format property and provides a fixed-length Base64 format for the string.
/// The method calculates the current offset of the string's length modulo 4. If the offset is zero, indicating that the length is already a multiple of 4, the method returns the original string. Otherwise

extension String {
    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}
