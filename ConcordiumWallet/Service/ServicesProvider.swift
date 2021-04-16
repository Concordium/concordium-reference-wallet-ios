//
// Created by Johan Rugager Vase on 26/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

protocol WalletAndStorageDependencyProvider {
    func mobileWallet() -> MobileWalletProtocol
    func storageManager() -> StorageManagerProtocol
}

protocol AccountsFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func transactionsService() -> TransactionsServiceProtocol
    func accountsService() -> AccountsServiceProtocol
    func identitiesService() -> IdentitiesService
}

protocol IdentitiesFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func identitiesService() -> IdentitiesService
}


protocol MoreFlowCoordinatorDependencyProvider: WalletAndStorageDependencyProvider {
    func exportService() -> ExportService
    func keychainWrapper() -> KeychainWrapperProtocol
}

protocol LoginDependencyProvider {
    func keychainWrapper() -> KeychainWrapperProtocol
}

protocol ImportDependencyProvider {
    func importService() -> ImportService
    func keychainWrapper() -> KeychainWrapperProtocol
}

class ServicesProvider {
    private let _mobileWallet: MobileWalletProtocol
    private let _networkManager: NetworkManagerProtocol
    private let _storageManager: StorageManagerProtocol
    private let _keychainWrapper: KeychainWrapper

    init(mobileWallet: MobileWalletProtocol,
         networkManager: NetworkManagerProtocol,
         storageManager: StorageManagerProtocol,
         keychainWrapper: KeychainWrapper) {
        self._mobileWallet = mobileWallet
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
}

extension ServicesProvider: AccountsFlowCoordinatorDependencyProvider {
    func accountsService() -> AccountsServiceProtocol {
        AccountsService(networkManager: _networkManager, mobileWallet: _mobileWallet, storageManager: _storageManager, keychain: keychainWrapper())
    }

    func transactionsService() -> TransactionsServiceProtocol {
        TransactionsService(networkManager: _networkManager, mobileWallet: _mobileWallet, storageManager: _storageManager)
    }
}

extension ServicesProvider: LoginDependencyProvider {
    func keychainWrapper() -> KeychainWrapperProtocol {
        _keychainWrapper
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
