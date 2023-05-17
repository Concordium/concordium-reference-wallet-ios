//
//  DependencyProviderMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
@testable import Mock

class DependencyProviderMock: AccountsFlowCoordinatorDependencyProviderMock {
    var transactionsServiceMock: TransServiceMock
    var storageManagerMock: StorageManagerMock

    init(transactionsServiceMock: TransServiceMock, storageManagerMock: StorageManagerMock) {
        self.transactionsServiceMock = transactionsServiceMock
        self.storageManagerMock = storageManagerMock
        super.init()
    }

    override func transactionsService() -> TransactionsServiceProtocol {
        transactionsServiceMock
    }

    override func storageManager() -> StorageManagerProtocol {
        storageManagerMock
    }
}
