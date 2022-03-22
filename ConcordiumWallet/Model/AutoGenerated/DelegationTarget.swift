// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let delegationTarget = try DelegationTarget(json)

import Foundation

// MARK: - DelegationTarget
struct DelegationTarget: Codable {
    let type: String?
    let targetBaker: Int?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case targetBaker = "targetBaker"
    }
}

// MARK: DelegationTarget convenience initializers and mutators

extension DelegationTarget {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DelegationTarget.self, from: data)
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
        type: String?? = nil,
        targetBaker: Int?? = nil
    ) -> DelegationTarget {
        return DelegationTarget(
            type: type ?? self.type,
            targetBaker: targetBaker ?? self.targetBaker
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
