//
//  ExportedBakerKeys.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 19/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct ExportedBakerKeys: Codable {
    let bakerId: Int
    let generatedKeys: GeneratedBakerKeys
    
    enum CodingKeys: String, CodingKey {
        case bakerId = "bakerId"
        case electionVerifyKey = "electionVerifyKey"
        case electionPrivateKey = "electionPrivateKey"
        case signatureVerifyKey = "signatureVerifyKey"
        case signatureSignKey = "signatureSignKey"
        case aggregationVerifyKey = "aggregationVerifyKey"
        case aggregationSignKey = "aggregationSignKey"
    }
    
    init(bakerId: Int, generatedKeys: GeneratedBakerKeys) {
        self.bakerId = bakerId
        self.generatedKeys = generatedKeys
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        bakerId = try container.decode(Int.self, forKey: .bakerId)
        generatedKeys = GeneratedBakerKeys(
            electionVerifyKey: try container.decode(String.self, forKey: .electionVerifyKey),
            electionPrivateKey: try container.decode(String.self, forKey: .electionPrivateKey),
            signatureVerifyKey: try container.decode(String.self, forKey: .signatureVerifyKey),
            signatureSignKey: try container.decode(String.self, forKey: .signatureSignKey),
            aggregationVerifyKey: try container.decode(String.self, forKey: .aggregationVerifyKey),
            aggregationSignKey: try container.decode(String.self, forKey: .signatureSignKey)
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bakerId, forKey: .bakerId)
        try container.encode(generatedKeys.electionVerifyKey, forKey: .electionVerifyKey)
        try container.encode(generatedKeys.electionPrivateKey, forKey: .electionPrivateKey)
        try container.encode(generatedKeys.signatureVerifyKey, forKey: .signatureVerifyKey)
        try container.encode(generatedKeys.signatureSignKey, forKey: .signatureSignKey)
        try container.encode(generatedKeys.aggregationVerifyKey, forKey: .aggregationVerifyKey)
        try container.encode(generatedKeys.aggregationSignKey, forKey: .aggregationSignKey)
    }
}

extension ExportedBakerKeys {
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
}
