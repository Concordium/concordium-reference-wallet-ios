//
//  BakingAlerts.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 06/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum BakingAlerts {
    static var noChanges: AlertOptions {
        let okAction = AlertAction(
            name: "baking.nochanges.ok".localized,
            completion: nil,
            style: .default
        )
        
        return AlertOptions(
            title: "baking.nochanges.title".localized,
            message: "baking.nochanges.message".localized,
            actions: [okAction]
        )
    }
}
