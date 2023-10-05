//
//  SerializeTokenTransferParametersInput.swift
//  ConcordiumWallet
//

import Foundation

struct SerializeTokenTransferParametersInput: Codable {
    var tokenId: String
    var amount: String
    var from: String
    var to: String
}
