// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let details = try Details(json)

import Foundation

// MARK: - Details
struct Details: Codable {
    let transferDestination: String?
    let memo: String?
    let transferAmount: String?
    let events: [String]?
    let outcome: OutcomeEnum
    let type: String?
    let detailsDescription: String?
    let transferSource: String?
    let newIndex: Int?
    let inputEncryptedAmount: String?
    let newSelfEncryptedAmount: String?
    let encryptedAmount: String?
    let aggregatedIndex: Int?
    let amountSubtracted: String?
    let rejectReason: String?
    let amountAdded: String?

    enum CodingKeys: String, CodingKey {
        case transferDestination = "transferDestination"
        case memo = "memo"
        case transferAmount = "transferAmount"
        case events = "events"
        case outcome = "outcome"
        case type = "type"
        case detailsDescription = "description"
        case transferSource = "transferSource"
        case newIndex = "newIndex"
        case inputEncryptedAmount = "inputEncryptedAmount"
        case newSelfEncryptedAmount = "newSelfEncryptedAmount"
        case encryptedAmount = "encryptedAmount"
        case aggregatedIndex = "aggregatedIndex"
        case amountSubtracted = "amountSubtracted"
        case rejectReason = "rejectReason"
        case amountAdded = "amountAdded"
    }
}

// MARK: Details convenience initializers and mutators

extension Details {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Details.self, from: data)
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
        transferDestination: String?? = nil,
        memo: String?? = nil,
        transferAmount: String?? = nil,
        events: [String]?? = nil,
        outcome: OutcomeEnum? = nil,
        type: String?? = nil,
        detailsDescription: String?? = nil,
        transferSource: String?? = nil,
        newIndex: Int?? = nil,
        inputEncryptedAmount: String?? = nil,
        newSelfEncryptedAmount: String?? = nil,
        encryptedAmount: String?? = nil,
        aggregatedIndex: Int?? = nil,
        amountSubtracted: String?? = nil,
        rejectReason: String?? = nil,
        amountAdded: String?? = nil
    ) -> Details {
        return Details(
            transferDestination: transferDestination ?? self.transferDestination,
            memo: memo ?? self.memo,
            transferAmount: transferAmount ?? self.transferAmount,
            events: events ?? self.events,
            outcome: outcome ?? self.outcome,
            type: type ?? self.type,
            detailsDescription: detailsDescription ?? self.detailsDescription,
            transferSource: transferSource ?? self.transferSource,
            newIndex: newIndex ?? self.newIndex,
            inputEncryptedAmount: inputEncryptedAmount ?? self.inputEncryptedAmount,
            newSelfEncryptedAmount: newSelfEncryptedAmount ?? self.newSelfEncryptedAmount,
            encryptedAmount: encryptedAmount ?? self.encryptedAmount,
            aggregatedIndex: aggregatedIndex ?? self.aggregatedIndex,
            amountSubtracted: amountSubtracted ?? self.amountSubtracted,
            rejectReason: rejectReason ?? self.rejectReason,
            amountAdded: amountAdded ?? self.amountAdded
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
