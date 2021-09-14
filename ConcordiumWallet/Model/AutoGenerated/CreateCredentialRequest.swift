// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createCredentialRequest = try CreateCredentialRequest(json)

import Foundation

// MARK: - CreateCredentialRequest
struct CreateCredentialRequest: Codable {
    let accountAddress: String
    let accountKeys: AccountKeys
    let credential: Credential
    let commitmentsRandomness: CommitmentsRandomness
    let encryptionPublicKey, encryptionSecretKey: String
}

// MARK: CreateCredentialRequest convenience initializers and mutators

extension CreateCredentialRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateCredentialRequest.self, from: data)
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
        credential: Credential? = nil,
        commitmentsRandomness: CommitmentsRandomness? = nil,
        encryptionPublicKey: String? = nil,
        encryptionSecretKey: String? = nil
    ) -> CreateCredentialRequest {
        return CreateCredentialRequest(
            accountAddress: accountAddress ?? self.accountAddress,
            accountKeys: accountKeys ?? self.accountKeys,
            credential: credential ?? self.credential,
            commitmentsRandomness: commitmentsRandomness ?? self.commitmentsRandomness,
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
