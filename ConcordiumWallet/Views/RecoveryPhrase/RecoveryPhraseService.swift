//
//  RecoveryPhraseService.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import MnemonicSwift
import Combine

protocol RecoveryPhraseServiceProtocol {
    func generateRecoveryPhrase(
        requestPasswordDelegate: RequestPasswordDelegate
    ) -> AnyPublisher<[String], Error>
}

struct RecoveryPhraseService {
    private static let recoveryPhraseKey = "CCD.RecoveryPhrase"
    private let keychainWrapper: KeychainWrapperProtocol
    
    init(keychainWrapper: KeychainWrapperProtocol) {
        self.keychainWrapper = keychainWrapper
    }
}

extension RecoveryPhraseService: RecoveryPhraseServiceProtocol {
    func generateRecoveryPhrase(
        requestPasswordDelegate: RequestPasswordDelegate
    ) -> AnyPublisher<[String], Error> {
        do {
            let recoveryPhrase = try Mnemonic.generateMnemonic(strength: 24 / 3 * 32)
            
            return Just(recoveryPhrase)
                .setFailureType(to: Error.self)
                .zip(requestPasswordDelegate.requestUserPassword(keychain: keychainWrapper))
                .tryMap { (recoveryPhrase, pwHash) in
                    try keychainWrapper.store(
                        key: RecoveryPhraseService.recoveryPhraseKey,
                        value: recoveryPhrase,
                        securedByPassword: pwHash
                    ).get()
                    
                    return recoveryPhrase.split(separator: " ").map { String($0) }
                }
                .eraseToAnyPublisher()
        } catch {
            return .fail(error)
        }
    }
}
