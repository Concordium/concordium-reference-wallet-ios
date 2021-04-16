// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let value = try CredentialValue(json)

import Foundation

// MARK: - CredentialValue
struct CredentialValue: Codable {
    let credential: ValueCredential
    let messageExpiry: Int
}

// MARK: CredentialValue convenience initializers and mutators

extension CredentialValue {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CredentialValue.self, from: data)
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
        credential: ValueCredential? = nil,
        messageExpiry: Int? = nil
    ) -> CredentialValue {
        return CredentialValue(
            credential: credential ?? self.credential,
            messageExpiry: messageExpiry ?? self.messageExpiry
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
