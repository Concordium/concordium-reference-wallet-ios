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
    case backup
    case cancel
}

extension ShowAlert {
    func showUpdateDialogIfNeeded(
        appSettingsResponse: AppSettingsResponse,
        showBackupOption: Bool,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        switch appSettingsResponse {
        case let .warning(url):
            showUpdateWarning(
                appStoreURL: url,
                showBackupOption: showBackupOption,
                actionHandler: actionHandler
            )
        case let .needsUpdate(url):
            showUpdatedNeeded(
                appStoreURL: url,
                showBackupOption: showBackupOption,
                actionHandler: actionHandler
            )
        case .ok:
            break
        }
    }
    
    private func showUpdateWarning(
        appStoreURL: URL,
        showBackupOption: Bool,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        var actions = [
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
        
//        if showBackupOption {
//            actions.insert(
//                AlertAction(
//                    name: "force.update.warning.backup".localized,
//                    completion: {
//                        actionHandler(.backup)
//                    },
//                    style: .default
//                ),
//                at: 1
//            )
//        }
        
        let alertOptions = AlertOptions(
            title: "force.update.warning.title".localized,
            message: showBackupOption ? "force.update.warning.message".localized : "force.update.warning.nobackup.message".localized,
            actions: actions)
        showAlert(with: alertOptions)
    }
    
    private func showUpdatedNeeded(
        appStoreURL: URL,
        showBackupOption: Bool,
        actionHandler: @escaping (ForceUpdateAction) -> Void
    ) {
        var actions = [
            AlertAction(
                name: "force.update.needed.update.now".localized,
                completion: {
                    actionHandler(.update(url: appStoreURL, forced: true))
                },
                style: .default
            )
        ]
        
        if showBackupOption {
            actions.append(
                AlertAction(
                    name: "force.update.needed.backup".localized,
                    completion: {
                        actionHandler(.backup)
                    },
                    style: .default
                )
            )
        }
        
        let alertOptions = AlertOptions(
            title: "force.update.needed.title".localized,
            message: showBackupOption ? "force.update.needed.message".localized : "force.update.needed.nobackup.message".localized,
            actions: actions
        )
        showAlert(with: alertOptions)
    }
}
