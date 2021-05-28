//
//  IdentityProviderError.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: - Details
struct IdentityProviderErrorWrapper: Codable {
    let error: IdentityProviderError
}

struct IdentityProviderError: Codable {
    let code, detail: String
}

// MARK: Details convenience initializers and mutators

extension IdentityProviderErrorWrapper {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IdentityProviderErrorWrapper.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
}
