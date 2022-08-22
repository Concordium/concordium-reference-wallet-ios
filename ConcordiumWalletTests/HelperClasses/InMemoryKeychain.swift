//
//  InMemoryKeychain.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 22/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine
@testable import Mock

class InMemoryKeychain: KeychainWrapperProtocol {
    private struct Item {
        let password: String?
        let value: String
    }
    
    private var values = [String: Item]()
    
    func hasValue(key: String) -> Bool {
        values[key] != nil
    }
    
    func store(key: String, value: String, securedByPassword password: String) -> Result<Void, KeychainError> {
        values[key] = .init(password: password, value: value)
        
        return .success(Void())
    }
    
    func getValue(for key: String, securedByPassword password: String) -> Result<String, KeychainError> {
        guard let item = values[key] else {
            return .failure(.itemNotFound)
        }
        
        guard password == item.password else {
            return .failure(.wrongPassword)
        }
        
        return .success(item.value)
    }
    
    func getValueWithBiometrics(for key: String) -> AnyPublisher<String, KeychainError> {
        guard let item = values[key] else {
            return .fail(.itemNotFound)
        }
        
        return .just(item.value)
    }
    
    func storeWithBiometrics(key: String, value: String) -> AnyPublisher<Void, KeychainError> {
        values[key] = .init(password: nil, value: value)
        
        return .just(Void())
    }
    
    func deleteKeychainItem(withKey key: String) -> Result<Void, KeychainError> {
        values[key] = nil
        return .success(Void())
    }
}
