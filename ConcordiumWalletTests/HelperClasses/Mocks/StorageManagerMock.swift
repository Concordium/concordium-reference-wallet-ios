//
//  StorageManagerMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
@testable import Mock
class StorageManagerMock: StorageManagerMockHelper {
    var transfers = [TransferDataType]()
    var latestTermsAndConditionsVersion: String = ""
    var storeLastAcceptedTermsAndConditionsVersionCalled = false
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
    
    override func storeLastAcceptedTermsAndConditionsVersion(_ version: String) {
        storeLastAcceptedTermsAndConditionsVersionCalled = true
        latestTermsAndConditionsVersion = version
    }
}
