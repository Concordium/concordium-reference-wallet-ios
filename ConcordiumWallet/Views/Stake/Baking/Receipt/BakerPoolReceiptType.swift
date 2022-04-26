//
//  BakerPoolReceiptType.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum BakerPoolReceiptType {
    case updateStake(isLoweringStake: Bool)
    case updatePool
    case updateKeys
    case remove
    case register
    
    init(dataHandler: StakeDataHandler) {
        if dataHandler.hasCurrentData() {
            switch dataHandler.transferType {
            case .updateBakerStake:
                self = .updateStake(isLoweringStake: dataHandler.isLoweringStake())
            case .updateBakerPool:
                self = .updatePool
            case .updateBakerKeys:
                self = .updateKeys
            default:
                self = .remove
            }
        } else {
            self = .register
        }
    }
}
