// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeCreateTransferRequest = try MakeCreateTransferRequest(json)

import Foundation

enum Payload: Codable {
    case contractUpdatePayload(ContractUpdatePayload)

    enum CodingKeys: CodingKey {
        case payload
        case amount
        case address
        case receiveName
        case maxContractExecutionEnergy
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            let amount = try container.decode(String.self, forKey: .amount)
            let address = try container.decode(ContractAddress.self, forKey: .message)
            let receiveName = try container.decode(String.self, forKey: .receiveName)
            let energy = try container.decode(Int.self, forKey: .maxContractExecutionEnergy)
            self = .contractUpdatePayload(
                .init(
                amount: amount,
                address: address,
                receiveName: receiveName,
                maxContractExecutionEnergy: energy,
                message: message
                )
            )
        } else {
            throw DecodingError.dataCorruptedError(forKey: .message, in: container, debugDescription: "failed to decode value for key message. Not a vaild payload.")
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .contractUpdatePayload(payload):
            try payload.encode(to: encoder)
        }
    }
}

// MARK: - MakeCreateTransferRequest

struct MakeCreateTransferRequest: Codable {
    let from: String?
    let to: String?
    let expiry: Int?
    let nonce: Int?
    let memo: String?
    let capital: String?
    let restakeEarnings: Bool?
    let delegationTarget: DelegationTarget?
    let openStatus: String?
    let metadataURL: String?
    let transactionFeeCommission: String?
    let bakingRewardCommission: String?
    let finalizationRewardCommission: Double?
    let bakerKeys: GeneratedBakerKeys?
    let keys: AccountKeys?
    let energy: Int?
    let amount: String?
    let global: Global?
    let senderSecretKey: String?
    let inputEncryptedAmount: InputEncryptedAmount?
    let receiverPublicKey: String?
    let type: String?
    let payload: Payload?

    enum CodingKeys: String, CodingKey {
        case from = "from"
        case to = "to"
        case expiry = "expiry"
        case nonce = "nonce"
        case memo = "memo"
        case capital = "capital"
        case restakeEarnings = "restakeEarnings"
        case delegationTarget = "delegationTarget"
        case openStatus = "openStatus"
        case metadataURL = "metadataUrl"
        case transactionFeeCommission = "transactionFeeCommission"
        case bakingRewardCommission = "bakingRewardCommission"
        case finalizationRewardCommission = "finalizationRewardCommission"
        case bakerKeys = "bakerKeys"
        case keys = "keys"
        case energy = "energy"
        case amount = "amount"
        case global = "global"
        case senderSecretKey = "senderSecretKey"
        case inputEncryptedAmount = "inputEncryptedAmount"
        case receiverPublicKey = "receiverPublicKey"
        case payload
        case type
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
        memo: String?? = nil,
        capital: String?? = nil,
        restakeEarnings: Bool?? = nil,
        delegationTarget: DelegationTarget?? = nil,
        openStatus: String?? = nil,
        metadataURL: String?? = nil,
        transactionFeeCommission: String?? = nil,
        bakingRewardCommission: String?? = nil,
        finalizationRewardCommission: Double?? = nil,
        bakerKeys: GeneratedBakerKeys?? = nil,
        keys: AccountKeys?? = nil,
        energy: Int?? = nil,
        amount: String?? = nil,
        global: Global?? = nil,
        senderSecretKey: String?? = nil,
        inputEncryptedAmount: InputEncryptedAmount?? = nil,
        receiverPublicKey: String?? = nil,
        type: String?? = nil,
        payload: Payload?? = nil
    ) -> MakeCreateTransferRequest {
        return MakeCreateTransferRequest(
            from: from ?? self.from,
            to: to ?? self.to,
            expiry: expiry ?? self.expiry,
            nonce: nonce ?? self.nonce,
            memo: memo ?? self.memo,
            capital: capital ?? self.capital,
            restakeEarnings: restakeEarnings ?? self.restakeEarnings,
            delegationTarget: delegationTarget ?? self.delegationTarget,
            openStatus: openStatus ?? self.openStatus,
            metadataURL: metadataURL ?? self.metadataURL,
            transactionFeeCommission: transactionFeeCommission ?? self.transactionFeeCommission,
            bakingRewardCommission: bakingRewardCommission ?? self.bakingRewardCommission,
            finalizationRewardCommission: finalizationRewardCommission ?? self.finalizationRewardCommission,
            bakerKeys: bakerKeys ?? self.bakerKeys,
            keys: keys ?? self.keys,
            energy: energy ?? self.energy,
            amount: amount ?? self.amount,
            global: global ?? self.global,
            senderSecretKey: senderSecretKey ?? self.senderSecretKey,
            inputEncryptedAmount: inputEncryptedAmount ?? self.inputEncryptedAmount,
            receiverPublicKey: receiverPublicKey ?? self.receiverPublicKey,
            type: type ?? self.type,
            payload: payload ?? self.payload
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
