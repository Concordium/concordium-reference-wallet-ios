// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let description = try Description(json)

import Foundation

// MARK: - Description
struct Description: Codable {
    let name, url, desc: String

    enum CodingKeys: String, CodingKey {
        case name, url
        case desc = "description"
    }
}

// MARK: Description convenience initializers and mutators

extension Description {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Description.self, from: data)
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
        name: String? = nil,
        url: String? = nil,
        desc: String? = nil
    ) -> Description {
        return Description(
            name: name ?? self.name,
            url: url ?? self.url,
            desc: desc ?? self.desc
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
