//
//  TransferType.swift
//  ConcordiumWallet
//
//  Concordium on 31/08/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum TransferType: String, Codable {
    case simpleTransfer
    case encryptedTransfer
    case transferToSecret
    case transferToPublic
}
