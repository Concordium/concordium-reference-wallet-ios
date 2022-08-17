//
//  SeedIdentityCreationStatus.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 09/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SeedIdentityCreationStatus: Codable {
    case pending
    case done(UpdateIdentityObject)
    case error(String)
    
    enum CodingKeys: String, CodingKey {
        case status
        case token
        case detail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let status = try container.decode(String.self, forKey: .status)
        switch status {
        case "pending":
            self = .pending
        case "done":
            let wrapperShell = try container.decode(UpdateIdentityObject.self, forKey: .token)
            self = .done(wrapperShell)
        case "error":
            let detail = try container.decode(String.self, forKey: .detail)
            self = .error(detail)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: container,
                debugDescription: "Invalid status, expected 'pending', 'done' or 'error' but got '\(status)'."
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .pending:
            try container.encode("pending", forKey: .status)
        case let .done(wrapper):
            try container.encode("done", forKey: .status)
            try container.encode(wrapper, forKey: .token)
        case let .error(details):
            try container.encode("error", forKey: .status)
            try container.encode(details, forKey: .detail)
        }
    }
}

struct UpdateIdentityObject: Codable {
    let identityObject: ObjectWrapper<SeedIdentityObject>
}
