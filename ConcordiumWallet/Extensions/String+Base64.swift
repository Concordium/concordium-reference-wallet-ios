//
//  String+Base64.swift
//  ConcordiumWallet
//

import Foundation

///      Returns the fixed base64 format of the string.
/// This method is used to ensure that a string representing base64-encoded data has a proper format. In some cases,
/// when working with certain schemas or data sources, the base64 string returned may not adhere to the standard format.
/// This method addresses that issue by adding padding characters ('=') to the end of the string if its length is not a multiple of 4, thus making it a valid base64 format.

extension String {
    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}
