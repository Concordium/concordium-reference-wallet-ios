// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let submissionStatus = try SubmissionStatus(json)

import Foundation

// MARK: - SubmissionStatus
struct SubmissionStatus: Codable {
    let status: SubmissionStatusEnum
    let amount: String?
    let sender: String?
    let to: String?
    let transactionHash: String?
    let cost: String?
    let outcome: OutcomeEnum?
    let blockHashes: [String]?
    let rejectReason: String?
    let newSelfEncryptedAmount: String?
    let encryptedAmount: String?
    let aggregatedIndex: Int?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case amount = "amount"
        case sender = "sender"
        case to = "to"
        case transactionHash = "transactionHash"
        case cost = "cost"
        case outcome = "outcome"
        case blockHashes = "blockHashes"
        case rejectReason = "rejectReason"
        case newSelfEncryptedAmount = "newSelfEncryptedAmount"
        case encryptedAmount = "encryptedAmount"
        case aggregatedIndex = "aggregatedIndex"
    }
}

// MARK: SubmissionStatus convenience initializers and mutators

extension SubmissionStatus {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SubmissionStatus.self, from: data)
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
        status: SubmissionStatusEnum? = nil,
        amount: String?? = nil,
        sender: String?? = nil,
        to: String?? = nil,
        transactionHash: String?? = nil,
        cost: String?? = nil,
        outcome: OutcomeEnum?? = nil,
        blockHashes: [String]?? = nil,
        rejectReason: String?? = nil,
        newSelfEncryptedAmount: String?? = nil,
        encryptedAmount: String?? = nil,
        aggregatedIndex: Int?? = nil
    ) -> SubmissionStatus {
        return SubmissionStatus(
            status: status ?? self.status,
            amount: amount ?? self.amount,
            sender: sender ?? self.sender,
            to: to ?? self.to,
            transactionHash: transactionHash ?? self.transactionHash,
            cost: cost ?? self.cost,
            outcome: outcome ?? self.outcome,
            blockHashes: blockHashes ?? self.blockHashes,
            rejectReason: rejectReason ?? self.rejectReason,
            newSelfEncryptedAmount: newSelfEncryptedAmount ?? self.newSelfEncryptedAmount,
            encryptedAmount: encryptedAmount ?? self.encryptedAmount,
            aggregatedIndex: aggregatedIndex ?? self.aggregatedIndex
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
