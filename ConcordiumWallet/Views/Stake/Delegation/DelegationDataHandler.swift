//
//  DelegationDataHandler.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class DelegationDataHandler : StakeDataHandler {
    init(account: AccountDataType, isRemoving: Bool) {
        if let delegation = account.delegation {
            if isRemoving {
                super.init(transferType: .removeDelegation)
            } else {
                super.init(transferType: .updateDelegation)
                currentData = Set()
                currentData?.update(with: AmountData(amount: GTU(intValue: Int(delegation.stakedAmount) ?? 0)))
                currentData?.update(with: RestakeDelegationData(restake: delegation.restakeEarnings))
                currentData?.update(with: PoolDelegationData(pool: BakerPool.from(delegationType: delegation.delegationTargetType, bakerId: delegation.delegationTargetBakerID)))
            }
        } else {
            //register delegation
            super.init(transferType: .registerDelegation)
        }
        self.add(entry: DelegationAccountData(accountAddress: account.address))
    }
}
