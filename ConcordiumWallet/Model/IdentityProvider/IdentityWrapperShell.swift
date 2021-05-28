//
//  IdentityWrapperShell.swift
//  ConcordiumWallet
//
//  Concordium on 17/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

struct IdentityWrapperShell: Codable {
    let accountAddress: String
    let credential: CredentialResponse
    let identityObject: IdentityObjectWrapper
}

extension IdentityWrapperShell {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IdentityWrapperShell.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
}
