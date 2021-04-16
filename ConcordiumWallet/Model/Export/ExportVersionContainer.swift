//
// Created by Johan Rugager Vase on 18/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ExportVersionContainer: Codable {
    static let concordiumWalletExportType = "concordium-mobile-wallet-data"
    let value: ExportValues
    var v: Int = 1
    var type = concordiumWalletExportType
}

extension ExportVersionContainer {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ExportVersionContainer.self, from: data)
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
