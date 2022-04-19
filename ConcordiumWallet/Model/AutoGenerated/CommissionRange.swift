// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commissionRange = try CommissionRange(json)

import Foundation

// MARK: - CommissionRange
struct CommissionRange: Codable {
    let max: Double
    let min: Double

    enum CodingKeys: String, CodingKey {
        case max = "max"
        case min = "min"
    }
}

// MARK: CommissionRange convenience initializers and mutators

extension CommissionRange {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CommissionRange.self, from: data)
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
        max: Double? = nil,
        min: Double? = nil
    ) -> CommissionRange {
        return CommissionRange(
            max: max ?? self.max,
            min: min ?? self.min
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
