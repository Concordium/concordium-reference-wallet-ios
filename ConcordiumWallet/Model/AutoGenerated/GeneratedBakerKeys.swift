// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let generatedBakerKeys = try GeneratedBakerKeys(json)

import Foundation

// MARK: - GeneratedBakerKeys
struct GeneratedBakerKeys: Codable {
    let electionVerifyKey: String
    let electionPrivateKey: String
    let signatureVerifyKey: String
    let signatureSignKey: String
    let aggregationVerifyKey: String
    let aggregationSignKey: String

    enum CodingKeys: String, CodingKey {
        case electionVerifyKey = "electionVerifyKey"
        case electionPrivateKey = "electionPrivateKey"
        case signatureVerifyKey = "signatureVerifyKey"
        case signatureSignKey = "signatureSignKey"
        case aggregationVerifyKey = "aggregationVerifyKey"
        case aggregationSignKey = "aggregationSignKey"
    }
}

// MARK: GeneratedBakerKeys convenience initializers and mutators

extension GeneratedBakerKeys {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GeneratedBakerKeys.self, from: data)
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
        electionVerifyKey: String? = nil,
        electionPrivateKey: String? = nil,
        signatureVerifyKey: String? = nil,
        signatureSignKey: String? = nil,
        aggregationVerifyKey: String? = nil,
        aggregationSignKey: String? = nil
    ) -> GeneratedBakerKeys {
        return GeneratedBakerKeys(
            electionVerifyKey: electionVerifyKey ?? self.electionVerifyKey,
            electionPrivateKey: electionPrivateKey ?? self.electionPrivateKey,
            signatureVerifyKey: signatureVerifyKey ?? self.signatureVerifyKey,
            signatureSignKey: signatureSignKey ?? self.signatureSignKey,
            aggregationVerifyKey: aggregationVerifyKey ?? self.aggregationVerifyKey,
            aggregationSignKey: aggregationSignKey ?? self.aggregationSignKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
