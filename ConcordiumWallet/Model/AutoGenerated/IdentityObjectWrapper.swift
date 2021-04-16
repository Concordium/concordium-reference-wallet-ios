// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let identityObjectWrapper = try IdentityObjectWrapper(json)

import Foundation

// MARK: - IdentityObjectWrapper
struct IdentityObjectWrapper: Codable {
    let value: IdentityObject
    let v: Int
}

// MARK: IdentityObjectWrapper convenience initializers and mutators

extension IdentityObjectWrapper {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IdentityObjectWrapper.self, from: data)
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
        value: IdentityObject? = nil,
        v: Int? = nil
    ) -> IdentityObjectWrapper {
        return IdentityObjectWrapper(
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
