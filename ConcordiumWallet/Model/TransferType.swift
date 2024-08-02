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
    
    func toWalletProxyTransferType() -> WalletProxyTransferType {
        switch self {
        case .simpleTransfer:
            return .simpleTransfer
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
            return .update
        }
    }
}

/// Transaction types as expected by Wallet Proxy
/// (see https://github.com/Concordium/concordium-wallet-proxy/blob/80ef058749d13f83e1f1afdecc6b1345f8def5fa/src/Proxy.hs#L687).
enum WalletProxyTransferType: String, Codable {
    case simpleTransfer

    case registerDelegation
    case updateDelegation
    case removeDelegation
    
    case registerBaker
    case updateBakerStake
    case updateBakerPool
    case updateBakerKeys
    case removeBaker
    case configureBaker

    case update
}
