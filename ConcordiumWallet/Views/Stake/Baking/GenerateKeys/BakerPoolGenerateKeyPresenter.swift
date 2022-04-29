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

class BakerPoolGenerateKeyViewModel {
    @Published private(set) var title = "baking.generatekeys.title".localized
    @Published private(set) var info = "baking.generatekeys.info".localized
    @Published private(set) var electionKeyTitle = "baking.generatekeys.electionkey".localized
    @Published private(set) var electionKeyContent: String
    @Published private(set) var signatureKeyTitle = "baking.generatekeys.signaturekey".localized
    @Published private(set) var signatureKeyContent: String
    @Published private(set) var aggregationKeyTitle = "baking.generatekeys.aggregationkey".localized
    @Published private(set) var aggregationKeyContent: String
    
    let keyResult: Result<GeneratedBakerKeys, Error>
    
    fileprivate init(keyResult: Result<GeneratedBakerKeys, Error>) {
        self.keyResult = keyResult
        
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
    func shareExportedFile(url: URL, completion: @escaping (Bool) -> Void)
    func finishedGeneratingKeys(cost: GTU, energy: Int, dataHandler: StakeDataHandler)
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
    
    private let viewModel: BakerPoolGenerateKeyViewModel
    private let transactionService: TransactionsServiceProtocol
    private let stakeService: StakeServiceProtocol
    private let exportService: ExportService
    private let account: AccountDataType
    private let dataHandler: StakeDataHandler
    
    private var cancellables = Set<AnyCancellable>()

    init(
        delegate: BakerPoolGenerateKeyPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        account: AccountDataType,
        dataHandler: StakeDataHandler
    ) {
        self.delegate = delegate
        self.transactionService = dependencyProvider.transactionsService()
        self.stakeService = dependencyProvider.stakeService()
        self.exportService = dependencyProvider.exportService()
        self.account = account
        self.dataHandler = dataHandler
        self.viewModel = BakerPoolGenerateKeyViewModel(keyResult: dependencyProvider.stakeService().generateBakerKeys())
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        self.view?.showAlert(
            with: AlertOptions(
                title: "baking.generatekeys.notice.title".localized,
                message: "baking.generatekeys.notice.message".localized,
                actions: [
                    AlertAction(
                        name: "ok".localized,
                        completion: nil,
                        style: .default
                    )
                ]
            )
        )
    }
    
    func handleExport() {
        if case let .success(keys) = viewModel.keyResult {
            do {
                let exportedKeys = ExportedBakerKeys(bakerId: account.accountIndex, generatedKeys: keys)
                let fileUrl = try exportService.export(bakerKeys: exportedKeys)
                self.delegate?.shareExportedFile(url: fileUrl, completion: { completed in
                    guard completed else { return }
                    do {
                        self.dataHandler.add(entry: BakerKeyData(keys: keys))
                        try self.exportService.deleteBakerKeys()
                        self.transactionService.getTransferCost(
                            transferType: self.dataHandler.transferType,
                            costParameters: self.dataHandler.getCostParameters()
                        ).showLoadingIndicator(in: self.view)
                            .sink { (error: Error) in
                                self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                            } receiveValue: { (transferCost: TransferCost) in
                                self.delegate?.finishedGeneratingKeys(
                                    cost: GTU(intValue: Int(transferCost.cost) ?? 0),
                                    energy: transferCost.energy,
                                    dataHandler: self.dataHandler
                                )
                            }
                            .store(in: &self.cancellables)
                    } catch {
                        Logger.warn(error)
                        self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    }
                })
            } catch {
                Logger.error(error)
            }
        }
    }
    
    func handleClose() {
        delegate?.pressedClose()
    }
}
