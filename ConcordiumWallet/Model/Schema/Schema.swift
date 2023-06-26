import Foundation

struct SchemaValue: Codable {
    let data: [UInt8]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([UInt8].self, forKey: .data)
    }
}

struct SchemaValueBuffer: Codable {
    
    enum ValueType: String, Codable {
        case buffer = "Buffer"
    }
    let type: ValueType
    let data: [UInt8]
}

enum Schema: Decodable {
    
    case moduleSchema(value: [UInt8], version: SchemaVersion?)
    case typeSchema(value: [UInt8])

    enum CodingKeys: String, CodingKey {
        case type, value, version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SchemaType.self, forKey: .type)
        var value: [UInt8]?
        if let buffer = try? container.decode(SchemaValueBuffer.self, forKey: .value) {
             value = buffer.data
        } else {
           let valueBase64 = try container.decode(String.self, forKey: .value)
        }
        switch type {
        case .moduleSchema:
            let version = try? container.decode(SchemaVersion.self, forKey: .version)
            self = .moduleSchema(value: value, version: version)
        case .parameterSchema:
            self = .typeSchema(value: value)
        }
    }
}
