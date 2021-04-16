// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let global = try Global(json)

import Foundation

// MARK: - Global
struct Global: Codable {
    let generator: String?
    let onChainCommitmentKey: String?
    let bulletproofGenerators: String?
    let genesisString: String?

    enum CodingKeys: String, CodingKey {
        case generator = "generator"
        case onChainCommitmentKey = "onChainCommitmentKey"
        case bulletproofGenerators = "bulletproofGenerators"
        case genesisString = "genesisString"
    }
}

// MARK: Global convenience initializers and mutators

extension Global {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Global.self, from: data)
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
        generator: String?? = nil,
        onChainCommitmentKey: String?? = nil,
        bulletproofGenerators: String?? = nil,
        genesisString: String?? = nil
    ) -> Global {
        return Global(
            generator: generator ?? self.generator,
            onChainCommitmentKey: onChainCommitmentKey ?? self.onChainCommitmentKey,
            bulletproofGenerators: bulletproofGenerators ?? self.bulletproofGenerators,
            genesisString: genesisString ?? self.genesisString
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
