//
// Created by Concordium on 22/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ExportContainer: Codable {
    let metadata: EncryptionMetadata
    let cipherText: String
}

extension ExportContainer {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ExportContainer.self, from: data)
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
