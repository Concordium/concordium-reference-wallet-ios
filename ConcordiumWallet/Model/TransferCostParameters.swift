//
//  TransferCostParameters.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 22/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum TransferCostParameter {
    case memoSize(Int)
    
    case amount //only for updateDelegation updateBakerStake or configureBaker
    case restake //only for updateDelegation, updateBakerStake or configureBaker
    case lpool //only for registerDelegation or updateDelegation
    case target //only for updateDelegation
    
    case metadataSize(Int) //only for registerBaker, updateBakerPool or configureBaker
    case openStatus
    case transactionCommission // only for updateBakerPool or configureBaker
    case bakerRewardCommission // only for updateBakerPool or configureBaker
    case finalizationRewardCommission // only for updateBakerPool or configureBaker
    
    
    var name: String {
        switch self {
        case .memoSize:
            return "memoSize"
        
        case .amount:
            return "amount"
        case .restake:
            return "restake"
        case .lpool:
            return "lpool"
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
        }
    }
    
    var value: CustomStringConvertible? {
        switch self {
        case .memoSize(let size):
            return size
        case .metadataSize(let size):
            return size
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
