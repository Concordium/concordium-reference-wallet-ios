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
    func generateRecoveryPhrase() -> Result<RecoveryPhrase, Error>
    
    func generateSuggestions(from words: RecoveryPhrase, maxNumberOfSuggestions: Int) -> [[String]]
    
    func suggestions(for word: String) -> [String]
    
    func validate(recoveryPhrase: [String]) -> Result<RecoveryPhrase, Error>
}

extension RecoveryPhraseServiceProtocol {
    func generateRecoveryPhrase() -> Result<RecoveryPhrase, Error> {
        return Result { try Mnemonic.generateMnemonic(strength: 24 / 3 * 32) }
            .flatMap { phrase in Result { try RecoveryPhrase(phrase: phrase) } }
    }
    
    func generateSuggestions(from recoveryPhrase: RecoveryPhrase, maxNumberOfSuggestions: Int) -> [[String]] {
        return recoveryPhrase.map { word in
            ([word] + recoveryPhrase.randomSequence(ofLength: maxNumberOfSuggestions - 1, skipping: word))
                .map { String($0) }
                .shuffled()
        }
    }
    
    func suggestions(for word: String) -> [String] {
        let lowercased = word.lowercased()
        
        let words = String.mnemonics.filter { $0.starts(with: lowercased) }
        
        return Array(words[0..<min(words.count, 4)])
    }
    
    func validate(recoveryPhrase: [String]) -> Result<RecoveryPhrase, Error> {
        return Result {
            let phrase = recoveryPhrase.joined(separator: " ")
            
            try Mnemonic.validate(mnemonic: phrase)
            
            return try RecoveryPhrase(phrase: phrase)
        }
    }
}

struct RecoveryPhraseService {
    private static let recoveryPhraseKey = "CCD.RecoveryPhrase"
    private let keychainWrapper: KeychainWrapperProtocol
    
    init(keychainWrapper: KeychainWrapperProtocol) {
        self.keychainWrapper = keychainWrapper
    }
}

extension RecoveryPhraseService: RecoveryPhraseServiceProtocol {}

private extension RandomAccessCollection where Element: Equatable {
    func randomSequence(ofLength length: Int, skipping elements: Element...) -> [Element] {
        var mutableCopy = Array(self)
        var result = [Element]()
        while !mutableCopy.isEmpty && result.count < length {
            let index = Int.random(in: 0..<mutableCopy.count)
            let value = mutableCopy.remove(at: index)
            if !elements.contains(value) {
                result.append(value)
            }
        }
        
        return result
    }
}
