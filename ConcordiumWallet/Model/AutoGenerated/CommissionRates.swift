// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commissionRates = try CommissionRates(json)

import Foundation

// MARK: - CommissionRates
struct CommissionRates: Codable {
    let transactionCommission: Double
    let finalizationCommission: Double
    let bakingCommission: Double

    enum CodingKeys: String, CodingKey {
        case transactionCommission = "transactionCommission"
        case finalizationCommission = "finalizationCommission"
        case bakingCommission = "bakingCommission"
    }
}

// MARK: CommissionRates convenience initializers and mutators

extension CommissionRates {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CommissionRates.self, from: data)
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
        transactionCommission: Double? = nil,
        finalizationCommission: Double? = nil,
        bakingCommission: Double? = nil
    ) -> CommissionRates {
        return CommissionRates(
            transactionCommission: transactionCommission ?? self.transactionCommission,
            finalizationCommission: finalizationCommission ?? self.finalizationCommission,
            bakingCommission: bakingCommission ?? self.bakingCommission
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
