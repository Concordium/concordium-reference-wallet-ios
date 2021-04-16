// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let initialAccountData = try InitialAccountData(json)

import Foundation

// MARK: - InitialAccountData
struct InitialAccountData: Codable {
    let accountAddress: String
    let accountKeys: AccountKeys
    let encryptionPublicKey, encryptionSecretKey: String
}

// MARK: InitialAccountData convenience initializers and mutators

extension InitialAccountData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InitialAccountData.self, from: data)
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
        accountKeys: AccountKeys? = nil,
        encryptionPublicKey: String? = nil,
        encryptionSecretKey: String? = nil
    ) -> InitialAccountData {
        return InitialAccountData(
            accountAddress: accountAddress ?? self.accountAddress,
            accountKeys: accountKeys ?? self.accountKeys,
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
