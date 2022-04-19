// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let poolInfo = try PoolInfo(json)

import Foundation

// MARK: - PoolInfo
struct PoolInfo: Codable {
    let commissionRates: CommissionRates
    let openStatus: String
    let metadataURL: String

    enum CodingKeys: String, CodingKey {
        case commissionRates = "commissionRates"
        case openStatus = "openStatus"
        case metadataURL = "metadataUrl"
    }
}

// MARK: PoolInfo convenience initializers and mutators

extension PoolInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PoolInfo.self, from: data)
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
        commissionRates: CommissionRates? = nil,
        openStatus: String? = nil,
        metadataURL: String? = nil
    ) -> PoolInfo {
        return PoolInfo(
            commissionRates: commissionRates ?? self.commissionRates,
            openStatus: openStatus ?? self.openStatus,
            metadataURL: metadataURL ?? self.metadataURL
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
