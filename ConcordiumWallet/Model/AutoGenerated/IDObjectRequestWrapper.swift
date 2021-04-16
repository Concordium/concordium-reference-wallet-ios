// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let iDObjectRequest = try IDObjectRequestWrapper(json)

import Foundation

// MARK: - IDObjectRequestWrapper
struct IDObjectRequestWrapper: Codable {
    let value: PreIdentityObject
    let v: Int
}

// MARK: IDObjectRequestWrapper convenience initializers and mutators

extension IDObjectRequestWrapper {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IDObjectRequestWrapper.self, from: data)
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
        value: PreIdentityObject? = nil,
        v: Int? = nil
    ) -> IDObjectRequestWrapper {
        return IDObjectRequestWrapper(
            value: value ?? self.value,
            v: v ?? self.v
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
