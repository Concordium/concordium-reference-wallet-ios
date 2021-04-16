// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let origin = try Origin(json)

import Foundation

// MARK: - Origin
struct Origin: Codable {
    let type: OriginTypeEnum?
    let address: String?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case address = "address"
    }
}

// MARK: Origin convenience initializers and mutators

extension Origin {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Origin.self, from: data)
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
        type: OriginTypeEnum?? = nil,
        address: String?? = nil
    ) -> Origin {
        return Origin(
            type: type ?? self.type,
            address: address ?? self.address
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
