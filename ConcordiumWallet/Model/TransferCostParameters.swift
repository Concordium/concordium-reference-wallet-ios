//
//  TransferCostParameters.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 22/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum TransferCostParameter: Equatable {
    case memoSize(Int)
    
    case restake // only for updateDelegation, updateBakerStake or configureBaker
    case passive // only for registerDelegation or updateDelegation
    case target // only for updateDelegation
    
    case metadataSize(Int) // only for registerBaker, updateBakerPool or configureBaker
    case openStatus
    case transactionCommission // only for updateBakerPool or configureBaker
    case bakerRewardCommission // only for updateBakerPool or configureBaker
    case finalizationRewardCommission // only for updateBakerPool or configureBaker
    
    case amount(String?)
    case sender(String)
    case contractIndex(Int)
    case contractSubindex(Int)
    case receiveName(String)
    case parameter(String)
    
    var name: String {
        switch self {
        case .memoSize:
            return "memoSize"
        case .amount(_):
            return "amount"
        case .restake:
            return "restake"
        case .passive:
            return "passive"
        case .target:
            return "target"
        case .metadataSize:
            return "metadataSize"

        case .openStatus:
            return "openStatus"
        case .transactionCommission:
            return "transactionCommission"
        case .bakerRewardCommission:
            return "bakerRewardCommission"
        case .finalizationRewardCommission:
            return "finalizationRewardCommission"
        case .sender(_):
            return "sender"
        case .contractIndex(_):
            return "contractIndex"
        case .contractSubindex(_):
            return "contractSubindex"
        case .receiveName(_):
            return "receiveName"
        case .parameter(_):
            return "parameter"
        }
    }
    
    var value: CustomStringConvertible? {
        switch self {
        case .memoSize(let size):
            return size
        case .metadataSize(let size):
            return size
        case .amount(let value):
            return value
        case .contractIndex(let index):
            return index
        case .contractSubindex(let subindex):
            return subindex
        case .receiveName(let name):
            return name
        case .parameter(let parameter):
            return parameter
        case .sender(let sender):
            return sender
        default:
            return nil
        }
    }
    static func parametersForMemoSize(_ size: Int?) -> [TransferCostParameter] {
        if let size = size {
            return [.memoSize(size)]
        }
        return []
    }
}
