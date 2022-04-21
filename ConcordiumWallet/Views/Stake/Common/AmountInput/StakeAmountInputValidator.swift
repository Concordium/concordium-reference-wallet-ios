//
//  StakeAmountInputValidator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 20/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

struct StakeAmountInputValidator {
    var minimumValue: GTU
    var maximumValue: GTU?
    var atDisposal: GTU
    var currentPool: GTU?
    var poolLimit: GTU?
    var previouslyStakedInPool: GTU
    
    func validate(amount: GTU) -> Result<GTU, StakeError> {
        .success(amount).flatMap {
            checkMaximum(amount: $0)
        }.flatMap {
            checkMinimum(amount: $0)
        }.flatMap {
            checkAtDisposal(amount: $0)
        }.flatMap {
            checkPoolLimit(amount: $0)
        }
    }
    
    func checkMaximum(amount: GTU) -> Result<GTU, StakeError> {
        if let maximumValue = maximumValue {
            if amount.intValue > maximumValue.intValue {
                return .failure(.maximumAmount(maximumValue))
            }
        }
        return .success(amount)
    }
    func checkMinimum(amount: GTU) -> Result<GTU, StakeError> {
        if amount.intValue < minimumValue.intValue {
            return .failure(.minimumAmount(minimumValue))
        }
        return .success(amount)
    }
    func checkAtDisposal(amount: GTU) -> Result<GTU, StakeError> {
        if amount.intValue > atDisposal.intValue {
            return .failure(.notEnoughFund(atDisposal))
        }
        return .success(amount)
    }
    func checkPoolLimit(amount: GTU) -> Result<GTU, StakeError> {
        guard let currentPool = currentPool, let poolLimit = poolLimit else {
            return .success(amount)
        }
        if amount.intValue + currentPool.intValue - previouslyStakedInPool.intValue > poolLimit.intValue {
            return .failure(.poolLimitReached(currentPool, poolLimit))
        }
        return .success(amount)
    }
}
