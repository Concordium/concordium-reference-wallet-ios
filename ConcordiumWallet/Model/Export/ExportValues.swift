//
// Created by Concordium on 18/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ExportValues: Codable {
    let identities: [ExportIdentityData]
    let recipients: [ExportRecipient]
}
