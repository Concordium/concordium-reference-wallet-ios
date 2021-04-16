// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountKeys = try AccountKeys(json)

import Foundation

// MARK: - AccountKeys
struct AccountKeys: Codable {
    let keys: [Int: KeyList]
    let threshold: Int
}

// MARK: AccountKeys convenience initializers and mutators

extension AccountKeys {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountKeys.self, from: data)
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
        keys: [Int: KeyList]? = nil,
        threshold: Int? = nil
    ) -> AccountKeys {
        return AccountKeys(
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
