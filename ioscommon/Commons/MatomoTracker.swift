//
//  MatomoTracker.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 28.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import MatomoTracker

extension MatomoTracker {
    static let shared: MatomoTracker = {
        let queue = UserDefaultsQueue(UserDefaults.standard, autoSave: true)
        let dispatcher = URLSessionDispatcher(baseURL: URL(string: AppConstants.MatomoTracker.baseUrl)!)
        let matomoTracker = MatomoTracker(siteId: AppConstants.MatomoTracker.siteId, queue: queue, dispatcher: dispatcher)
        matomoTracker.logger = DefaultLogger(minLevel: .verbose)
        matomoTracker.migrateFromFourPointFourSharedInstance()
        return matomoTracker
    }()
    
    private func migrateFromFourPointFourSharedInstance() {
        guard !UserDefaults.standard.bool(forKey: AppConstants.MatomoTracker.migratedFromFourPointFourSharedInstance) else { return }
        copyFromOldSharedInstance()
        UserDefaults.standard.set(true, forKey: AppConstants.MatomoTracker.migratedFromFourPointFourSharedInstance)
    }
}
