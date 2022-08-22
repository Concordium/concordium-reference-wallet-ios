//
// Created by Concordium on 26/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

protocol WalletAndStorageDependencyProvider {
    func mobileWallet() -> MobileWalletProtocol
    func seedMobileWallet() -> SeedMobileWalletProtocol
    func storageManager() -> StorageManagerProtocol
}

protocol AccountsFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func transactionsService() -> TransactionsServiceProtocol
    func accountsService() -> AccountsServiceProtocol
    func identitiesService() -> IdentitiesService
    func appSettingsService() -> AppSettingsService
}

protocol IdentitiesFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func identitiesService() -> IdentitiesService
    func seedIdentitiesService() -> SeedIdentitiesService
    func seedAccountsService() -> SeedAccountsService
}

protocol MoreFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func exportService() -> ExportService
    func keychainWrapper() -> KeychainWrapperProtocol
}

protocol LoginDependencyProvider: WalletAndStorageDependencyProvider {
    func keychainWrapper() -> KeychainWrapperProtocol
    func appSettingsService() -> AppSettingsService
    func recoveryPhraseService() -> RecoveryPhraseService
    func seedMobileWallet() -> SeedMobileWalletProtocol
    func seedIdentitiesService() -> SeedIdentitiesService
    func seedAccountsService() -> SeedAccountsService
}

protocol ImportDependencyProvider {
    func importService() -> ImportService
    func keychainWrapper() -> KeychainWrapperProtocol
}

protocol StakeCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func transactionsService() -> TransactionsServiceProtocol
    func stakeService() -> StakeServiceProtocol
    func accountsService() -> AccountsServiceProtocol
    func exportService() -> ExportService
}

class ServicesProvider {
    private let _mobileWallet: MobileWalletProtocol
    private let _seedMobileWallet: SeedMobileWalletProtocol
    private let _networkManager: NetworkManagerProtocol
    private let _storageManager: StorageManagerProtocol
    private let _keychainWrapper: KeychainWrapper

    init(mobileWallet: MobileWalletProtocol,
         seedMobileWallet: SeedMobileWalletProtocol,
         networkManager: NetworkManagerProtocol,
         storageManager: StorageManagerProtocol,
         keychainWrapper: KeychainWrapper) {
        self._mobileWallet = mobileWallet
        self._seedMobileWallet = seedMobileWallet
        self._networkManager = networkManager
        self._storageManager = storageManager
        self._keychainWrapper = keychainWrapper
    }
}

extension ServicesProvider: WalletAndStorageDependencyProvider {
    func mobileWallet() -> MobileWalletProtocol {
        _mobileWallet
    }

    func storageManager() -> StorageManagerProtocol {
        _storageManager
    }
}

extension ServicesProvider: IdentitiesFlowCoordinatorDependencyProvider {
    func identitiesService() -> IdentitiesService {
        IdentitiesService(networkManager: _networkManager, storageManager: _storageManager)
    }
    
    func seedIdentitiesService() -> SeedIdentitiesService {
        SeedIdentitiesService(
            networkManager: _networkManager,
            storageManager: _storageManager,
            mobileWallet: _seedMobileWallet
        )
    }
    
    func seedAccountsService() -> SeedAccountsService {
        SeedAccountsService(
            mobileWallet: _seedMobileWallet,
            networkManager: _networkManager,
            storageManager: _storageManager,
            keychainWrapper: _keychainWrapper
        )
    }
}

extension ServicesProvider: AccountsFlowCoordinatorDependencyProvider {
    func accountsService() -> AccountsServiceProtocol {
        AccountsService(networkManager: _networkManager, mobileWallet: _mobileWallet, storageManager: _storageManager, keychain: keychainWrapper())
    }

    func transactionsService() -> TransactionsServiceProtocol {
        TransactionsService(networkManager: _networkManager, mobileWallet: _mobileWallet, storageManager: _storageManager)
    }
    
    func stakeService() -> StakeServiceProtocol {
        StakeService(networkManager: _networkManager, mobileWallet: _mobileWallet)
    }

    func appSettingsService() -> AppSettingsService {
        AppSettingsService(networkManager: _networkManager)
    }
}

extension ServicesProvider: StakeCoordinatorDependencyProvider {
}

extension ServicesProvider: LoginDependencyProvider {
    func keychainWrapper() -> KeychainWrapperProtocol {
        _keychainWrapper
    }
    
    func recoveryPhraseService() -> RecoveryPhraseService {
        RecoveryPhraseService(
            keychainWrapper: _keychainWrapper,
            mobileWallet: _seedMobileWallet
        )
    }
    
    func seedMobileWallet() -> SeedMobileWalletProtocol {
        _seedMobileWallet
    }
}

extension ServicesProvider: MoreFlowCoordinatorDependencyProvider {
    func exportService() -> ExportService {
        ExportService(storageManager: _storageManager)
    }
}

extension ServicesProvider: ImportDependencyProvider {
    func importService() -> ImportService {
        ImportService(storageManager: _storageManager, accountsService: accountsService(), mobileWallet: mobileWallet())
    }
}
