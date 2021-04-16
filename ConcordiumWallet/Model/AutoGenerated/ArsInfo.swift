// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let arsInfo = try ArsInfo(json)

import Foundation

// MARK: - ArsInfo
struct ArsInfo: Codable {
    let arIdentity: Int
    let arDescription: Description
    let arPublicKey: String
}

// MARK: ArsInfo convenience initializers and mutators

extension ArsInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ArsInfo.self, from: data)
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
        arIdentity: Int? = nil,
        arDescription: Description? = nil,
        arPublicKey: String? = nil
    ) -> ArsInfo {
        return ArsInfo(
            arIdentity: arIdentity ?? self.arIdentity,
            arDescription: arDescription ?? self.arDescription,
            arPublicKey: arPublicKey ?? self.arPublicKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
