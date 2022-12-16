//
//  ExportPrivateKeyPresenter.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 15.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

protocol ExportPrivateKeyPresenterDelegate: RequestPasswordDelegate {
    func exportPrivateKey(with privateKey: String)
    func finishedExportingPrivateKey(with privateKey: String)
}

class ExportPrivateKeyPresenter: SwiftUIPresenter<ExportPrivateKeyViewModel> {
    private let account: AccountDataType
    private weak var delegate: ExportPrivateKeyPresenterDelegate?
    private var privateKey = ""
    
    init(
        account: AccountDataType,
        delegate: ExportPrivateKeyPresenterDelegate
    ) {
        self.account = account
        self.delegate = delegate
        
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
                let privateAccountKeys = try getPrivateAccountKeys(for: account, pwHash: pwHash!).get()
                privateKey = privateAccountKeys.keys[0]?.keys[0]?.signKey ?? ""
                
                viewModel.exportPrivateKey = .shown(privateKey: privateKey, topMessage: "exportprivatekey.toprevealmessage".localized, exportButtonTitle: "exportprivatekey.export".localized)
            case .copyTapped:
                UIPasteboard.general.string = privateKey
                viewModel.alertText = AlertText(text: "exportprivatekey.copied".localized)
            case .exportTapped:
                delegate?.exportPrivateKey(with: privateKey)
            case .doneTapped:
                delegate?.finishedExportingPrivateKey(with: privateKey)
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
}
