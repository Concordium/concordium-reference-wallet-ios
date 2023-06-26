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
        // TODO: Check what the version should be if that's a string
        if let schema = try? container.decode(Schema.self, forKey: .schema) {
            self.schema = schema
        } else {
            schema = .moduleSchema(value: try container.decode(String.self, forKey: .schema), version: nil)
        }
    }
}
