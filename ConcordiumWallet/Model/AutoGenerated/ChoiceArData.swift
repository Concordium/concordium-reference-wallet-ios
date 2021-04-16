// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let choiceArData = try ChoiceArData(json)

import Foundation

// MARK: - ChoiceArData
struct ChoiceArData: Codable {
    let arIdentities: [Int]
    let threshold: Int
}

// MARK: ChoiceArData convenience initializers and mutators

extension ChoiceArData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ChoiceArData.self, from: data)
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
        arIdentities: [Int]? = nil,
        threshold: Int? = nil
    ) -> ChoiceArData {
        return ChoiceArData(
            arIdentities: arIdentities ?? self.arIdentities,
            threshold: threshold ?? self.threshold
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
