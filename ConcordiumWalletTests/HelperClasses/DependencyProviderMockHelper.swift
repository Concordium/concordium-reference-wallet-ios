//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
@testable import Mock

class DependencyProviderMockHelper: AccountsFlowCoordinatorDependencyProvider {
    func appSettingsService() -> AppSettingsService {
        fatalError("appSettingsService() has not been implemented")
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
