//
//  AppConstants.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 13/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

struct AppConstants {
    struct Support {
        static let supportMail: String = Bundle.main.object(forInfoDictionaryKey: "Notabene Support Mail") as? String ?? ""
    }
}
