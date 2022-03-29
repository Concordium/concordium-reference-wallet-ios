// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mintDistribution = try MintDistribution(json)

import Foundation

// MARK: - MintDistribution
struct MintDistribution: Codable {
    let bakingReward: Double
    let finalizationReward: Double

    enum CodingKeys: String, CodingKey {
        case bakingReward = "bakingReward"
        case finalizationReward = "finalizationReward"
    }
}

// MARK: MintDistribution convenience initializers and mutators

extension MintDistribution {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MintDistribution.self, from: data)
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
        bakingReward: Double? = nil,
        finalizationReward: Double? = nil
    ) -> MintDistribution {
        return MintDistribution(
            bakingReward: bakingReward ?? self.bakingReward,
            finalizationReward: finalizationReward ?? self.finalizationReward
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
