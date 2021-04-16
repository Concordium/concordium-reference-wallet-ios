// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let schedule = try Schedule(json)

import Foundation

// MARK: - Schedule
struct Schedule: Codable {
    let amount: String?
    let transactions: [String]?
    let timestamp: Int?

    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case transactions = "transactions"
        case timestamp = "timestamp"
    }
}

// MARK: Schedule convenience initializers and mutators

extension Schedule {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Schedule.self, from: data)
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
        amount: String?? = nil,
        transactions: [String]?? = nil,
        timestamp: Int?? = nil
    ) -> Schedule {
        return Schedule(
            amount: amount ?? self.amount,
            transactions: transactions ?? self.transactions,
            timestamp: timestamp ?? self.timestamp
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
