//
//  CredentialResponse.swift
//  ConcordiumWallet
//
//  Created by Concordium on 17/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - Credential
struct CredentialResponse: Codable {
    let v: Int
    let value: CredentialValue
}

// MARK: Credential convenience initializers and mutators

extension CredentialResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CredentialResponse.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        v: Int? = nil,
        value: CredentialValue? = nil
    ) -> CredentialResponse {
        return CredentialResponse(
            v: v ?? self.v,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }

    func toCredential() -> Credential {
        return Credential(v: v, value: value)
        // return Credential(v: v, value: CredentialValue(credential: value, messageExpiry: 0))
    }
}
