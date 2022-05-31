// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bakerStakePendingChange = try BakerStakePendingChange(json)

import Foundation

// MARK: - BakerStakePendingChange
struct BakerStakePendingChange: Codable {
    let pendingChangeType: String
    let bakerEquityCapital: String?
    let effectiveTime: String?
    let estimatedChangeTime: String?

    enum CodingKeys: String, CodingKey {
        case pendingChangeType = "pendingChangeType"
        case bakerEquityCapital = "bakerEquityCapital"
        case effectiveTime = "effectiveTime"
        case estimatedChangeTime = "estimatedChangeTime"
    }
}

// MARK: BakerStakePendingChange convenience initializers and mutators

extension BakerStakePendingChange {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BakerStakePendingChange.self, from: data)
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
        pendingChangeType: String? = nil,
        bakerEquityCapital: String?? = nil,
        effectiveTime: String?? = nil,
        estimatedChangeTime: String?? = nil
    ) -> BakerStakePendingChange {
        return BakerStakePendingChange(
            pendingChangeType: pendingChangeType ?? self.pendingChangeType,
            bakerEquityCapital: bakerEquityCapital ?? self.bakerEquityCapital,
            effectiveTime: effectiveTime ?? self.effectiveTime,
            estimatedChangeTime: estimatedChangeTime ?? self.estimatedChangeTime
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
