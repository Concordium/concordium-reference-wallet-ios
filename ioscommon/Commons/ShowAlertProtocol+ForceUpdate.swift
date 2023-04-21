//
//  ShowAlertProtocol+ForceUpdate.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum ForceUpdateAction {
    case update(url: URL, forced: Bool)
    case cancel
}

extension ShowAlert {
    func showUpdateDialogIfNeeded(
        appSettingsResponse: AppSettingsResponse,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        switch appSettingsResponse {
        case let .warning(url):
            showUpdateWarning(
                appStoreURL: url,
                actionHandler: actionHandler
            )
        case let .needsUpdate(url):
            showUpdatedNeeded(
                appStoreURL: url,
                actionHandler: actionHandler
            )
        case .ok:
            break
        }
    }
    
    private func showUpdateWarning(
        appStoreURL: URL,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        let actions = [
            AlertAction(
                name: "force.update.warning.update.now".localized,
                completion: {
                    actionHandler(.update(url: appStoreURL, forced: false))
                },
                style: .default
            ),
            AlertAction(
                name: "force.update.warning.remind.me".localized,
                completion: {
                    actionHandler(.cancel)
                },
                style: .default
            )
        ]
        
        let alertOptions = AlertOptions(
            title: "force.update.warning.title".localized,
            message: "force.update.warning.nobackup.message".localized,
            actions: actions)
        showAlert(with: alertOptions)
    }
    
    private func showUpdatedNeeded(
        appStoreURL: URL,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        let actions = [
            AlertAction(
                name: "force.update.needed.update.now".localized,
                completion: {
                    actionHandler(.update(url: appStoreURL, forced: true))
                },
                style: .default
            )
        ]
        
        let alertOptions = AlertOptions(
            title: "force.update.needed.title".localized,
            message: "force.update.needed.nobackup.message".localized,
            actions: actions
        )
        showAlert(with: alertOptions)
    }
}
