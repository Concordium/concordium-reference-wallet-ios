// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let publicKeys = try PublicKeys(json)

import Foundation

// MARK: - PublicKeys
struct PublicKeys: Codable {
    let keys: [String: SchemeVerifyKey]
    let threshold: Int
}

// MARK: PublicKeys convenience initializers and mutators

extension PublicKeys {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PublicKeys.self, from: data)
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
        keys: [String: SchemeVerifyKey]? = nil,
        threshold: Int? = nil
    ) -> PublicKeys {
        return PublicKeys(
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
