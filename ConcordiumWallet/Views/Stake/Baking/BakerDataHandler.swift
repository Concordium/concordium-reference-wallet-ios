//
//  BakerDataHandler.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class BakerDataHandler: StakeDataHandler {
    // TODO: option can be a menu option
    init(account: AccountDataType, option: Bool) {
        if account.baker != nil {
           // TODO: switch on the option to figure out what to do
            super.init(transferType: .removeBaker)
        } else {
            // register baker
            super.init(transferType: .registerBaker)
        }
        self.add(entry: DelegationAccountData(accountAddress: account.address))
    }
    
    override func getTransferObject() -> TransferDataType {
        if isNewAmountZero() {
            var transfer = TransferDataTypeFactory.create()
            transfer.transferType = .removeBaker
            return transfer
        }
        return super.getTransferObject()
    }
}
