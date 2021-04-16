// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let transferCost = try TransferCost(json)

import Foundation

// MARK: - TransferCost
struct TransferCost: Codable {
    let energy: Int
    let cost: String

    enum CodingKeys: String, CodingKey {
        case energy = "energy"
        case cost = "cost"
    }
}

// MARK: TransferCost convenience initializers and mutators

extension TransferCost {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TransferCost.self, from: data)
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
        energy: Int? = nil,
        cost: String? = nil
    ) -> TransferCost {
        return TransferCost(
            energy: energy ?? self.energy,
            cost: cost ?? self.cost
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
