// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let transaction = try Transaction(json)

import Foundation

// MARK: - Transaction
struct Transaction: Codable {
    let blockTime: Double?
    let origin: Origin?
    let energy: Int?
    let blockHash: String
    let cost: String?
    let subtotal: String?
    let transactionHash: String?
    let details: Details
    let total: String?
    let id: Int?
    let encrypted: Encrypted?

    enum CodingKeys: String, CodingKey {
        case blockTime = "blockTime"
        case origin = "origin"
        case energy = "energy"
        case blockHash = "blockHash"
        case cost = "cost"
        case subtotal = "subtotal"
        case transactionHash = "transactionHash"
        case details = "details"
        case total = "total"
        case id = "id"
        case encrypted = "encrypted"
    }
}

// MARK: Transaction convenience initializers and mutators

extension Transaction {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Transaction.self, from: data)
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
        blockTime: Double?? = nil,
        origin: Origin?? = nil,
        energy: Int?? = nil,
        blockHash: String? = nil,
        cost: String?? = nil,
        subtotal: String?? = nil,
        transactionHash: String?? = nil,
        details: Details? = nil,
        total: String?? = nil,
        id: Int?? = nil,
        encrypted: Encrypted?? = nil
    ) -> Transaction {
        return Transaction(
            blockTime: blockTime ?? self.blockTime,
            origin: origin ?? self.origin,
            energy: energy ?? self.energy,
            blockHash: blockHash ?? self.blockHash,
            cost: cost ?? self.cost,
            subtotal: subtotal ?? self.subtotal,
            transactionHash: transactionHash ?? self.transactionHash,
            details: details ?? self.details,
            total: total ?? self.total,
            id: id ?? self.id,
            encrypted: encrypted ?? self.encrypted
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
