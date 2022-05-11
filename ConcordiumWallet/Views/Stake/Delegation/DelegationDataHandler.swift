//
//  DelegationDataHandler.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class DelegationDataHandler: StakeDataHandler {
    init(account: AccountDataType, isRemoving: Bool) {
        if let delegation = account.delegation {
            if isRemoving {
                super.init(transferType: .removeDelegation)
                self.add(entry: DelegationStopAccountData(accountName: account.name, accountAddress: account.address))
            } else {
                super.init(transferType: .updateDelegation) {
                    DelegationAccountData(accountName: account.name, accountAddress: account.address)
                    DelegationAmountData(amount: GTU(intValue: delegation.stakedAmount))
                    RestakeDelegationData(restake: delegation.restakeEarnings)
                    PoolDelegationData(
                        pool: BakerTarget.from(
                            delegationType: delegation.delegationTargetType,
                            bakerId: delegation.delegationTargetBakerID
                        )
                    )
                }
                self.add(entry: DelegationAccountData(accountName: account.name, accountAddress: account.address))
            }
        } else {
            // register delegation
            super.init(transferType: .registerDelegation)
            self.add(entry: DelegationAccountData(accountName: account.name, accountAddress: account.address))
        }
    }
}
