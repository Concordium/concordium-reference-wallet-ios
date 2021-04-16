// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let credentialPublicKeys = try CredentialPublicKeys(json)

import Foundation

// MARK: - CredentialPublicKeys
struct CredentialPublicKeys: Codable {
    let keys: [Int: SchemeVerifyKey]
    let threshold: Int

    enum CodingKeys: String, CodingKey {
        case keys = "keys"
        case threshold
    }
}

// MARK: CredentialPublicKeys convenience initializers and mutators

extension CredentialPublicKeys {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CredentialPublicKeys.self, from: data)
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
        keys: [Int: SchemeVerifyKey]? = nil,
        threshold: Int? = nil
    ) -> CredentialPublicKeys {
        return CredentialPublicKeys(
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
