// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountEncryptedAmount = try AccountEncryptedAmount(json)

import Foundation

// MARK: - AccountEncryptedAmount
struct AccountEncryptedAmount: Codable {
    let incomingAmounts: [String]?
    let selfAmount: String?
    let startIndex: Int?
    let numAggregated: Int?

    enum CodingKeys: String, CodingKey {
        case incomingAmounts = "incomingAmounts"
        case selfAmount = "selfAmount"
        case startIndex = "startIndex"
        case numAggregated = "numAggregated"
    }
}

// MARK: AccountEncryptedAmount convenience initializers and mutators

extension AccountEncryptedAmount {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountEncryptedAmount.self, from: data)
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
        incomingAmounts: [String]?? = nil,
        selfAmount: String?? = nil,
        startIndex: Int?? = nil,
        numAggregated: Int?? = nil
    ) -> AccountEncryptedAmount {
        return AccountEncryptedAmount(
            incomingAmounts: incomingAmounts ?? self.incomingAmounts,
            selfAmount: selfAmount ?? self.selfAmount,
            startIndex: startIndex ?? self.startIndex,
            numAggregated: numAggregated ?? self.numAggregated
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
