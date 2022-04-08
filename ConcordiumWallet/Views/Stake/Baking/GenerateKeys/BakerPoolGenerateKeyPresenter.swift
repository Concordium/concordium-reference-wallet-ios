//
//  BakerPoolGenerateKeyPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 07/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// Add this to your coordinator:
//    func showBakerPoolGenerateKey() {
//        let vc = BakerPoolGenerateKeyFactory.create(with: BakerPoolGenerateKeyPresenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }

enum BakerPoolGenerateKeyAction {
    case export
    case close
}

class BakerPoolGenerateKeyViewModel {
    @Published private(set) var title: String
    @Published private(set) var info: String
    @Published private(set) var electionKeyTitle: String
    @Published private(set) var electionKeyContent: String
    @Published private(set) var signatureKeyTitle: String
    @Published private(set) var signatureKeyContent: String
    @Published private(set) var aggregationKeyTitle: String
    @Published private(set) var aggregationKeyContent: String
    
    fileprivate init(keyResult: Result<GeneratedBakerKeys, Error>) {
        title = "baking.generatekeys.title".localized
        info = "baking.generatekeys.info".localized
        electionKeyTitle = "baking.generatekeys.electionkey".localized
        signatureKeyTitle = "baking.generatekeys.signaturekey".localized
        aggregationKeyTitle = "baking.generatekeys.aggregationkey".localized
        
        if case let .success(keys) = keyResult {
            electionKeyContent = keys.electionVerifyKey.splitInto(lines: 2)
            signatureKeyContent = keys.signatureVerifyKey.splitInto(lines: 2)
            aggregationKeyContent = keys.aggregationVerifyKey.splitInto(lines: 6)
        } else {
            electionKeyContent = ""
            signatureKeyContent = ""
            aggregationKeyContent = ""
        }
    }
}

// MARK: -
// MARK: Delegate
protocol BakerPoolGenerateKeyPresenterDelegate: AnyObject {
    func pressedClose()
    func pressedExportKeys(keys: GeneratedBakerKeys)
}

// MARK: -
// MARK: Presenter
protocol BakerPoolGenerateKeyPresenterProtocol: AnyObject {
	var view: BakerPoolGenerateKeyViewProtocol? { get set }
    func viewDidLoad()
    
    func handleExport()
    func handleClose()
}

class BakerPoolGenerateKeyPresenter: BakerPoolGenerateKeyPresenterProtocol {

    weak var view: BakerPoolGenerateKeyViewProtocol?
    weak var delegate: BakerPoolGenerateKeyPresenterDelegate?
    
    private var viewModel: BakerPoolGenerateKeyViewModel
    private let keys: Result<GeneratedBakerKeys, Error>

    init(
        delegate: BakerPoolGenerateKeyPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider
    ) {
        self.delegate = delegate
        let generatedKeys = dependencyProvider.mobileWallet().generateBakerKeys()
        self.keys = generatedKeys
        self.viewModel = BakerPoolGenerateKeyViewModel(keyResult: generatedKeys)
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        self.view?.showAlert(
            with: AlertOptions(
                title: "baking.generatekeys.notice.title".localized,
                message: "baking.generatekeys.notice.message".localized,
                actions: [
                    AlertAction(
                        name: "OK".localized,
                        completion: nil,
                        style: .default
                    )
                ]
            )
        )
    }
    
    func handleExport() {
        if case let .success(keys) = self.keys {
            delegate?.pressedExportKeys(keys: keys)
        }
    }
    
    func handleClose() {
        delegate?.pressedClose()
    }
}
