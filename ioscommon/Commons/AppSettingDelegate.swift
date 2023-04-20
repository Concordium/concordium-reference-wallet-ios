//
//  AppSettingDelegate.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol AppSettingsDelegate: AnyObject {
    func checkForLatestTermsAndConditions()
    func checkForAppSettings()
}
