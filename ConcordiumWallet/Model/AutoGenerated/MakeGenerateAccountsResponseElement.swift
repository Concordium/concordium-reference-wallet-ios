// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeGenerateAccountsResponseElement = try MakeGenerateAccountsResponseElement(json)

import Foundation

// MARK: - MakeGenerateAccountsResponseElement
struct MakeGenerateAccountsResponseElement: Codable {
    let accountAddress: String
    let encryptionPublicKey: String
    let encryptionSecretKey: String

    enum CodingKeys: String, CodingKey {
        case accountAddress = "accountAddress"
        case encryptionPublicKey = "encryptionPublicKey"
        case encryptionSecretKey = "encryptionSecretKey"
    }
}

// MARK: MakeGenerateAccountsResponseElement convenience initializers and mutators

extension MakeGenerateAccountsResponseElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeGenerateAccountsResponseElement.self, from: data)
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
        accountAddress: String? = nil,
        encryptionPublicKey: String? = nil,
        encryptionSecretKey: String? = nil
    ) -> MakeGenerateAccountsResponseElement {
        return MakeGenerateAccountsResponseElement(
            accountAddress: accountAddress ?? self.accountAddress,
            encryptionPublicKey: encryptionPublicKey ?? self.encryptionPublicKey,
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
