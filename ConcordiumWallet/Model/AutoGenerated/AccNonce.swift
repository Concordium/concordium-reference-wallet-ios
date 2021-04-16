// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accNonce = try AccNonce(json)

import Foundation

// MARK: - AccNonce
struct AccNonce: Codable {
    let nonce: Int
    let allFinal: Bool

    enum CodingKeys: String, CodingKey {
        case nonce = "nonce"
        case allFinal = "allFinal"
    }
}

// MARK: AccNonce convenience initializers and mutators

extension AccNonce {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccNonce.self, from: data)
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
        nonce: Int? = nil,
        allFinal: Bool? = nil
    ) -> AccNonce {
        return AccNonce(
            nonce: nonce ?? self.nonce,
            allFinal: allFinal ?? self.allFinal
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
