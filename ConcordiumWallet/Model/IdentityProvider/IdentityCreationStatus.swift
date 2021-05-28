//
// Created by Concordium on 18/06/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

enum IdentityCreationStatusEnum: String, Codable {
    case pending
    case done
    case error
}

struct IdentityCreationStatus: Codable {
    let status: IdentityCreationStatusEnum
    let token: IdentityWrapperShell?
    let error: String?
    let detail: String?
}

extension IdentityCreationStatus {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IdentityCreationStatus.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
}
