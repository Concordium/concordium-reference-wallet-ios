// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let attributeList = try AttributeList(json)

import Foundation

// MARK: - AttributeList
struct AttributeList: Codable {
    let validTo, createdAt: String
    let maxAccounts: Int
    let chosenAttributes: [String: String]
}

// MARK: AttributeList convenience initializers and mutators

extension AttributeList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AttributeList.self, from: data)
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
        validTo: String? = nil,
        createdAt: String? = nil,
        maxAccounts: Int? = nil,
        chosenAttributes: [String: String]? = nil
    ) -> AttributeList {
        return AttributeList(
            validTo: validTo ?? self.validTo,
            createdAt: createdAt ?? self.createdAt,
            maxAccounts: maxAccounts ?? self.maxAccounts,
            chosenAttributes: chosenAttributes ?? self.chosenAttributes
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
