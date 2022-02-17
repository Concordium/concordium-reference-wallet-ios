//
//  SanityChecker.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/01/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

enum SanityCheckerMode {
    case automatic
    case manual
}

protocol ImportExport: AnyObject {
    func showImport()
    func showExport()
}

class SanityChecker {
    var errorDisplayer: ShowAlert?
    var mobileWallet: MobileWalletProtocol
    var storageManager: StorageManagerProtocol
    weak var coordinator: Coordinator?
    weak var delegate: ImportExport?
    
    private var cancellables: [AnyCancellable] = []
    
    static var lastSanityReport: [(IdentityDataType?, [AccountDataType])] = []
    
    init(mobileWallet: MobileWalletProtocol,
         storageManager: StorageManagerProtocol) {
        self.mobileWallet = mobileWallet
        self.storageManager = storageManager
    }
    
    // swiftlint:disable:next line_length
    public func requestPwAndCheckSanity(requestPasswordDelegate: RequestPasswordDelegate?, keychainWrapper: KeychainWrapperProtocol, mode: SanityCheckerMode) {
        requestPasswordDelegate?.requestUserPassword(keychain: keychainWrapper)
            .sink(receiveError: { [weak self] error in
                if case GeneralError.userCancelled = error { return }
                self?.errorDisplayer?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] pwHash in
                guard let self = self else { return }
                self.checkSanity(pwHash: pwHash, mode: mode, completion: {})
            }).store(in: &cancellables)
    }
    
    public func generateSanityReport(pwHash: String) -> [(IdentityDataType?, [AccountDataType])] {
        let report = self.mobileWallet.verifyIdentitiesAndAccounts(pwHash: pwHash)
        SanityChecker.lastSanityReport = report
        return report
    }
    
    public func checkSanity(pwHash: String, mode: SanityCheckerMode, completion: @escaping () -> Void) {
        let report = generateSanityReport(pwHash: pwHash)
        self.showValidateIdentitiesAlert(report: report, mode: mode, completion: completion)
    }
    
    // swiftlint:disable:next line_length
    public func showValidateIdentitiesAlert(report: [(IdentityDataType?, [AccountDataType])], mode: SanityCheckerMode, completion: @escaping () -> Void) {
        switch mode {
        case .automatic:
            if report.count == 0 || AppSettings.ignoreMissingKeysForIdsOrAccountsAtLogin == true {
                if AppSettings.lastKnownAppVersion == nil {
                    showBackupWarningAfterUpdate(completion: completion)
                    AppSettings.lastKnownAppVersion = AppSettings.appVersion
                } else if let lastKnownAppVersion = AppSettings.lastKnownAppVersion,
                          lastKnownAppVersion.versionCompare(AppSettings.appVersion) != .orderedSame {
                    showBackupWarningAfterUpdate(completion: completion)
                    AppSettings.lastKnownAppVersion = AppSettings.appVersion
                }
                
                return
            }
        case .manual:
            if report.count == 0 {
                showAllOkAlert()
                return
            }
        }
        var message = "more.validateIdsAndAccount.unusableIdentitiesFound".localized
        for (identity, accounts) in report {
            if let nickname = identity?.nickname {
                message += String(format: "more.validateIdsAndAccount.identity".localized, nickname)
            } else {
                message += "\n"
            }
            for account in accounts {
                message += String(format: "more.validateIdsAndAccount.account".localized, account.displayName)
            }
        }
        
        let alert = UIAlertController(
            title: "more.validateIdsAndAccount.warningTitle".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(title: "more.validateIdsAndAccount.removeFromApp".localized, style: .destructive) { [weak self] (_) in
            self?.showSecondConfirmation(report: report, completion: completion)
        }
       
        let remindMeLater = UIAlertAction(title: "more.validateIdsAndAccount.remindLater".localized, style: .default) {  [weak self] (_) in
            self?.remindMeLater(report: report)
            completion()
        }
        
        let keepAsReadonly = UIAlertAction(title: "more.validateIdsAndAccount.keep".localized, style: .default) {  [weak self] (_) in
            self?.keepAsReadOnly(report: report)
            completion()
        }
        let redirectToImport = UIAlertAction(title: "more.validateIdsAndAccount.import".localized, style: .cancel) {  [weak self] (_) in
            self?.redirectToImport()
            completion()
        }
        
        switch mode {
        case .automatic:
            break
        case .manual:
            alert.addAction(removeAction)
        }
        
        alert.addAction(remindMeLater)
        alert.addAction(keepAsReadonly)
        alert.addAction(redirectToImport)
        
        coordinator?.navigationController.present(alert, animated: true)
    }
    
    private func redirectToImport() {
        self.delegate?.showImport()
    }
    /*
     The method returns the identities that failed to be removed. If some of the identities in the report also
     contain accounts that have keys, that identity will not be removed
     */
    private func removeIdentitiesAndAccountsWithoutKeys(report: [(IdentityDataType?, [AccountDataType])]) -> [IdentityDataType] {
        var failToRemoveIdentities = [IdentityDataType]()
        for (identity, accounts) in report {
            //if we do not have an identity attached, we delete the accounts
            guard let identity = identity else {
                for account in accounts {
                    self.storageManager.removeAccount(account: account)
                }
                continue
            }
            let identityAccounts = self.storageManager.getAccounts(for: identity)
            for account in accounts {
                self.storageManager.removeAccount(account: account)
            }
            //if the identity contains also valid accounts, we cannot delete the identity
            if identityAccounts.count == accounts.count {
                self.storageManager.removeIdentity(identity)
            } else {
                failToRemoveIdentities.append(identity)
            }
        }
        return failToRemoveIdentities
    }
    
    private func remindMeLater(report: [(IdentityDataType?, [AccountDataType])]) {
        AppSettings.ignoreMissingKeysForIdsOrAccountsAtLogin = false
        markIdsAndAccountsAsReadOnly(report: report)
    }
    
    private func keepAsReadOnly(report: [(IdentityDataType?, [AccountDataType])]) {
        AppSettings.ignoreMissingKeysForIdsOrAccountsAtLogin = true
        markIdsAndAccountsAsReadOnly(report: report)
    }
    
    private func markIdsAndAccountsAsReadOnly(report: [(IdentityDataType?, [AccountDataType])]) {
        //only accounts will be marked as readonly because we don't have a readonly state for ids yet
        for (_, accounts) in report {
            for account in accounts {
                _ = account.withMarkAsReadOnly(true)
            }
        }
    }
    
    private func showSecondConfirmation(report: [(IdentityDataType?, [AccountDataType])], completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "more.validateIdsAndAccount.confirmationtitle".localized,
            message: "more.validateIdsAndAccount.confirmationtext".localized,
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(title: "more.validateIdsAndAccount.yesremoveFromApp".localized, style: .destructive) { [weak self] (_) in
            guard let self = self else { return }
            let failedToRemoveIdentities = self.removeIdentitiesAndAccountsWithoutKeys(report: report)
            if failedToRemoveIdentities.count == 0 {
                completion()
            } else {
                self.showAlertForIdentitiesNotDeleted(failedToRemoveIdentities: failedToRemoveIdentities,
                                                      completion: completion)
            }
        }
        
        let keepAsReadonly = UIAlertAction(title: "more.validateIdsAndAccount.keep".localized, style: .cancel) {  [weak self] (_) in
            self?.keepAsReadOnly(report: report)
            completion()
        }
        let redirectToImport = UIAlertAction(title: "more.validateIdsAndAccount.import".localized, style: .default) {  [weak self] (_) in
            self?.redirectToImport()
            completion()
        }
        alert.addAction(removeAction)
        alert.addAction(keepAsReadonly)
        alert.addAction(redirectToImport)
        coordinator?.navigationController.present(alert, animated: true)
    }
    /*
     This alert is shown in case the user chooses to delete the identities with missing keys,
     but some of them still contain accounts with valid keys
     */
    private func showAlertForIdentitiesNotDeleted(failedToRemoveIdentities: [IdentityDataType], completion: @escaping () -> Void) {
        var message = "more.validateIdsAndAccount.idsWithFunctioningAccounts".localized
        for identity in failedToRemoveIdentities {
            message += String(format: "more.validateIdsAndAccount.identity".localized, identity.nickname)
        }
        
        let alert = UIAlertController(
            title: "more.validateIdsAndAccount.simpleWarningTitle".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "more.validateIdsAndAccount.okay".localized, style: .default) {  (_) in
            completion()
        }
        alert.addAction(okAction)
        coordinator?.navigationController.present(alert, animated: true)
    }
    
    private func showAllOkAlert() {
        let alert = UIAlertController(
            title: "more.validateIdsAndAccount.allOk.title".localized,
            message: "more.validateIdsAndAccount.allOk.description".localized,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "more.validateIdsAndAccount.okay".localized, style: .default) {  (_) in
        }
        alert.addAction(okAction)
        coordinator?.navigationController.present(alert, animated: true)
    }

    private func showBackupWarningAfterUpdate(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "backupafterupdate.alert.title".localized,
            message: "backupafterupdate.alert.message".localized,
            preferredStyle: .alert
        )

        let notNowAction = UIAlertAction(
            title: "backupafterupdate.alert.action.notnow".localized,
            style: .default,
            handler: { [weak self] _ in
                let areYouSureAlert = UIAlertController(
                    title: "accountfinalized.extrabackup.alert.title".localized,
                    message: "accountfinalized.extrabackup.alert.message".localized,
                    preferredStyle: .alert
                )

                let dismissAction = UIAlertAction(
                    title: "accountfinalized.extrabackup.alert.action.dismiss".localized,
                    style: .destructive,
                    handler: { _ in
                        AppSettings.needsBackupWarning = true
                        completion()
                    }
                )

                let makeBackupAction = UIAlertAction(
                    title: "accountfinalized.alert.action.backup".localized,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.delegate?.showExport()
                    }
                )

                areYouSureAlert.addAction(dismissAction)
                areYouSureAlert.addAction(makeBackupAction)

                self?.coordinator?.navigationController.present(areYouSureAlert, animated: true)
            }
        )

        let makeBackupAction = UIAlertAction(
            title: "accountfinalized.alert.action.backup".localized,
            style: .default,
            handler: { [weak self] _ in
                self?.delegate?.showExport()
            }
        )

        alert.addAction(notNowAction)
        alert.addAction(makeBackupAction)

        coordinator?.navigationController.present(alert, animated: true)
    }
}
