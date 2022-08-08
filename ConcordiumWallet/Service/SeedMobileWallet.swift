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
    func getSeed(withDelegate requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<Seed, Error>
    
    func store(recoveryPhrase: RecoveryPhrase, with pwHash: String) -> Result<Seed, Error>
 
    func createIDRequest(
        for identitiyProvider: IdentityProviderDataType,
        index: Int,
        globalValues: GlobalWrapper,
        seed: Seed
    ) -> Result<IDRequestV1, Error>
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
    
    func getSeed(withDelegate requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<Seed, Error> {
        requestPasswordDelegate.requestUserPassword(keychain: keychain)
            .flatMap { pwHash in
                self.keychain.getValue(
                    for: self.seedKey,
                    securedByPassword: pwHash
                )
                .map { Seed(value: $0) }
                .publisher
                .mapError { $0 as Error }
            }
            .eraseToAnyPublisher()
    }
    
    func store(recoveryPhrase: RecoveryPhrase, with pwHash: String) -> Result<Seed, Error> {
        return Result {
            let seed = try Mnemonic.deterministicSeedString(from: recoveryPhrase.joined(separator: " "))
         
            try keychain.store(key: seedKey, value: seed, securedByPassword: pwHash).get()
            
            return Seed(value: seed)
        }
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

private extension GlobalVariables {
    init?(global: GlobalWrapper) {
        guard let genesisString = global.value.genesisString,
              let onChainCommitmentKey = global.value.onChainCommitmentKey,
              let bulletproofGenerators = global.value.bulletproofGenerators
        else {
            return nil
        }
        
        self.genesisString = genesisString
        self.onChainCommitmentKey = onChainCommitmentKey
        self.bulletproofGenerators = bulletproofGenerators
    }
}
