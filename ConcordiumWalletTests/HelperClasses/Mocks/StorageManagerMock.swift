//
//  StorageManagerMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Wykop on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
@testable import Mock
class StorageManagerMock: StorageManagerMockHelper {
    var transfers = [TransferDataType]()
    var latestTermsAndConditionsVersion: String!
    override func getRecipient(withAddress address: String) -> RecipientDataType? {
        RecipientEntity()
    }

    override func getTransfers(for accountAddress: String) -> [TransferDataType] {
        transfers
    }

    func addMockLocalTransaction(time: Int) {
        let transferEntity = TransferEntity()
        transferEntity.createdAt = Date(timeIntervalSince1970: Double(time))
        transfers.append(transferEntity)
    }
    
    override func getLastAcceptedTermsAndConditionsVersion() -> String {
        latestTermsAndConditionsVersion
    }
}
