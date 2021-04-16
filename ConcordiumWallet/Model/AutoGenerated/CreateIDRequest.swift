// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createIDRequest = try CreateIDRequest(json)

import Foundation

// MARK: - CreateIDRequest
struct CreateIDRequest: Codable {
    let ipInfo: IPInfo
    let arsInfos: [String: ArsInfo]
    let global: Global
}

// MARK: CreateIDRequest convenience initializers and mutators

extension CreateIDRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateIDRequest.self, from: data)
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
        global: Global? = nil
    ) -> CreateIDRequest {
        return CreateIDRequest(
            ipInfo: ipInfo ?? self.ipInfo,
            arsInfos: arsInfos ?? self.arsInfos,
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
