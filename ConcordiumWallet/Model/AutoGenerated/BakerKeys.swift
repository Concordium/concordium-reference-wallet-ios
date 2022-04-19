// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bakerKeys = try BakerKeys(json)

import Foundation

// MARK: - BakerKeys
struct BakerKeys: Codable {
    let aggregationSignKey: String?
    let aggregationVerifyKey: String?
    let electionPrivateKey: String?
    let electionVerifyKey: String?
    let signatureSignKey: String?
    let signatureVerifyKey: String?

    enum CodingKeys: String, CodingKey {
        case aggregationSignKey = "aggregationSignKey"
        case aggregationVerifyKey = "aggregationVerifyKey"
        case electionPrivateKey = "electionPrivateKey"
        case electionVerifyKey = "electionVerifyKey"
        case signatureSignKey = "signatureSignKey"
        case signatureVerifyKey = "signatureVerifyKey"
    }
}

// MARK: BakerKeys convenience initializers and mutators

extension BakerKeys {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BakerKeys.self, from: data)
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
        aggregationSignKey: String?? = nil,
        aggregationVerifyKey: String?? = nil,
        electionPrivateKey: String?? = nil,
        electionVerifyKey: String?? = nil,
        signatureSignKey: String?? = nil,
        signatureVerifyKey: String?? = nil
    ) -> BakerKeys {
        return BakerKeys(
            aggregationSignKey: aggregationSignKey ?? self.aggregationSignKey,
            aggregationVerifyKey: aggregationVerifyKey ?? self.aggregationVerifyKey,
            electionPrivateKey: electionPrivateKey ?? self.electionPrivateKey,
            electionVerifyKey: electionVerifyKey ?? self.electionVerifyKey,
            signatureSignKey: signatureSignKey ?? self.signatureSignKey,
            signatureVerifyKey: signatureVerifyKey ?? self.signatureVerifyKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
