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
                self.add(entry: DelegationStopAccountData(accountAddress: account.address))
            } else {
                super.init(transferType: .updateDelegation)
                currentData = Set()
                currentData?.update(with: DelegationAccountData(accountAddress: account.address))
                currentData?.update(with: AmountData(amount: GTU(intValue: delegation.stakedAmount)))
                currentData?.update(with: RestakeDelegationData(restake: delegation.restakeEarnings))
                let bakerPool = BakerTarget.from(delegationType: delegation.delegationTargetType, bakerId: delegation.delegationTargetBakerID)
                currentData?.update(with: PoolDelegationData(pool: bakerPool))
                self.add(entry: DelegationAccountData(accountAddress: account.address))
            }
        } else {
            // register delegation
            super.init(transferType: .registerDelegation)
            self.add(entry: DelegationAccountData(accountAddress: account.address))
        }
    }
    override func getTransferObject() -> TransferDataType {
        if isNewAmountZero() {
            var transfer = TransferDataTypeFactory.create()
            transfer.transferType = .removeDelegation
            return transfer
        }
        return super.getTransferObject()
    }
}
