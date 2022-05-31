// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let pendingChange = try PendingChange(json)

import Foundation

// MARK: - PendingChange
struct PendingChange: Codable {
    let change: String
    let newStake: String?
    let effectiveTime: String?
    let estimatedChangeTime: String?

    enum CodingKeys: String, CodingKey {
        case change = "change"
        case newStake = "newStake"
        case effectiveTime = "effectiveTime"
        case estimatedChangeTime = "estimatedChangeTime"
    }
}

// MARK: PendingChange convenience initializers and mutators

extension PendingChange {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PendingChange.self, from: data)
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
        change: String? = nil,
        newStake: String?? = nil,
        effectiveTime: String?? = nil,
        estimatedChangeTime: String?? = nil
    ) -> PendingChange {
        return PendingChange(
            change: change ?? self.change,
            newStake: newStake ?? self.newStake,
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
