// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let gASRewards = try GASRewards(json)

import Foundation

// MARK: - GASRewards
struct GASRewards: Codable {
    let chainUpdate: Double
    let accountCreation: Double
    let baker: Double

    enum CodingKeys: String, CodingKey {
        case chainUpdate = "chainUpdate"
        case accountCreation = "accountCreation"
        case baker = "baker"
    }
}

// MARK: GASRewards convenience initializers and mutators

extension GASRewards {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GASRewards.self, from: data)
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
        chainUpdate: Double? = nil,
        accountCreation: Double? = nil,
        baker: Double? = nil
    ) -> GASRewards {
        return GASRewards(
            chainUpdate: chainUpdate ?? self.chainUpdate,
            accountCreation: accountCreation ?? self.accountCreation,
            baker: baker ?? self.baker
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
