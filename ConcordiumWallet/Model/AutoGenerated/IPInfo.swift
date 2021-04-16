// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let iPInfo = try IPInfo(json)

import Foundation

// MARK: - IPInfo
struct IPInfo: Codable {
    let ipIdentity: Int
    let ipDescription: Description
    let ipVerifyKey, ipCdiVerifyKey: String
}

// MARK: IPInfo convenience initializers and mutators

extension IPInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IPInfo.self, from: data)
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
        ipIdentity: Int? = nil,
        ipDescription: Description? = nil,
        ipVerifyKey: String? = nil,
        ipCdiVerifyKey: String? = nil
    ) -> IPInfo {
        return IPInfo(
            ipIdentity: ipIdentity ?? self.ipIdentity,
            ipDescription: ipDescription ?? self.ipDescription,
            ipVerifyKey: ipVerifyKey ?? self.ipVerifyKey,
            ipCdiVerifyKey: ipCdiVerifyKey ?? self.ipCdiVerifyKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
