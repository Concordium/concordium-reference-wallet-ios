//
//  SchemeVerifyKey.swift
//  ConcordiumWallet
//
//  Created by Concordium on 15/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - SchemeVerifyKey
struct SchemeVerifyKey: Codable {
    let schemeID, verifyKey: String

    enum CodingKeys: String, CodingKey {
        case schemeID = "schemeId"
        case verifyKey
    }
}

// MARK: SchemeVerifyKey convenience initializers and mutators

extension SchemeVerifyKey {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SchemeVerifyKey.self, from: data)
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
        schemeID: String? = nil,
        verifyKey: String? = nil
    ) -> SchemeVerifyKey {
        return SchemeVerifyKey(
            schemeID: schemeID ?? self.schemeID,
            verifyKey: verifyKey ?? self.verifyKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
