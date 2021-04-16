// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let iDRequest = try IDRequest(json)

import Foundation

// MARK: - IDRequest
struct IDRequest: Codable {
    let idObjectRequest: IDObjectRequestWrapper
    let redirectURI: String
}

// MARK: IDRequest convenience initializers and mutators

extension IDRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IDRequest.self, from: data)
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
        idObjectRequest: IDObjectRequestWrapper? = nil,
        redirectURI: String? = nil
    ) -> IDRequest {
        return IDRequest(
            idObjectRequest: idObjectRequest ?? self.idObjectRequest,
            redirectURI: redirectURI ?? self.redirectURI
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
