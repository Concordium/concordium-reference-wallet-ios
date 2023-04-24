import Foundation

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

extension Encodable {
    func encodeToString(encoder: JSONEncoder = newJSONEncoder(), encoding: String.Encoding = .utf8) throws -> String {
        guard let string = String(data: try encoder.encode(self), encoding: encoding) else {
            throw GeneralError.unexpectedNullValue
        }
        
        return string
    }
}

extension Decodable {
    static func decodeFromSring(
        _ string: String,
        decoder: JSONDecoder = newJSONDecoder(),
        encoding: String.Encoding = .utf8
    ) throws -> Self {
        guard let data = string.data(using: encoding) else {
            throw GeneralError.unexpectedNullValue
        }
        
        return try decoder.decode(Self.self, from: data)
    }
}
