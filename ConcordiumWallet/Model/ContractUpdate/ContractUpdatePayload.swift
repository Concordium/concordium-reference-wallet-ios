import Foundation

// MARK: - Payload
struct ContractUpdatePayload: Codable {
    let amount: String
    let address: ContractAddress
    let receiveName: String
    let maxContractExecutionEnergy: Int
    let message: String
}

// MARK: - Address
struct ContractAddress: Codable {
    let index, subindex: Int
}

struct ParameterToJsonInput: Codable {
    let parameter: String
    let receiveName: String
    let schema: Schema
    let schemaVersion: Int?
}
