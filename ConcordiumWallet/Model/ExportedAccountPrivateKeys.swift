//
//  ExportedAccountPrivateKeys.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 19.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct ExportedAccountPrivateKeys: Codable {
    let environment: String
    let type: String
    let v: Int
    let value: ExportedAccountPrivateKeysValues
    
    enum CodingKeys: String, CodingKey {
        case environment = "environment"
        case type = "type"
        case v = "v"
        case value = "value"
    }
    
    init(privateKey: AccountKeys, address: String, credential: Credential) {
        self.environment = Environment.current.rawValue
        self.type = "exportedaccountprivatekeys.type".localized
        self.v = credential.v
        self.value = ExportedAccountPrivateKeysValues(privateKey: privateKey, address: address, credential: credential)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        environment = try container.decode(String.self, forKey: .environment)
        type = try container.decode(String.self, forKey: .type)
        v = try container.decode(Int.self, forKey: .v)
        value = try container.decode(ExportedAccountPrivateKeysValues.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(environment, forKey: .environment)
        try container.encode(type, forKey: .type)
        try container.encode(v, forKey: .v)
        try container.encode(value, forKey: .value)
    }
}

extension ExportedAccountPrivateKeys {
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
}

struct ExportedAccountPrivateKeysValues: Codable {
    let privateKey: AccountKeys
    let address: String
    let credential: [Int: String]
    
    enum CodingKeys: String, CodingKey {
        case privateKey = "accountKeys"
        case address = "address"
        case credential = "credentials"
    }
    
    init(privateKey: AccountKeys, address: String, credential: Credential) {
        guard let credId = credential.value.credential.contents.dictionary["credId"] as? String else {
                    fatalError("Could not cast credId")
                }
        
        self.privateKey = privateKey
        self.address = address
        self.credential = [0: credId]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        privateKey = try container.decode(AccountKeys.self, forKey: .privateKey)
        address = try container.decode(String.self, forKey: .address)
        credential = try container.decode([Int: String].self, forKey: .credential)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(privateKey, forKey: .privateKey)
        try container.encode(address, forKey: .address)
        try container.encode(credential, forKey: .credential)
    }
}
