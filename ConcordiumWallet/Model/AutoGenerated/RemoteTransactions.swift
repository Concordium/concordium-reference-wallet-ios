// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let remoteTransactions = try RemoteTransactions(json)

import Foundation

// MARK: - RemoteTransactions
struct RemoteTransactions: Codable {
    let transactions: [Transaction]?
    let count: Int?
    let limit: Int?
    let order: String?

    enum CodingKeys: String, CodingKey {
        case transactions = "transactions"
        case count = "count"
        case limit = "limit"
        case order = "order"
    }
}

// MARK: RemoteTransactions convenience initializers and mutators

extension RemoteTransactions {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RemoteTransactions.self, from: data)
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
        transactions: [Transaction]?? = nil,
        count: Int?? = nil,
        limit: Int?? = nil,
        order: String?? = nil
    ) -> RemoteTransactions {
        return RemoteTransactions(
            transactions: transactions ?? self.transactions,
            count: count ?? self.count,
            limit: limit ?? self.limit,
            order: order ?? self.order
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
