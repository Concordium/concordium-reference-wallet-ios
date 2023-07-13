import Foundation

struct ContractUpdateParams: Decodable {
    var schema: Schema
    let type: TransferType
    let sender: String
    let payload: ContractUpdatePayload
    
    enum CodingKeys: String, CodingKey {
        case schema, type, sender, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode 'type' field into TransferType.
        let typeStr = try container.decode(String.self, forKey: .type)
        if typeStr == "Update" {
            // For backwards compatibility with older versions of @concordium/wallet-connectors.
            type = TransferType.contractUpdate
        } else if let t = TransferType(rawValue: typeStr) {
            type = t
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid transaction type '\(typeStr)'")
        }
        
        // Decode sender and payload.
        sender = try container.decode(String.self, forKey: .sender)
        let payloadData = try Data(container.decode(String.self, forKey: .payload).utf8)
        payload = try JSONDecoder().decode(ContractUpdatePayload.self, from: payloadData)

        // Attempt to decode schema from schema object, falling back to legacy base64 encoded module schema.
        if let s = try? container.decode(Schema.self, forKey: .schema) {
            schema = s
        } else {
            guard let schemaValueBase64 = try container.decodeIfPresent(String.self, forKey: .schema) else {
                schema = .empty
                return
            }
            if let data = Data(base64Encoded: schemaValueBase64) {
                schema = .moduleSchema(value: data, version: nil)
            } else {
                // Invalid Base64 encoding.
                throw WalletConnectError.schemaError(.invalidBase64(schemaValueBase64))
            }
        }
    }
}
