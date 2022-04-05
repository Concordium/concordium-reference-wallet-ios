// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let delegationTarget = try TransferRequestDelegationTarget(json)

import Foundation

// MARK: - TransferRequestDelegationTarget
struct TransferRequestDelegationTarget: Codable {
    let type: String?
    let targetBaker: Int?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case targetBaker = "targetBaker"
    }
    
    init(type: String?, targetBaker: Int?) {
        self.type = type
        self.targetBaker = targetBaker == -1 ? nil : targetBaker
    }
}

// MARK: TransferRequestDelegationTarget convenience initializers and mutators

extension TransferRequestDelegationTarget {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TransferRequestDelegationTarget.self, from: data)
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
        type: String?? = nil,
        targetBaker: Int?? = nil
    ) -> TransferRequestDelegationTarget {
        return TransferRequestDelegationTarget(
            type: type ?? self.type,
            targetBaker: targetBaker ?? self.targetBaker
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
