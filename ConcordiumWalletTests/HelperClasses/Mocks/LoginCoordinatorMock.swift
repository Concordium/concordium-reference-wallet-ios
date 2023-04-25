//
//  LoginCoordinatorMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
@testable import Mock

class LoginDependencyProviderStub: LoginDependencyProvider {
    func appSettingsService() -> AppSettingsServiceProtocol {
        AppSettingsServiceProtocolMock()
    }

    func recoveryPhraseService() -> RecoveryPhraseService {
        fatalError("identitiesService() has not been implemented")
    }

    func seedIdentitiesService() -> SeedIdentitiesService {
        fatalError("identitiesService() has not been implemented")
    }

    func seedAccountsService() -> SeedAccountsService {
        fatalError("identitiesService() has not been implemented")
    }

    func keychainWrapper() -> KeychainWrapperProtocol {
        InMemoryKeychain()
    }

    func transactionsService() -> TransactionsServiceProtocol {
        fatalError("transactionsService() has not been implemented")
    }

    func accountsService() -> AccountsServiceProtocol {
        fatalError("accountsService() has not been implemented")
    }

    func identitiesService() -> IdentitiesService {
        fatalError("identitiesService() has not been implemented")
    }

    func mobileWallet() -> MobileWalletProtocol {
        fatalError("mobileWallet() has not been implemented")
    }

    func storageManager() -> StorageManagerProtocol {
        StorageManagerMock()
    }

    func seedMobileWallet() -> SeedMobileWalletProtocol {
        fatalError("seedMobileWallet() has not been implemented")
    }
}
