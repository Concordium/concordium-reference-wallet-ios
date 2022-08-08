//
//  CreateIDRequestV1.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct CreateIDRequestV1: Codable {
    let ipInfo: IPInfoV1
    let arsInfos: [String: ARSInfoV1]
    let global: Global
    let seed: Seed
    let net: Net
    let identityIndex: Int
}

struct IPInfoV1: Codable {
    let ipIdentity: Int
    let name: String
    let url: String
    let description: String
    let ipVerifyKey: String
    let ipCdiVerifyKey: String
    
    enum CodingKeys: String, CodingKey {
        case ipIdentity
        case ipDescription
        case ipVerifyKey
        case ipCdiVerifyKey
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        ipIdentity = try container.decode(Int.self, forKey: .ipIdentity)
        ipVerifyKey = try container.decode(String.self, forKey: .ipVerifyKey)
        ipCdiVerifyKey = try container.decode(String.self, forKey: .ipCdiVerifyKey)
        
        let description = try container.decode(DescriptionV1.self, forKey: .ipDescription)
        
        name = description.name
        url = description.url
        self.description = description.description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ipIdentity, forKey: .ipIdentity)
        try container.encode(ipVerifyKey, forKey: .ipVerifyKey)
        try container.encode(ipCdiVerifyKey, forKey: .ipCdiVerifyKey)
        try container.encode(
            DescriptionV1(name: name, url: url, description: description),
            forKey: .ipDescription
        )
    }
}

struct ARSInfoV1: Codable {
    let arIdentity: Int
    let name: String
    let url: String
    let description: String
    let arPublicKey: String
    
    enum CodingKeys: String, CodingKey {
        case arIdentity
        case arDescription
        case arPublicKey
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        arIdentity = try container.decode(Int.self, forKey: .arIdentity)
        arPublicKey = try container.decode(String.self, forKey: .arPublicKey)
        
        let description = try container.decode(DescriptionV1.self, forKey: .arDescription)
        
        name = description.name
        url = description.url
        self.description = description.description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(arIdentity, forKey: .arIdentity)
        try container.encode(arPublicKey, forKey: .arPublicKey)
        
        try container.encode(
            DescriptionV1(name: name, url: url, description: description),
            forKey: .arDescription
        )
    }
}

struct GlobalVariables: Codable {
    let genesisString: String
    let onChainCommitmentKey: String
    let bulletproofGenerators: String
}

private struct DescriptionV1: Codable {
    let name: String
    let url: String
    let description: String
}
