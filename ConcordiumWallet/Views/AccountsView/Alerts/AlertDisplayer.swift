//
//  AlertDisplayer.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum AlertType {
    case backup(notification: FinalizedAccountsNotification, actionCompletion: () -> Void, dismissCompletion: () -> Void)
    case backupExtra(notification: FinalizedAccountsNotification, actionCompletion: () -> Void, dismissCompletion: () -> Void)
    case shieldedTransfer(account: AccountDataType, actionCompletion: () -> Void, dismissCompletion: () -> Void)
    
    func priority() -> AlertDisplayPriority {
        switch self {
        case .backup:
            return .High
        case .backupExtra:
            return .Medium
        case .shieldedTransfer:
            return .Low
        }
    }
    func identifier() -> String {
        switch self {
        case .backup(let notification, _, _):
            switch notification {
            case .singleAccount(let accountName):
                return "backup" + "single" + accountName
            case .multiple:
                return "backup" + "multiple"
            }
        case .backupExtra(let notification, _, _):
            switch notification {
            case .singleAccount(let accountName):
                return "backupConfirmation" + "single" + accountName
            case .multiple:
                return "backupConfirmation" + "multiple"
            }
        case .shieldedTransfer(let account, _, _):
            return "shieldedTransfer" + account.address
        }
    }
    
    func getAlertOptions(alertDismissedCompletion: @escaping () -> Void) -> AlertOptions {
        switch self {
        case .backup(let notification, let action, let dismiss):
            let title: String
            let message: String
            
            switch notification {
            case .singleAccount(let accountName):
                title = "accountfinalized.single.alert.title".localized
                message = String(format: "accountfinalized.single.alert.message".localized, accountName)
            case .multiple:
                title = "accountfinalized.multiple.alert.title".localized
                message = "accountfinalized.multiple.alert.message".localized
            }
            
            return AlertOptions(title: title, message: message, actions: [
                AlertAction(
                    name: "ok".localized,
                    completion: {
                        dismiss()
                        alertDismissedCompletion()
                    },
                    style: .default),
                AlertAction(
                    name: "accountfinalized.alert.action.backup".localized,
                    completion: {
                        action()
                        alertDismissedCompletion()
                    },
                    style: .default)
            ])
            
        case .backupExtra(_, let action, let dismiss):
            return AlertOptions(
                title: "accountfinalized.extrabackup.alert.title".localized,
                message: "accountfinalized.extrabackup.alert.message".localized,
                actions: [
                    AlertAction(
                        name: "accountfinalized.extrabackup.alert.action.dismiss".localized,
                        completion: {
                            dismiss()
                            alertDismissedCompletion()
                        },
                        style: .destructive
                    ),
                    AlertAction(
                        name: "accountfinalized.alert.action.backup".localized,
                        completion: {
                            action()
                            alertDismissedCompletion()
                        },
                        style: .default
                    )
                ]
            )
        case .shieldedTransfer(let account, let action, let dismiss):
            let showActionName = String(format: "accounts.alert.shiededtransactions.show".localized, account.displayName)
            let message = String(format: "accounts.alert.shiededtransactions.message".localized, account.displayName, account.displayName)
            return AlertOptions(title: "accounts.alert.shiededtransactions.title".localized, message: message, actions: [
                AlertAction(name: showActionName, completion: {
                    action()
                    alertDismissedCompletion()
                }, style: .default),
                AlertAction(name: "accounts.alert.shiededtransactions.later".localized, completion: {
                    dismiss()
                    alertDismissedCompletion()
                }, style: .default)
            ])
        }
        
    }
}

enum AlertDisplayPriority: Int, Comparable {
    case Lowest
    case Low
    case Medium
    case High
    case Highest
    
    static func < (lhs: AlertDisplayPriority, rhs: AlertDisplayPriority) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

extension AlertType: Equatable {
    static func == (lhs: AlertType, rhs: AlertType) -> Bool {
        lhs.identifier() == rhs.identifier()
    }
}
extension AlertType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier())
    }
}

protocol AlertDisplayerDelegate: AnyObject {
    func showAlert(options: AlertOptions)
}

class AlertDisplayer {
    @Published private var alerts: Set<AlertType> = []
    private var shownAlertType: AlertType?
    private var cancellables: [AnyCancellable] = []
    
    weak var delegate: AlertDisplayerDelegate? {
        didSet {
            $alerts.sink { [weak self] alerts in
                guard let self = self else { return }
                self.determineShownAlert(alerts: alerts)
            }.store(in: &cancellables)
        }
    }
    
    func enqueueAlert(_ alert: AlertType) {
        let dismissedIds = AppSettings.dismissedAlertIds
        if !dismissedIds.contains(alert.identifier()) {
            alerts.insert(alert)
           
        }
    }
    
    private func determineShownAlert(alerts: Set<AlertType>) {
        let firstAlert = alerts.sorted { $0.priority() < $1.priority() }.first
        if let alert = firstAlert {
            // if we are not currently showing an alert we display the one that was just added
            // if we show one, we wait for it to be dismissed thus removed from alerts and this code will run again
            if shownAlertType == nil {
                shownAlertType = alert
                self.delegate?.showAlert(options: alert.getAlertOptions(alertDismissedCompletion: { [weak self] in
                    // only save dimissed for shielded (backup needs to always be shown when added to the displayer)
                    if let shownAlertType = self?.shownAlertType {
                        // remove the alert only after it was dismissed
                        self?.shownAlertType = nil
                        self?.alerts.remove(shownAlertType)
                        // if it was a shielded transfer alert, we added to the dismissed list
                        if case AlertType.shieldedTransfer = shownAlertType {
                            var dismissedIds = AppSettings.dismissedAlertIds
                            dismissedIds.append(shownAlertType.identifier())
                            AppSettings.dismissedAlertIds = dismissedIds
                        }
                    }
                    
                }))
            }
        }
    }
}
