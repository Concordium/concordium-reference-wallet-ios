//
//  AppConstants.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 13/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

struct AppConstants {
    
    // MARK: - Privacy Policy
    
    struct PrivacyPolicy {
        static let url = "https://developer.concordium.software/extra/Terms-and-conditions-Mobile-Wallet.pdf"
    }
    
    // MARK: - Support
    struct Support {
        static let concordiumSupportMail: String = Bundle.main.object(forInfoDictionaryKey: "Concordium Support Mail") as? String ?? ""
    }
    
    //
    struct MatomoTracker {
        static let baseUrl: String = "https://concordium.matomo.cloud/matomo.php"
        static let siteId = "4"
        static let versionCustomDimensionId: Int = 1
        static let networkCustomDimensionId: Int = 2
        
        static let migratedFromFourPointFourSharedInstance = "migratedFromFourPointFourSharedInstance"
    }
    
    //
    struct Email {
        static let contact = "contact@concordium.software"
        static let support = "support@concordium.software"
    }
}
