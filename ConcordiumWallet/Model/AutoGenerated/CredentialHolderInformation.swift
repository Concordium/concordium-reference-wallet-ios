// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let credentialHolderInformation = try CredentialHolderInformation(json)

import Foundation

// MARK: - CredentialHolderInformation
struct CredentialHolderInformation: Codable {
    let idCredSecret: String
}

// MARK: CredentialHolderInformation convenience initializers and mutators

extension CredentialHolderInformation {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CredentialHolderInformation.self, from: data)
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
        idCredSecret: String? = nil
    ) -> CredentialHolderInformation {
        return CredentialHolderInformation(
            idCredSecret: idCredSecret ?? self.idCredSecret
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
