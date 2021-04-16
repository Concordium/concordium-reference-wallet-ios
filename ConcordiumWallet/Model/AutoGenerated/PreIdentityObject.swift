// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let preIdentityObject = try PreIdentityObject(json)

import Foundation

// MARK: - PreIdentityObject
struct PreIdentityObject: Codable {
    let pubInfoForIP: PubInfoForIP
    let ipArData: [String: IPArDatum]
    let choiceArData: ChoiceArData
    let idCredSECCommitment, prfKeyCommitmentWithIP: String
    let prfKeySharingCoeffCommitments: [String]
    let proofsOfKnowledge: String

    enum CodingKeys: String, CodingKey {
        case pubInfoForIP = "pubInfoForIp"
        case ipArData, choiceArData
        case idCredSECCommitment = "idCredSecCommitment"
        case prfKeyCommitmentWithIP, prfKeySharingCoeffCommitments, proofsOfKnowledge
    }
}

// MARK: PreIdentityObject convenience initializers and mutators

extension PreIdentityObject {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PreIdentityObject.self, from: data)
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
        pubInfoForIP: PubInfoForIP? = nil,
        ipArData: [String: IPArDatum]? = nil,
        choiceArData: ChoiceArData? = nil,
        idCredSECCommitment: String? = nil,
        prfKeyCommitmentWithIP: String? = nil,
        prfKeySharingCoeffCommitments: [String]? = nil,
        proofsOfKnowledge: String? = nil
    ) -> PreIdentityObject {
        return PreIdentityObject(
            pubInfoForIP: pubInfoForIP ?? self.pubInfoForIP,
            ipArData: ipArData ?? self.ipArData,
            choiceArData: choiceArData ?? self.choiceArData,
            idCredSECCommitment: idCredSECCommitment ?? self.idCredSECCommitment,
            prfKeyCommitmentWithIP: prfKeyCommitmentWithIP ?? self.prfKeyCommitmentWithIP,
            prfKeySharingCoeffCommitments: prfKeySharingCoeffCommitments ?? self.prfKeySharingCoeffCommitments,
            proofsOfKnowledge: proofsOfKnowledge ?? self.proofsOfKnowledge
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
