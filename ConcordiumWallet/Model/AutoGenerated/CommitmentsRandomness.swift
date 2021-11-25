// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commitmentsRandomness = try CommitmentsRandomness(json)

import Foundation

// MARK: - CommitmentsRandomness
struct CommitmentsRandomness: Codable {
    let attributesRand: [String: String]
    let credCounterRand, idCredSECRand, maxAccountsRand, prfRand: String

    enum CodingKeys: String, CodingKey {
        case attributesRand, credCounterRand
        case idCredSECRand = "idCredSecRand"
        case maxAccountsRand, prfRand
    }
}

// MARK: CommitmentsRandomness convenience initializers and mutators

extension CommitmentsRandomness {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CommitmentsRandomness.self, from: data)
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
        attributesRand: [String: String]? = nil,
        credCounterRand: String? = nil,
        idCredSECRand: String? = nil,
        maxAccountsRand: String? = nil,
        prfRand: String? = nil
    ) -> CommitmentsRandomness {
        return CommitmentsRandomness(
            attributesRand: attributesRand ?? self.attributesRand,
            credCounterRand: credCounterRand ?? self.credCounterRand,
            idCredSECRand: idCredSECRand ?? self.idCredSECRand,
            maxAccountsRand: maxAccountsRand ?? self.maxAccountsRand,
            prfRand: prfRand ?? self.prfRand
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
