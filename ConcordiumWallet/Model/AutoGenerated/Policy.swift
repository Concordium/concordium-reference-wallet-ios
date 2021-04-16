// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let policy = try Policy(json)

import Foundation

// MARK: - Policy
struct Policy: Codable {
    let createdAt: String
    let revealedAttributes: [String: String]
    let validTo: String
}

// MARK: Policy convenience initializers and mutators

extension Policy {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Policy.self, from: data)
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
        createdAt: String? = nil,
        revealedAttributes: [String: String]? = nil,
        validTo: String? = nil
    ) -> Policy {
        return Policy(
            createdAt: createdAt ?? self.createdAt,
            revealedAttributes: revealedAttributes ?? self.revealedAttributes,
            validTo: validTo ?? self.validTo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
