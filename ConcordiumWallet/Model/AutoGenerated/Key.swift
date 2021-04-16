// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let key = try Key(json)

import Foundation

// MARK: - Key
struct Key: Codable {
    let signKey: String?
    let verifyKey: String?

    enum CodingKeys: String, CodingKey {
        case signKey = "signKey"
        case verifyKey = "verifyKey"
    }
}

// MARK: Key convenience initializers and mutators

extension Key {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Key.self, from: data)
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
        signKey: String?? = nil,
        verifyKey: String?? = nil
    ) -> Key {
        return Key(
            signKey: signKey ?? self.signKey,
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
