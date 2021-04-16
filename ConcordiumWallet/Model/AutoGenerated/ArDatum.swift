// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let arDatum = try ArDatum(json)

import Foundation

// MARK: - ArDatum
struct ArDatum: Codable {
    let encIDCredPubShare: String

    enum CodingKeys: String, CodingKey {
        case encIDCredPubShare = "encIdCredPubShare"
    }
}

// MARK: ArDatum convenience initializers and mutators

extension ArDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ArDatum.self, from: data)
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
        encIDCredPubShare: String? = nil
    ) -> ArDatum {
        return ArDatum(
            encIDCredPubShare: encIDCredPubShare ?? self.encIDCredPubShare
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
