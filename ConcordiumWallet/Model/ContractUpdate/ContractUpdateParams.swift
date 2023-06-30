import Foundation

struct ContractUpdateParams: Decodable {
    let schema: Schema
    let type: TransferType
    let sender: String
    let payload: ContractUpdatePayload
    
    enum CodingKeys: String, CodingKey {
        case schema, type, sender, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(TransferType.self, forKey: .type)
        sender = try container.decode(String.self, forKey: .sender)
        let payloadData = try Data(container.decode(String.self, forKey: .payload).utf8)
        payload = try JSONDecoder().decode(ContractUpdatePayload.self, from: payloadData)

        // Attempt to decode schema from schema object, falling back to legacy base64 encoded module schema.
        if let s = try? container.decode(Schema.self, forKey: .schema) {
            schema = s
        } else {
            let schemaValueBase64 = try container.decode(String.self, forKey: .schema)
            if let data = Data(base64Encoded: schemaValueBase64) {
                schema = .moduleSchema(value: data, version: nil)
            } else {
                // Invalid Base64 encoding.
                throw WalletConnectError.schemaError(.invalidBase64(schemaValueBase64))
            }
        }
    }
}
