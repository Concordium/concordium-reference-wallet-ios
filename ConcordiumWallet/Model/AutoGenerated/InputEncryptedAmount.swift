// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let inputEncryptedAmount = try InputEncryptedAmount(json)

import Foundation

// MARK: - InputEncryptedAmount
struct InputEncryptedAmount: Codable {
    let aggEncryptedAmount: String?
    let aggAmount: String?
    let aggIndex: Int?

    enum CodingKeys: String, CodingKey {
        case aggEncryptedAmount = "aggEncryptedAmount"
        case aggAmount = "aggAmount"
        case aggIndex = "aggIndex"
    }
}

// MARK: InputEncryptedAmount convenience initializers and mutators

extension InputEncryptedAmount {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InputEncryptedAmount.self, from: data)
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
        aggEncryptedAmount: String?? = nil,
        aggAmount: String?? = nil,
        aggIndex: Int?? = nil
    ) -> InputEncryptedAmount {
        return InputEncryptedAmount(
            aggEncryptedAmount: aggEncryptedAmount ?? self.aggEncryptedAmount,
            aggAmount: aggAmount ?? self.aggAmount,
            aggIndex: aggIndex ?? self.aggIndex
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
