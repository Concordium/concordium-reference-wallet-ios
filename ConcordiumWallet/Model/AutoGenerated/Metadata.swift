// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let metadata = try Metadata(json)

import Foundation

// MARK: - Metadata
struct Metadata: Codable {
    let support: String?
    let issuanceStart: String
    let recoveryStart: String?
    let icon: String
}

// MARK: Metadata convenience initializers and mutators

extension Metadata {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Metadata.self, from: data)
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
        support: String?? = nil,
        issuanceStart: String? = nil,
        recoveryStart: String? = nil,
        icon: String? = nil
    ) -> Metadata {
        return Metadata(
            support: support ?? self.support,
            issuanceStart: issuanceStart ?? self.issuanceStart,
            recoveryStart: recoveryStart ?? self.recoveryStart,
            icon: icon ?? self.icon
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
