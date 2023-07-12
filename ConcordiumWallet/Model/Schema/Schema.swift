import Foundation

enum Schema: Codable {
    case moduleSchema(value: Data, version: SchemaVersion?)
    case typeSchema(value: Data)
    
    enum CodingKeys: String, CodingKey {
        case type, value, version
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .moduleSchema(value: value, version: version):
            try container.encode("module", forKey: .type)
            try container.encode(value, forKey: .value)
            try container.encodeIfPresent(version, forKey: .version)
        case let .typeSchema(value: value):
            try container.encode("parameter", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var type = try? container.decode(SchemaType.self, forKey: .type)
        if type == nil, let brokenType = try? container.decode(SchemaTypeBroken.self, forKey: .type) {
            switch brokenType {
            case .moduleSchema: type = .moduleSchema
            case .typeSchema: type = .typeSchema
            }
        }
        guard let type else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "no valid 'type' value")
        }
        let value = try Schema.decodeValue(container)
        switch type {
        case .moduleSchema:
            let version = try? container.decode(SchemaVersion.self, forKey: .version)
            self = .moduleSchema(value: value, version: version)
        case .typeSchema:
            self = .typeSchema(value: value)
        }
    }
    
    static func decodeValue(_ container: KeyedDecodingContainer<Schema.CodingKeys>) throws -> Data {
        // First attempt to decode schema as base64-encoded string.
        if let rawValueBase64 = try? container.decode(String.self, forKey: .value) {
            if let data = Data(base64Encoded: fixedBase64Format(for: rawValueBase64)) {
                return data
            }
            // Invalid Base64 encoding.
            throw WalletConnectError.schemaError(.invalidBase64(rawValueBase64))
        }
        // If it fails, attempt to decode as JavaScript's Buffer.
        if let buffer = try? container.decode(SchemaValueBufferBroken.self, forKey: .value) {
            return Data(buffer.data)
        }
        // Both attempts failed.
        throw WalletConnectError.schemaError(.unknownFormat)
    }
    
    var version: SchemaVersion? {
        switch self {
        case let .moduleSchema(value: _, version: version):
            return version
        default: return nil
        }
    }

    /// Returns the fixed base64 format of the string.
    /// This method is used to ensure that a string representing base64-encoded data has a proper format. In some cases,
    /// when working with certain schemas or data sources, the base64 string returned may not adhere to the standard format.
    /// This method addresses that issue by adding padding characters ('=') to the end of the string if its length is not a multiple of 4, thus making it a valid base64 format.
    private static func fixedBase64Format(for string: String) -> String {
        let offset = string.count % 4
        guard offset != 0 else { return string }
        return string.padding(toLength: string.count + 4 - offset, withPad: "=", startingAt: 0)
    }
}

enum SchemaType: String, Decodable {
    case moduleSchema = "module"
    case typeSchema = "parameter"
}

/// Schema value format used by @concordium/wallet-connectors v0.3.x.
/// JSON format: {type: "Buffer", data: [bytes]}
/// The format is incorrect and only supported for backwards compatibility.
/// The correct type is a base64-encoded string.
struct SchemaValueBufferBroken: Codable {
    enum ValueType: String, Codable {
        case buffer = "Buffer"
    }
    let type: ValueType
    let data: [UInt8]
}

/// Schema type keys used by @concordium/wallet-connectors v0.3.x.
/// The format is incorrect and only supported for backwards compatibility.
/// The correct keys are contained in the type `SchemaType` above.
enum SchemaTypeBroken: String, Decodable {
    case moduleSchema = "ModuleSchema"
    case typeSchema = "TypeSchema"
}
