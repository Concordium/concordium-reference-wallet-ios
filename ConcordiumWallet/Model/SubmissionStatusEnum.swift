//
// Created by Concordium on 23/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
enum SubmissionStatusEnum: String, Codable {
    case received
    case absent
    case committed
    case finalized
}
