// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createCredentialRequestCredential = try Credential(json)

import Foundation

// MARK: - Credential
struct Credential: Codable {
    let v: Int
    let value: CredentialValue
}

// MARK: Credential convenience initializers and mutators

extension Credential {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Credential.self, from: data)
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
    ) -> Credential {
        return Credential(
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
}
