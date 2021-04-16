// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let makeGenerateAaccountsRequest = try MakeGenerateAaccountsRequest(json)

import Foundation

// MARK: - MakeGenerateAaccountsRequest
struct MakeGenerateAaccountsRequest: Codable {
    let identityObject: IdentityObject
    let privateIDObjectData: PrivateIDObjectData
    let global: Global

    enum CodingKeys: String, CodingKey {
        case identityObject = "identityObject"
        case privateIDObjectData = "privateIdObjectData"
        case global = "global"
    }
}

// MARK: MakeGenerateAaccountsRequest convenience initializers and mutators

extension MakeGenerateAaccountsRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeGenerateAaccountsRequest.self, from: data)
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
        identityObject: IdentityObject? = nil,
        privateIDObjectData: PrivateIDObjectData? = nil,
        global: Global? = nil
    ) -> MakeGenerateAaccountsRequest {
        return MakeGenerateAaccountsRequest(
            identityObject: identityObject ?? self.identityObject,
            privateIDObjectData: privateIDObjectData ?? self.privateIDObjectData,
            global: global ?? self.global
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
