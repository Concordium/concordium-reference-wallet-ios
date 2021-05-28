//
//  KeyList.swift
//  ConcordiumWallet
//
//  Created by Concordium on 15/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

struct KeyList: Codable {
    let keys: [Int: Key]
    let threshold: Int
}

extension KeyList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(KeyList.self, from: data)
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
        keys: [Int: Key]? = nil,
        threshold: Int? = nil
    ) -> KeyList {
        return KeyList(
            keys: keys ?? self.keys,
            threshold: threshold ?? self.threshold
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
