import Foundation

// MARK: - Payload
struct ContractUpdatePayload: Codable {
    let amount: String
    let address: Address
    let receiveName: String
    let maxContractExecutionEnergy: Int
    let message: String
}

// MARK: - Address
struct Address: Codable {
    let index, subindex: Int
}
