// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let chainParametersResponse = try ChainParametersResponse(json)

import Foundation

// MARK: - ChainParametersResponse
struct ChainParametersResponse: Codable {
    let mintPerPayday: Double
    let rewardParameters: RewardParameters
    let poolOwnerCooldown: Int
    let capitalBound: Double
    let microGTUPerEuro: EuroPerEnergy
    let rewardPeriodLength: Int
    let passiveTransactionCommission: Double
    let leverageBound: EuroPerEnergy
    let foundationAccountIndex: Int
    let passiveFinalizationCommission: Double
    let delegatorCooldown: Int
    let bakingCommissionRange: CommissionRange
    let passiveBakingCommission: Double
    let accountCreationLimit: Int
    let finalizationCommissionRange: CommissionRange
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
        case passiveTransactionCommission = "passiveTransactionCommission"
        case leverageBound = "leverageBound"
        case foundationAccountIndex = "foundationAccountIndex"
        case passiveFinalizationCommission = "passiveFinalizationCommission"
        case delegatorCooldown = "delegatorCooldown"
        case bakingCommissionRange = "bakingCommissionRange"
        case passiveBakingCommission = "passiveBakingCommission"
        case accountCreationLimit = "accountCreationLimit"
        case finalizationCommissionRange = "finalizationCommissionRange"
        case euroPerEnergy = "euroPerEnergy"
        case transactionCommissionRange = "transactionCommissionRange"
        case minimumEquityCapital = "minimumEquityCapital"
    }
}

// MARK: ChainParametersResponse convenience initializers and mutators

extension ChainParametersResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ChainParametersResponse.self, from: data)
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
        passiveTransactionCommission: Double? = nil,
        leverageBound: EuroPerEnergy? = nil,
        foundationAccountIndex: Int? = nil,
        passiveFinalizationCommission: Double? = nil,
        delegatorCooldown: Int? = nil,
        bakingCommissionRange: CommissionRange? = nil,
        passiveBakingCommission: Double? = nil,
        accountCreationLimit: Int? = nil,
        finalizationCommissionRange: CommissionRange? = nil,
        euroPerEnergy: EuroPerEnergy? = nil,
        transactionCommissionRange: CommissionRange? = nil,
        minimumEquityCapital: String? = nil
    ) -> ChainParametersResponse {
        return ChainParametersResponse(
            mintPerPayday: mintPerPayday ?? self.mintPerPayday,
            rewardParameters: rewardParameters ?? self.rewardParameters,
            poolOwnerCooldown: poolOwnerCooldown ?? self.poolOwnerCooldown,
            capitalBound: capitalBound ?? self.capitalBound,
            microGTUPerEuro: microGTUPerEuro ?? self.microGTUPerEuro,
            rewardPeriodLength: rewardPeriodLength ?? self.rewardPeriodLength,
            passiveTransactionCommission: passiveTransactionCommission ?? self.passiveTransactionCommission,
            leverageBound: leverageBound ?? self.leverageBound,
            foundationAccountIndex: foundationAccountIndex ?? self.foundationAccountIndex,
            passiveFinalizationCommission: passiveFinalizationCommission ?? self.passiveFinalizationCommission,
            delegatorCooldown: delegatorCooldown ?? self.delegatorCooldown,
            bakingCommissionRange: bakingCommissionRange ?? self.bakingCommissionRange,
            passiveBakingCommission: passiveBakingCommission ?? self.passiveBakingCommission,
            accountCreationLimit: accountCreationLimit ?? self.accountCreationLimit,
            finalizationCommissionRange: finalizationCommissionRange ?? self.finalizationCommissionRange,
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
