// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let iPArDatum = try IPArDatum(json)

import Foundation

// MARK: - IPArDatum
struct IPArDatum: Codable {
    let encPrfKeyShare, proofCOMEncEq: String

    enum CodingKeys: String, CodingKey {
        case encPrfKeyShare
        case proofCOMEncEq = "proofComEncEq"
    }
}

// MARK: IPArDatum convenience initializers and mutators

extension IPArDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IPArDatum.self, from: data)
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
        encPrfKeyShare: String? = nil,
        proofCOMEncEq: String? = nil
    ) -> IPArDatum {
        return IPArDatum(
            encPrfKeyShare: encPrfKeyShare ?? self.encPrfKeyShare,
            proofCOMEncEq: proofCOMEncEq ?? self.proofCOMEncEq
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
