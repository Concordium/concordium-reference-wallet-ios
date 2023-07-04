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

    case contractUpdate = "Update"
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
    
    func toEstimateCostTransferType() -> EstimateCostTransferType {
        switch self {
        case .simpleTransfer:
            return .simpleTransfer
        case .encryptedTransfer:
            return .encryptedTransfer
        case .transferToSecret:
            return .transferToSecret
        case .transferToPublic:
            return .transferToPublic
        case .registerDelegation:
            return .registerDelegation
        case .updateDelegation:
            return .updateDelegation
        case .removeDelegation:
            return .removeDelegation
        case .registerBaker:
            return .registerBaker
        case .updateBakerStake:
            return .updateBakerStake
        case .updateBakerPool:
            return .updateBakerPool
        case .updateBakerKeys:
            return .updateBakerKeys
        case .removeBaker:
            return .removeBaker
        case .configureBaker:
            return .configureBaker
        case .contractUpdate:
            return .contractUpdate
        }
    }
}

enum EstimateCostTransferType: String, Codable {
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

    case contractUpdate = "update"
}
