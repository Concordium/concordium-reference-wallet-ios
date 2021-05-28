//
// Created by Concordium on 20/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

extension ServicesProvider {
    static func defaultProvider() -> ServicesProvider {
        Logger.warn("Running with **MOCK** data")
        let keychain: KeychainWrapper = KeychainWrapper()
        let storageManager: StorageManager = StorageManager(keychain: keychain)
        return ServicesProvider(mobileWallet: MobileWallet(storageManager: storageManager, keychain: keychain),
                                networkManager: NetworkManager(session: NetworkSessionMock()),
                                storageManager: storageManager,
                                keychainWrapper: keychain)
    }

}
