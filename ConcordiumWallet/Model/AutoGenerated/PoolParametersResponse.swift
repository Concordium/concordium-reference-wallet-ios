// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let poolParametersResponse = try PoolParametersResponse(json)

import Foundation

// MARK: - PoolParametersResponse
struct PoolParametersResponse: Codable {
    let capitalBound: Double
    let transactionCommissionLPool: Double
    let leverageBound: LeverageBound
    let finalizationCommissionLPool: Double
    let bakingCommissionRange: CommissionRange
    let bakingCommissionLPool: Double
    let finalizationCommissionRange: CommissionRange
    let transactionCommissionRange: CommissionRange
    let minimumEquityCapital: String

    enum CodingKeys: String, CodingKey {
        case capitalBound = "capitalBound"
        case transactionCommissionLPool = "transactionCommissionLPool"
        case leverageBound = "leverageBound"
        case finalizationCommissionLPool = "finalizationCommissionLPool"
        case bakingCommissionRange = "bakingCommissionRange"
        case bakingCommissionLPool = "bakingCommissionLPool"
        case finalizationCommissionRange = "finalizationCommissionRange"
        case transactionCommissionRange = "transactionCommissionRange"
        case minimumEquityCapital = "minimumEquityCapital"
    }
}

// MARK: PoolParametersResponse convenience initializers and mutators

extension PoolParametersResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PoolParametersResponse.self, from: data)
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
        capitalBound: Double? = nil,
        transactionCommissionLPool: Double? = nil,
        leverageBound: LeverageBound? = nil,
        finalizationCommissionLPool: Double? = nil,
        bakingCommissionRange: CommissionRange? = nil,
        bakingCommissionLPool: Double? = nil,
        finalizationCommissionRange: CommissionRange? = nil,
        transactionCommissionRange: CommissionRange? = nil,
        minimumEquityCapital: String? = nil
    ) -> PoolParametersResponse {
        return PoolParametersResponse(
            capitalBound: capitalBound ?? self.capitalBound,
            transactionCommissionLPool: transactionCommissionLPool ?? self.transactionCommissionLPool,
            leverageBound: leverageBound ?? self.leverageBound,
            finalizationCommissionLPool: finalizationCommissionLPool ?? self.finalizationCommissionLPool,
            bakingCommissionRange: bakingCommissionRange ?? self.bakingCommissionRange,
            bakingCommissionLPool: bakingCommissionLPool ?? self.bakingCommissionLPool,
            finalizationCommissionRange: finalizationCommissionRange ?? self.finalizationCommissionRange,
            transactionCommissionRange: transactionCommissionRange ?? self.transactionCommissionRange,
            minimumEquityCapital: minimumEquityCapital ?? self.minimumEquityCapital
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
