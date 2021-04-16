// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let globalWrapper = try GlobalWrapper(json)

import Foundation

// MARK: - GlobalWrapper
struct GlobalWrapper: Codable {
    let value: Global
    let v: Int
}

// MARK: GlobalWrapper convenience initializers and mutators

extension GlobalWrapper {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GlobalWrapper.self, from: data)
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
        value: Global? = nil,
        v: Int? = nil
    ) -> GlobalWrapper {
        return GlobalWrapper(
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
