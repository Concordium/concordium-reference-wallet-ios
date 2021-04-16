// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let encrypted = try Encrypted(json)

import Foundation

// MARK: - Encrypted
struct Encrypted: Codable {
    let newStartIndex: Int?
    let newSelfEncryptedAmount: String?
    let encryptedAmount: String?
    let newIndex: Int?

    enum CodingKeys: String, CodingKey {
        case newStartIndex = "newStartIndex"
        case newSelfEncryptedAmount = "newSelfEncryptedAmount"
        case encryptedAmount = "encryptedAmount"
        case newIndex = "newIndex"
    }
}

// MARK: Encrypted convenience initializers and mutators

extension Encrypted {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Encrypted.self, from: data)
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
        newStartIndex: Int?? = nil,
        newSelfEncryptedAmount: String?? = nil,
        encryptedAmount: String?? = nil,
        newIndex: Int?? = nil
    ) -> Encrypted {
        return Encrypted(
            newStartIndex: newStartIndex ?? self.newStartIndex,
            newSelfEncryptedAmount: newSelfEncryptedAmount ?? self.newSelfEncryptedAmount,
            encryptedAmount: encryptedAmount ?? self.encryptedAmount,
            newIndex: newIndex ?? self.newIndex
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
