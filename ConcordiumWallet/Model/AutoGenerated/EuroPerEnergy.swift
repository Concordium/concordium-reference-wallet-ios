// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let euroPerEnergy = try EuroPerEnergy(json)

import Foundation

// MARK: - EuroPerEnergy
struct EuroPerEnergy: Codable {
    let denominator: UInt64
    let numerator: UInt64

    enum CodingKeys: String, CodingKey {
        case denominator = "denominator"
        case numerator = "numerator"
    }
}

// MARK: EuroPerEnergy convenience initializers and mutators

extension EuroPerEnergy {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EuroPerEnergy.self, from: data)
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
        denominator: UInt64? = nil,
        numerator: UInt64? = nil
    ) -> EuroPerEnergy {
        return EuroPerEnergy(
            denominator: denominator ?? self.denominator,
            numerator: numerator ?? self.numerator
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
