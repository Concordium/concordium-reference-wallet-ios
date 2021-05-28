//
// Created by Concordium on 03/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
enum OutcomeEnum: String, Codable {
    case newAccount
    case newCredential
    case success
    case reject
    case ambiguous
}
