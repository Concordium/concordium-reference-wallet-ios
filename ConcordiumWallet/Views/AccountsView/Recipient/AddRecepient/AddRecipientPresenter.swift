//
//  AddRecipientPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/14/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum EditRecipientMode {
    case add
    case edit(recipient: RecipientDataType)
}

// MARK: View
protocol AddRecipientViewProtocol: ShowAlert {
    func bind(to: AddRecipientViewModel)
    func showAddressInvalid()
}

// MARK: -
// MARK: Delegate
protocol AddRecipientPresenterDelegate: AnyObject {
    func addRecipientDidSelectSave(recipient: RecipientDataType)
    func addRecipientDidSelectQR()
}

// MARK: -
// MARK: Presenter
protocol AddRecipientPresenterProtocol: AnyObject {
	var view: AddRecipientViewProtocol? { get set }
    func viewDidLoad()
    
    func calculateSaveButtonState(name: String, address: String)
    
    func userTappedSave(name: String, address: String)
    func userTappedQR()
    func setAccountAddress(_: String)
}

class AddRecipientViewModel {
    @Published var address: String = ""
    @Published var name: String = ""
    @Published var title: String = ""
    @Published var enableSave = false
}

class AddRecipientPresenter {

    weak var view: AddRecipientViewProtocol?
    weak var delegate: AddRecipientPresenterDelegate?
    var viewModel = AddRecipientViewModel()
    
    private var mode: EditRecipientMode = .add

    private var storageManager: StorageManagerProtocol
    private var wallet: MobileWalletProtocol

    init(delegate: AddRecipientPresenterDelegate? = nil,
         dependencyProvider: WalletAndStorageDependencyProvider,
         mode: EditRecipientMode) {
        self.delegate = delegate
        self.storageManager = dependencyProvider.storageManager()
        self.wallet = dependencyProvider.mobileWallet()
        self.mode = mode
        switch mode {
            case .add:
                viewModel.title = "addRecipient.title".localized
                viewModel.enableSave = true
            case .edit(let recipient):
                viewModel.title = "editAddress.title".localized
                viewModel.name = recipient.name
                viewModel.address = recipient.address
        }
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}

extension AddRecipientPresenter: AddRecipientPresenterProtocol {
    func userTappedSave(name: String, address: String) {

        let qrValid = wallet.check(accountAddress: address)
        if !qrValid {
            view?.showAddressInvalid()
            return
        }

        var newRecipient = RecipientDataTypeFactory.create()
        newRecipient.name = name
        newRecipient.address = address
        
        switch mode {
        case .add:
            if let existingRecipient = storageManager.getRecipient(withAddress: address) {
                view?.showErrorAlert(ViewError.duplicateRecipient(name: existingRecipient.name))
                return
            }
        default: break
        }

        switch mode {
            case .add:
                do {
                    try storageManager.storeRecipient(newRecipient)
                    delegate?.addRecipientDidSelectSave(recipient: newRecipient)
                } catch let error {
                    view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }
            case .edit(let recipient):
                do {
                    try storageManager.editRecipient(oldRecipient: recipient, newRecipient: newRecipient)
                    delegate?.addRecipientDidSelectSave(recipient: newRecipient)
                } catch let error {
                    view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }
        }
    }
    
    func userTappedQR() {
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            
            guard permissionGranted else {
                self.view?.showRecoverableErrorAlert(
                    .cameraAccessDeniedError,
                    recoverActionTitle: "errorAlert.continueButton".localized,
                    hasCancel: true
                ) {
                    SettingsHelper.openAppSettings()
                }
                return
            }

            self.delegate?.addRecipientDidSelectQR()
        }
    }

    func setAccountAddress(_ address: String) {
        viewModel.address = address
    }
    
    func calculateSaveButtonState(name: String, address: String) {
        switch mode {
            case .add:
                viewModel.enableSave = !name.isEmpty && !address.isEmpty
            case .edit(let recipient):
                viewModel.enableSave = (name != recipient.name) || (address != recipient.address)
                                         && (!name.isEmpty && !address.isEmpty)
        }
    }
}
