//
//  SeedMobileWallet.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine
import MnemonicSwift

protocol SeedMobileWalletProtocol {
    var hasSetupRecoveryPhrase: Bool { get }
    
    func getSeed(with pwHash: String) -> Seed?
    func getSeed(withDelegate requestPasswordDelegate: RequestPasswordDelegate) async throws -> Seed
    
    func removeSeed() throws
    
    func store(recoveryPhrase: RecoveryPhrase, with pwHash: String) -> Result<Seed, Error>
    func store(recoveryPhrase: RecoveryPhrase, withDelegate requestPasswordDelegate: RequestPasswordDelegate) async throws -> Seed
    
    func updateSeed(oldPwHash: String, newPwHash: String) throws -> Seed?
 
    @MainActor
    func createIDRequest(
        for identitiyProvider: IdentityProviderDataType,
        index: Int,
        globalValues: GlobalWrapper,
        seed: Seed
    ) -> Result<IDRequestV1, Error>
    
    @MainActor
    func createCredentialRequest(
        for identity: IdentityDataType,
        global: GlobalWrapper,
        revealedAttributes: [String],
        accountNumber: Int,
        seed: Seed
    ) -> Result<CreateCredentialRequest, Error>
    
    func createIDRecoveryRequest(
        for identityProvider: IPInfo,
        global: GlobalWrapper,
        index: Int,
        seed: Seed
    ) -> Result<GenerateRecoveryRequestOutput, Error>
}

class SeedMobileWallet: SeedMobileWalletProtocol {
    private let seedKey = "RecoveryPhraseSeed"
    
    private let walletFacade = MobileWalletFacade()
    
    private let keychain: KeychainWrapperProtocol
    
    var hasSetupRecoveryPhrase: Bool {
        keychain.hasValue(key: seedKey)
    }
    
    init(keychain: KeychainWrapperProtocol) {
        self.keychain = keychain
    }
    
    func getSeed(with pwHash: String) -> Seed? {
        switch keychain.getValue(for: seedKey, securedByPassword: pwHash) {
        case let .success(seed):
            return Seed(value: seed)
        case .failure:
            return nil
        }
    }
    
    func getSeed(withDelegate requestPasswordDelegate: RequestPasswordDelegate) async throws -> Seed {
        let pwHash = try await requestPasswordDelegate.requestUserPassword(keychain: keychain)
        
        let seedValue = try self.keychain.getValue(for: seedKey, securedByPassword: pwHash).get()
        
        return Seed(value: seedValue)
    }
    
    func removeSeed() throws {
        try self.keychain.deleteKeychainItem(withKey: seedKey).get()
    }
    
    func store(recoveryPhrase: RecoveryPhrase, with pwHash: String) -> Result<Seed, Error> {
        return Result {
            let seed = try Mnemonic.deterministicSeedString(from: recoveryPhrase.joined(separator: " "))
         
            try keychain.store(key: seedKey, value: seed, securedByPassword: pwHash).get()
            
            return Seed(value: seed)
        }
    }
    
    func store(recoveryPhrase: RecoveryPhrase, withDelegate requestPasswordDelegate: RequestPasswordDelegate) async throws -> Seed {
        let pwHash = try await requestPasswordDelegate.requestUserPassword(keychain: keychain)
        
        return try store(recoveryPhrase: recoveryPhrase, with: pwHash).get()
    }
    
    func updateSeed(oldPwHash: String, newPwHash: String) throws -> Seed? {
        if let seed = getSeed(with: oldPwHash) {
            try keychain.store(key: seedKey, value: seed.value, securedByPassword: newPwHash).get()
            
            return seed
        }
        
        return nil
    }
    
    func createIDRequest(
        for identitiyProvider: IdentityProviderDataType,
        index: Int,
        globalValues: GlobalWrapper,
        seed: Seed
    ) -> Result<IDRequestV1, Error> {
        guard let createRequset = CreateIDRequestV1(
            identityProvider: identitiyProvider,
            global: globalValues,
            seed: seed,
            net: .current,
            identityIndex: index
        ) else {
            return .failure(MobileWalletError.invalidArgument)
        }
        
        return Result {
            try walletFacade.createIdRequestAndPrivateData(input: createRequset)
        }
    }
    
    func createCredentialRequest(
        for identity: IdentityDataType,
        global: GlobalWrapper,
        revealedAttributes: [String],
        accountNumber: Int,
        seed: Seed
    ) -> Result<CreateCredentialRequest, Error> {
        guard let createRequest = CreateSeedCredentialRequest(
            identity: identity,
            globalWrapper: global,
            revealedAttributes: revealedAttributes,
            expiry: Date(timeIntervalSinceNow: 10 * 60),
            accountNumber: accountNumber,
            seed: seed
        ) else {
            return .failure(MobileWalletError.invalidArgument)
        }
        
        return Result {
            try walletFacade.createCredential(input: createRequest)
        }
    }
    
    func createIDRecoveryRequest(
        for identityProvider: IPInfo,
        global: GlobalWrapper,
        index: Int,
        seed: Seed
    ) -> Result<GenerateRecoveryRequestOutput, Error> {
        let input = GenerateRecoveryRequestInput(
            identityProvider: identityProvider,
            globalWrapper: global,
            seed: seed,
            index: index
        )
        
        return Result {
            try walletFacade.generateRecoveryRequest(input: input)
        }
    }
}

private extension CreateIDRequestV1 {
    init?(
        identityProvider: IdentityProviderDataType,
        global: GlobalWrapper,
        seed: Seed,
        net: Net,
        identityIndex: Int
    ) {
        guard let ipInfo = identityProvider.ipInfo.map(IPInfoV1.init(oldIPInfo:)) else {
            return nil
        }
        
        guard let arsInfos = identityProvider.arsInfos?.mapValues(ARSInfoV1.init(oldARSInfo:)) else {
            return nil
        }
        
        self.ipInfo = ipInfo
        self.arsInfos = arsInfos
        self.global = global.value
        self.seed = seed
        self.net = net
        self.identityIndex = identityIndex
    }
}

private extension IPInfoV1 {
    init(oldIPInfo: IPInfo) {
        ipIdentity = oldIPInfo.ipIdentity
        name = oldIPInfo.ipDescription.name
        url = oldIPInfo.ipDescription.url
        description = oldIPInfo.ipDescription.desc
        ipVerifyKey = oldIPInfo.ipVerifyKey
        ipCdiVerifyKey = oldIPInfo.ipCdiVerifyKey
    }
}

private extension ARSInfoV1 {
    init(oldARSInfo: ArsInfo) {
        arIdentity = oldARSInfo.arIdentity
        name = oldARSInfo.arDescription.name
        url = oldARSInfo.arDescription.url
        description = oldARSInfo.arDescription.desc
        arPublicKey = oldARSInfo.arPublicKey
    }
}

private extension CreateSeedCredentialRequest {
    init?(
        identity: IdentityDataType,
        globalWrapper: GlobalWrapper,
        revealedAttributes: [String],
        expiry: Date,
        accountNumber: Int,
        seed: Seed
    ) {
        guard let oldIPInfo = identity.identityProvider?.ipInfo,
              let oldARSInfos = identity.identityProvider?.arsInfos,
              let identityObject = identity.seedIdentityObject
        else {
            return nil
        }
        
        ipInfo = IPInfoV1(oldIPInfo: oldIPInfo)
        arsInfos = oldARSInfos.mapValues(ARSInfoV1.init(oldARSInfo:))
        global = globalWrapper.value
        self.identityObject = identityObject
        self.revealedAttributes = revealedAttributes
        identityIndex = identity.index
        self.accountNumber = accountNumber
        self.seed = seed
        net = .current
        self.expiry = Int(expiry.timeIntervalSince1970)
    }
}

private extension GenerateRecoveryRequestInput {
    init(
        identityProvider: IPInfo,
        globalWrapper: GlobalWrapper,
        seed: Seed,
        index: Int
    ) {
        ipInfo = IPInfoV1(oldIPInfo: identityProvider)
        global = globalWrapper.value
        timestamp = Int(Date().timeIntervalSince1970)
        self.seed = seed
        net = .current
        identityIndex = index
    }
}
