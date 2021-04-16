// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeCreateCredentialRequest = try MakeCreateCredentialRequest(json)

import Foundation

// MARK: - MakeCreateCredentialRequest
struct MakeCreateCredentialRequest: Codable {
    let ipInfo: IPInfo
    let arsInfos: [String: ArsInfo]
    let global: Global
    let identityObject: IdentityObject
    let privateIDObjectData: PrivateIDObjectData
    let revealedAttributes: [String]
    let accountNumber, expiry: Int

    enum CodingKeys: String, CodingKey {
        case ipInfo, arsInfos, global, identityObject
        case privateIDObjectData = "privateIdObjectData"
        case revealedAttributes, accountNumber, expiry
    }
}

// MARK: MakeCreateCredentialRequest convenience initializers and mutators

extension MakeCreateCredentialRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeCreateCredentialRequest.self, from: data)
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
        ipInfo: IPInfo? = nil,
        arsInfos: [String: ArsInfo]? = nil,
        global: Global? = nil,
        identityObject: IdentityObject? = nil,
        privateIDObjectData: PrivateIDObjectData? = nil,
        revealedAttributes: [String]? = nil,
        accountNumber: Int? = nil,
        expiry: Int? = nil
    ) -> MakeCreateCredentialRequest {
        return MakeCreateCredentialRequest(
            ipInfo: ipInfo ?? self.ipInfo,
            arsInfos: arsInfos ?? self.arsInfos,
            global: global ?? self.global,
            identityObject: identityObject ?? self.identityObject,
            privateIDObjectData: privateIDObjectData ?? self.privateIDObjectData,
            revealedAttributes: revealedAttributes ?? self.revealedAttributes,
            accountNumber: accountNumber ?? self.accountNumber,
            expiry: expiry ?? self.expiry
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
