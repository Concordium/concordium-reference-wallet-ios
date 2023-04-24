//
//  ExportPrivateKeyPresenter.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 15.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

protocol ExportPrivateKeyPresenterDelegate: RequestPasswordDelegate {
    func finishedExportingPrivateKey()
    func shareExportedFile(url: URL, completion: @escaping (Bool) -> Void)
}

class ExportPrivateKeyPresenter: SwiftUIPresenter<ExportPrivateKeyViewModel> {
    private let account: AccountDataType
    private weak var delegate: ExportPrivateKeyPresenterDelegate?
    private var privateKey: AccountKeys!
    private let exportService: ExportService
    
    init(
        account: AccountDataType,
        delegate: ExportPrivateKeyPresenterDelegate
    ) {
        self.account = account
        self.delegate = delegate
        
        let defaultProvider = ServicesProvider.defaultProvider()
        self.exportService = defaultProvider.exportService()
        
        super.init(
            viewModel: .init(
                title: "exportprivatekey.title".localized,
                exportPrivateKey: .hidden(topMessage: "exportprivatekey.toprevealmessage".localized, downMessage: String(format: ("exportprivatekey.downrevealmessage".localized), account.displayName)),
                doneButtonTitle: "exportprivatekey.done".localized
            )
        )
        
        viewModel.navigationTitle = "exportprivatekey.navigationtitle".localized
    }
    
    override func receive(event: ExportPrivateKeyEvent) {
        Task {
            switch event {
            case .showPrivateKey:
                let keychain: KeychainWrapper = KeychainWrapper()
                let pwHash = try await delegate?.requestUserPassword(keychain: keychain)
                privateKey = try getPrivateAccountKeys(for: account, pwHash: pwHash!).get()
                let signKey = privateKey.keys[0]?.keys[0]?.signKey ?? ""
                
                viewModel.exportPrivateKey = .shown(privateKey: signKey, topMessage: "exportprivatekey.toprevealmessage".localized, exportButtonTitle: "exportprivatekey.export".localized)
            case .copyTapped:
                UIPasteboard.general.string = privateKey.keys[0]?.keys[0]?.signKey ?? ""
                viewModel.alertText = AlertText(text: "exportprivatekey.copied".localized)
            case .exportTapped:
                handleExport(with: privateKey, address: account.address, credential: account.credential)
            case .doneTapped:
                delegate?.finishedExportingPrivateKey()
            }
        }
    }
    
    private func getPrivateAccountKeys(for account: AccountDataType, pwHash: String) -> Result<AccountKeys, Error> {
        let keychain: KeychainWrapper = KeychainWrapper()
        let storageManager: StorageManager = StorageManager(keychain: keychain)
        guard let key = account.encryptedAccountData else { return .failure(MobileWalletError.invalidArgument) }
        return storageManager.getPrivateAccountKeys(key: key, pwHash: pwHash)
                .mapError { $0 as Error }
    }
    
    private func handleExport(with privateKey: AccountKeys, address: String, credential: Credential?) {
        guard let credential = credential else {
            print("Account credential does not exist.")
            
            return
        }
        
        do {
            let exportedKeys = ExportedAccountPrivateKeys(privateKey: privateKey, address: address, credential: credential)
            let fileUrl = try exportService.export(accountPrivateKeys: exportedKeys, forAccountWithAddress: account.address)
            
            self.delegate?.shareExportedFile(url: fileUrl, completion: { completed in
                guard completed else { return }
                do {
                    try self.exportService.deleteAccountPrivateKeys(forAccountWithAddress: self.account.address)
                    self.viewModel.alertText = AlertText(text: "exportprivatekey.exported".localized)
                } catch {
                    Logger.warn(error)
                }
            })
        } catch {
            Logger.error(error)
        }
    }
}
