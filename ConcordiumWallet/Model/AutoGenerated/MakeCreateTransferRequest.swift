// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeCreateTransferRequest = try MakeCreateTransferRequest(json)

import Foundation

// MARK: - MakeCreateTransferRequest
struct MakeCreateTransferRequest: Codable {
    let from: String?
    let to: String?
    let expiry: Int?
    let nonce: Int?
    let keys: AccountKeys?
    let energy: Int?
    let amount: String?
    let global: Global?
    let senderSecretKey: String?
    let inputEncryptedAmount: InputEncryptedAmount?
    let receiverPublicKey: String?

    enum CodingKeys: String, CodingKey {
        case from = "from"
        case to = "to"
        case expiry = "expiry"
        case nonce = "nonce"
        case keys = "keys"
        case energy = "energy"
        case amount = "amount"
        case global = "global"
        case senderSecretKey = "senderSecretKey"
        case inputEncryptedAmount = "inputEncryptedAmount"
        case receiverPublicKey = "receiverPublicKey"
    }
}

// MARK: MakeCreateTransferRequest convenience initializers and mutators

extension MakeCreateTransferRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeCreateTransferRequest.self, from: data)
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
        from: String?? = nil,
        to: String?? = nil,
        expiry: Int?? = nil,
        nonce: Int?? = nil,
        keys: AccountKeys?? = nil,
        energy: Int?? = nil,
        amount: String?? = nil,
        global: Global?? = nil,
        senderSecretKey: String?? = nil,
        inputEncryptedAmount: InputEncryptedAmount?? = nil,
        receiverPublicKey: String?? = nil
    ) -> MakeCreateTransferRequest {
        return MakeCreateTransferRequest(
            from: from ?? self.from,
            to: to ?? self.to,
            expiry: expiry ?? self.expiry,
            nonce: nonce ?? self.nonce,
            keys: keys ?? self.keys,
            energy: energy ?? self.energy,
            amount: amount ?? self.amount,
            global: global ?? self.global,
            senderSecretKey: senderSecretKey ?? self.senderSecretKey,
            inputEncryptedAmount: inputEncryptedAmount ?? self.inputEncryptedAmount,
            receiverPublicKey: receiverPublicKey ?? self.receiverPublicKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
