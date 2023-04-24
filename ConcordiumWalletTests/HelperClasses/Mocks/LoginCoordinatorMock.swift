//
//  LoginCoordinatorMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
@testable import Mock

class LoginCoordinatorMock: LoginCoordinator {
    
}

class LoginDependencyProviderMock: LoginDependencyProvider {
    func appSettingsService() -> AppSettingsService {
        fatalError("identitiesService() has not been implemented")
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
        fatalError("storageManager() has not been implemented")
    }

    func seedMobileWallet() -> SeedMobileWalletProtocol {
        fatalError("seedMobileWallet() has not been implemented")
    }
}
