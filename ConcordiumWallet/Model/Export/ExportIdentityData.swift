//
// Created by Concordium on 18/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ExportIdentityData: Codable {
    let nextAccountNumber: Int
    let identityProvider: IPInfoResponseElement
    let identityObject: IdentityObject
    let privateIdObjectData: PrivateIDObjectData
    let name: String
    let accounts: [ExportAccount]
}
