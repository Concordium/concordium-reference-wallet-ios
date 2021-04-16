// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createTransferRequest = try CreateTransferRequest(json)

import Foundation

// MARK: - CreateTransferRequest
struct CreateTransferRequest: Codable {
    let remaining: String?
    let addedSelfEncryptedAmount: String?
    let signatures: [Int: [Int: String]]
    let transaction: String

    enum CodingKeys: String, CodingKey {
        case remaining = "remaining"
        case addedSelfEncryptedAmount = "addedSelfEncryptedAmount"
        case signatures = "signatures"
        case transaction = "transaction"
    }
}

// MARK: CreateTransferRequest convenience initializers and mutators

extension CreateTransferRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateTransferRequest.self, from: data)
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
        remaining: String? = nil,
        addedSelfEncryptedAmount: String? = nil,
        signatures: [Int: [Int: String]]? = nil,
        transaction: String? = nil
    ) -> CreateTransferRequest {
        return CreateTransferRequest(
            remaining: remaining ?? self.remaining,
            addedSelfEncryptedAmount: addedSelfEncryptedAmount ?? self.addedSelfEncryptedAmount,
            signatures: signatures ?? self.signatures,
            transaction: transaction ?? self.transaction
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
