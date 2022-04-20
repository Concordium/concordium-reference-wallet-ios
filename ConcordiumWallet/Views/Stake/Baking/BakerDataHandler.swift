//
//  BakerDataHandler.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class BakerDataHandler: StakeDataHandler {
    enum Action {
        case register // TODO: Add missing cases
        
    }
    
    init(account: AccountDataType, action: Action) {
        switch action {
        case .register:
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
