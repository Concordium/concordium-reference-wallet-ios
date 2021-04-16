// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let valueCredential = try ValueCredential(json)

import Foundation

// MARK: - ValueCredential
struct ValueCredential: Codable {
    let contents: JSONObject
    let type: String
}

// MARK: ValueCredential convenience initializers and mutators

extension ValueCredential {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ValueCredential.self, from: data)
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
        contents: JSONObject? = nil,
        type: String? = nil
    ) -> ValueCredential {
        return ValueCredential(
            contents: contents ?? self.contents,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
