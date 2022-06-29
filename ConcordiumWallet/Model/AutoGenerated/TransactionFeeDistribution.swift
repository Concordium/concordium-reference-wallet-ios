// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let transactionFeeDistribution = try TransactionFeeDistribution(json)

import Foundation

// MARK: - TransactionFeeDistribution
struct TransactionFeeDistribution: Codable {
    let gasAccount: Double
    let baker: Double

    enum CodingKeys: String, CodingKey {
        case gasAccount = "gasAccount"
        case baker = "baker"
    }
}

// MARK: TransactionFeeDistribution convenience initializers and mutators

extension TransactionFeeDistribution {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TransactionFeeDistribution.self, from: data)
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
        gasAccount: Double? = nil,
        baker: Double? = nil
    ) -> TransactionFeeDistribution {
        return TransactionFeeDistribution(
            gasAccount: gasAccount ?? self.gasAccount,
            baker: baker ?? self.baker
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
