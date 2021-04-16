// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountReleaseSchedule = try AccountReleaseSchedule(json)

import Foundation

// MARK: - AccountReleaseSchedule
struct AccountReleaseSchedule: Codable {
    let schedule: [Schedule]?
    let total: String?

    enum CodingKeys: String, CodingKey {
        case schedule = "schedule"
        case total = "total"
    }
}

// MARK: AccountReleaseSchedule convenience initializers and mutators

extension AccountReleaseSchedule {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountReleaseSchedule.self, from: data)
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
        schedule: [Schedule]?? = nil,
        total: String?? = nil
    ) -> AccountReleaseSchedule {
        return AccountReleaseSchedule(
            schedule: schedule ?? self.schedule,
            total: total ?? self.total
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
