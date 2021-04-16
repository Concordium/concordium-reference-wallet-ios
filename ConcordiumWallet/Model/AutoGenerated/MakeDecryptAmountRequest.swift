// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeDecryptAmountRequest = try MakeDecryptAmountRequest(json)

import Foundation

// MARK: - MakeDecryptAmountRequest
struct MakeDecryptAmountRequest: Codable {
    let encryptedAmount: String?
    let encryptionSecretKey: String?

    enum CodingKeys: String, CodingKey {
        case encryptedAmount = "encryptedAmount"
        case encryptionSecretKey = "encryptionSecretKey"
    }
}

// MARK: MakeDecryptAmountRequest convenience initializers and mutators

extension MakeDecryptAmountRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeDecryptAmountRequest.self, from: data)
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
        encryptedAmount: String?? = nil,
        encryptionSecretKey: String?? = nil
    ) -> MakeDecryptAmountRequest {
        return MakeDecryptAmountRequest(
            encryptedAmount: encryptedAmount ?? self.encryptedAmount,
            encryptionSecretKey: encryptionSecretKey ?? self.encryptionSecretKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
