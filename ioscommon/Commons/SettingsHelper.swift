//
//  SettingsHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 10/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

struct SettingsHelper {
    static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
