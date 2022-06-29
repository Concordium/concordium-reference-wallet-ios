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
    
    case registerDelegation
    case updateDelegation
    case removeDelegation
    
    case registerBaker
    case updateBakerStake
    case updateBakerPool
    case updateBakerKeys
    case removeBaker
    case configureBaker
    
    var isDelegationTransfer: Bool {
        switch self {
        case .registerDelegation, .updateDelegation, .removeDelegation:
            return true
        default:
            return false
        }
    }
    
    var isBakingTransfer: Bool {
        switch self {
        case .registerBaker, .updateBakerStake, .updateBakerPool,
                .updateBakerKeys, .removeBaker, .configureBaker:
            return true
        default:
            return false
        }
    }
}
