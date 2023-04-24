//
//  ConcordiumTestCase.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 22/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
@testable import Mock

class ConcordiumTestCase: XCTestCase {
    let mockNetwork = NetworkSessionMock()

    func getTestProvider() -> ServicesProvider {
        var storageConfig = RealmHelper.realmConfiguration
        storageConfig.inMemoryIdentifier = name
        let keychain = InMemoryKeychain()
        let storageManager = StorageManager(keychain: keychain, configuration: storageConfig)
        
        return ServicesProvider(
            mobileWallet: MobileWallet(
                storageManager: storageManager,
                keychain: keychain
            ),
            seedMobileWallet: SeedMobileWallet(keychain: keychain),
            networkManager: NetworkManager(session: mockNetwork),
            storageManager: storageManager,
            keychainWrapper: keychain
        )
    }
    
    override func setUp() {
        mockNetwork.clearOverrides()
    }
}
