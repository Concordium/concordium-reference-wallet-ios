// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let privateIDObjectData = try PrivateIDObjectData(json)

import Foundation

// MARK: - PrivateIDObjectData
struct PrivateIDObjectData: Codable {
    let aci: Aci
    let randomness: String
}

// MARK: PrivateIDObjectData convenience initializers and mutators

extension PrivateIDObjectData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrivateIDObjectData.self, from: data)
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
        aci: Aci? = nil,
        randomness: String? = nil
    ) -> PrivateIDObjectData {
        return PrivateIDObjectData(
            aci: aci ?? self.aci,
            randomness: randomness ?? self.randomness
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
