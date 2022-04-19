// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let poolParametersResponse = try PoolParametersResponse(json)

import Foundation

// MARK: - PoolParametersResponse
struct PoolParametersResponse: Codable {
    let mintPerPayday: Double
    let rewardParameters: RewardParameters
    let poolOwnerCooldown: Int
    let capitalBound: Double
    let microGTUPerEuro: EuroPerEnergy
    let rewardPeriodLength: Int
    let transactionCommissionLPool: Double
    let leverageBound: EuroPerEnergy
    let foundationAccountIndex: Int
    let finalizationCommissionLPool: Double
    let delegatorCooldown: Int
    let bakingCommissionRange: CommissionRange
    let bakingCommissionLPool: Double
    let accountCreationLimit: Int
    let finalizationCommissionRange: CommissionRange
    let electionDifficulty: Double
    let euroPerEnergy: EuroPerEnergy
    let transactionCommissionRange: CommissionRange
    let minimumEquityCapital: String

    enum CodingKeys: String, CodingKey {
        case mintPerPayday = "mintPerPayday"
        case rewardParameters = "rewardParameters"
        case poolOwnerCooldown = "poolOwnerCooldown"
        case capitalBound = "capitalBound"
        case microGTUPerEuro = "microGTUPerEuro"
        case rewardPeriodLength = "rewardPeriodLength"
        case transactionCommissionLPool = "transactionCommissionLPool"
        case leverageBound = "leverageBound"
        case foundationAccountIndex = "foundationAccountIndex"
        case finalizationCommissionLPool = "finalizationCommissionLPool"
        case delegatorCooldown = "delegatorCooldown"
        case bakingCommissionRange = "bakingCommissionRange"
        case bakingCommissionLPool = "bakingCommissionLPool"
        case accountCreationLimit = "accountCreationLimit"
        case finalizationCommissionRange = "finalizationCommissionRange"
        case electionDifficulty = "electionDifficulty"
        case euroPerEnergy = "euroPerEnergy"
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
        mintPerPayday: Double? = nil,
        rewardParameters: RewardParameters? = nil,
        poolOwnerCooldown: Int? = nil,
        capitalBound: Double? = nil,
        microGTUPerEuro: EuroPerEnergy? = nil,
        rewardPeriodLength: Int? = nil,
        transactionCommissionLPool: Double? = nil,
        leverageBound: EuroPerEnergy? = nil,
        foundationAccountIndex: Int? = nil,
        finalizationCommissionLPool: Double? = nil,
        delegatorCooldown: Int? = nil,
        bakingCommissionRange: CommissionRange? = nil,
        bakingCommissionLPool: Double? = nil,
        accountCreationLimit: Int? = nil,
        finalizationCommissionRange: CommissionRange? = nil,
        electionDifficulty: Double? = nil,
        euroPerEnergy: EuroPerEnergy? = nil,
        transactionCommissionRange: CommissionRange? = nil,
        minimumEquityCapital: String? = nil
    ) -> PoolParametersResponse {
        return PoolParametersResponse(
            mintPerPayday: mintPerPayday ?? self.mintPerPayday,
            rewardParameters: rewardParameters ?? self.rewardParameters,
            poolOwnerCooldown: poolOwnerCooldown ?? self.poolOwnerCooldown,
            capitalBound: capitalBound ?? self.capitalBound,
            microGTUPerEuro: microGTUPerEuro ?? self.microGTUPerEuro,
            rewardPeriodLength: rewardPeriodLength ?? self.rewardPeriodLength,
            transactionCommissionLPool: transactionCommissionLPool ?? self.transactionCommissionLPool,
            leverageBound: leverageBound ?? self.leverageBound,
            foundationAccountIndex: foundationAccountIndex ?? self.foundationAccountIndex,
            finalizationCommissionLPool: finalizationCommissionLPool ?? self.finalizationCommissionLPool,
            delegatorCooldown: delegatorCooldown ?? self.delegatorCooldown,
            bakingCommissionRange: bakingCommissionRange ?? self.bakingCommissionRange,
            bakingCommissionLPool: bakingCommissionLPool ?? self.bakingCommissionLPool,
            accountCreationLimit: accountCreationLimit ?? self.accountCreationLimit,
            finalizationCommissionRange: finalizationCommissionRange ?? self.finalizationCommissionRange,
            electionDifficulty: electionDifficulty ?? self.electionDifficulty,
            euroPerEnergy: euroPerEnergy ?? self.euroPerEnergy,
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
