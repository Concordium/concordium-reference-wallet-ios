// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountBalance = try AccountBalance(json)

import Foundation

// MARK: - AccountBalance
struct AccountBalance: Codable {
    let currentBalance: Balance?
    let finalizedBalance: Balance?

    enum CodingKeys: String, CodingKey {
        case currentBalance = "currentBalance"
        case finalizedBalance = "finalizedBalance"
    }
}

// MARK: AccountBalance convenience initializers and mutators

extension AccountBalance {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountBalance.self, from: data)
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
        currentBalance: Balance?? = nil,
        finalizedBalance: Balance?? = nil
    ) -> AccountBalance {
        return AccountBalance(
            currentBalance: currentBalance ?? self.currentBalance,
            finalizedBalance: finalizedBalance ?? self.finalizedBalance
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
