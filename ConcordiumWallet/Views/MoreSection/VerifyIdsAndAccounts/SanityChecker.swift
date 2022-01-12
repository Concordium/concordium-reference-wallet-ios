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

class SanityChecker {
    var keychainWrapper: KeychainWrapperProtocol
    var errorDisplayer: ShowAlert
    var mobileWallet: MobileWalletProtocol
    var storageManager: StorageManagerProtocol
   
    weak var requestPasswordDelegate: RequestPasswordDelegate?
    weak var coordinator: Coordinator?
    
    private var cancellables: [AnyCancellable] = []
    
    init(requestPasswordDelegate: RequestPasswordDelegate,
         keychainWrapper: KeychainWrapperProtocol,
         mobileWallet: MobileWalletProtocol,
         storageManager: StorageManagerProtocol,
         errorDisplayer: ShowAlert,
         coordinator: Coordinator) {
        self.requestPasswordDelegate = requestPasswordDelegate
        self.keychainWrapper = keychainWrapper
        self.errorDisplayer = errorDisplayer
        self.mobileWallet = mobileWallet
        self.coordinator = coordinator
        self.storageManager = storageManager
    }
    
    public func requestPwAndCheckSanity() {
        requestPasswordDelegate?.requestUserPassword(keychain: keychainWrapper)
            .sink(receiveError: { [weak self] error in
                if case GeneralError.userCancelled = error { return }
                self?.errorDisplayer.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] pwHash in
                guard let self = self else { return }
                self.checkSanity(pwHash: pwHash)
            }).store(in: &cancellables)
    }
    
    public func checkSanity(pwHash: String) {
        let report = self.mobileWallet.verifyIdentitiesAndAccounts(pwHash: pwHash)
        self.showValidateIdentitiesAlert(report: report)
    }
    
    private func showValidateIdentitiesAlert(report: [(IdentityDataType, [AccountDataType])]) {
        var message = "more.validateIdsAndAccount.unusableIdentitiesFound".localized
        for (identity, accounts) in report {
            message += String(format: "more.validateIdsAndAccount.identity".localized, identity.nickname)
            for account in accounts {
                message += String(format: "more.validateIdsAndAccount.account".localized, (account.name ?? ""))
            }
        }
        
        let alert = UIAlertController(
            title: "more.validateIdsAndAccount.warningTitle".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(title: "more.validateIdsAndAccount.removeFromApp".localized, style: .destructive) { (_) in
//            completion()
        }
       
        let remindMeLater = UIAlertAction(title: "more.validateIdsAndAccount.remindLater".localized, style: .default) { (_) in
//            completion()
        }
        
        let keepAsReadonly = UIAlertAction(title: "more.validateIdsAndAccount.keep".localized, style: .cancel) { (_) in
//            completion()
        }
        
        alert.addAction(removeAction)
        alert.addAction(remindMeLater)
        alert.addAction(keepAsReadonly)
        
        coordinator?.navigationController.present(alert, animated: true)
    }
    
    private func removeIdentitiesAndAccountsWithoutKeys(report: [(IdentityDataType, [AccountDataType])]) {
        for (identity, accounts) in report {
            for account in accounts {
                self.storageManager.removeAccount(account: account)
            }
            self.storageManager.removeIdentity(identity)
        }
    }
    
    private func remindMeLater() {
        //TODO: mark accounts as read-only and remind user later
    }
    
    private func keepAsReadOnly() {
        //TODO: mark accounts as read-only and set a flag not to check this at login
    }
}
