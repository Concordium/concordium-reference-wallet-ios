// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let leverageBound = try LeverageBound(json)

import Foundation

// MARK: - LeverageBound
struct LeverageBound: Codable {
    let denominator: Int
    let numerator: Int

    enum CodingKeys: String, CodingKey {
        case denominator = "denominator"
        case numerator = "numerator"
    }
}

// MARK: LeverageBound convenience initializers and mutators

extension LeverageBound {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LeverageBound.self, from: data)
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
        denominator: Int? = nil,
        numerator: Int? = nil
    ) -> LeverageBound {
        return LeverageBound(
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
