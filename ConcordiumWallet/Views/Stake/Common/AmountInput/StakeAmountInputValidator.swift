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
    var balance: GTU
    var atDisposal: GTU
    var releaseSchedule: GTU
    var currentPool: GTU?
    var poolLimit: GTU?
    var previouslyStakedInPool: GTU
    var isInCooldown: Bool
    var oldPool: BakerTarget?
    var newPool: BakerTarget?
    
    func validate(amount: GTU, fee: GTU) -> Result<GTU, StakeError> {
        .success(amount)
        .flatMap(checkMaximum(amount:))
        .flatMap(checkMinimum(amount:))
        .flatMap { checkBalance(amount: $0, fee: fee) }
        .flatMap { checkAtDisposal(amount: $0, fee: fee) }
        .flatMap(checkPoolLimit(amount:))
    }
    
    func checkMaximum(amount: GTU) -> Result<GTU, StakeError> {
        if let maximumValue = maximumValue {
            if amount > maximumValue {
                return .failure(.maximumAmount(maximumValue))
            }
        }
        return .success(amount)
    }
    func checkMinimum(amount: GTU) -> Result<GTU, StakeError> {
        if amount < minimumValue {
            return .failure(.minimumAmount(minimumValue))
        }
        return .success(amount)
    }
    func checkAtDisposal(amount: GTU, fee: GTU) -> Result<GTU, StakeError> {
        if amount - previouslyStakedInPool - releaseSchedule > atDisposal || fee > atDisposal {
            return .failure(.notEnoughFund(atDisposal))
        }
        return .success(amount)
    }
    func checkBalance(amount: GTU, fee: GTU) -> Result<GTU, StakeError> {
        if amount + fee > balance {
            return .failure(.notEnoughFund(balance))
        }
        return .success(amount)
    }
    func checkPoolLimit(amount: GTU) -> Result<GTU, StakeError> {
        guard let currentPool = currentPool, let poolLimit = poolLimit else {
            return .success(amount)
        }
        let previousStake: GTU = {
            if oldPool == newPool {
                return previouslyStakedInPool
            } else {
                return .zero
            }
        }()
        if amount + currentPool - previousStake > poolLimit {
            return .failure(.poolLimitReached(currentPool, poolLimit, isInCooldown))
        }
        return .success(amount)
    }
}
