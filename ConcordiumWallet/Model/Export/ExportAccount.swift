//
// Created by Johan Rugager Vase on 18/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ExportAccount: Codable {
    let name: String
    let address: String
    let submissionId: String
    let accountKeys: AccountKeys
    let revealedAttributes: [String: String]
    let credential: Credential
    let encryptionSecretKey: String // ok
}
