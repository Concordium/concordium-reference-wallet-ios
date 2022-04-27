//
//  DelegationStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum PendingChanges {
    case none
    case newDelegationAmount(coolDownEndTimestamp: String, newDelegationAmount: GTU)
    case stoppedDelegation(coolDownEndTimestamp: String)
    case poolWasDeregistered(coolDownEndTimestamp: String)
}

// MARK: -
// MARK: Delegate
protocol DelegationStatusPresenterDelegate: AnyObject {
    func pressedStop(cost: GTU, energy: Int)
    func pressedRegisterOrUpdate()
    func pressedClose()
}

class DelegationStatusPresenter: StakeStatusPresenterProtocol {

    weak var view: StakeStatusViewProtocol?
    weak var delegate: DelegationStatusPresenterDelegate?

    private var account: AccountDataType
    private var viewModel: StakeStatusViewModel
    private var dataHandler: StakeDataHandler
    private var transactionService: TransactionsServiceProtocol
    private var stakeService: StakeServiceProtocol
    private var accountsService: AccountsServiceProtocol
    private var storageManager: StorageManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(account: AccountDataType,
         dataHandler: StakeDataHandler,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         delegate: DelegationStatusPresenterDelegate? = nil) {
        self.account = account
        self.transactionService = dependencyProvider.transactionsService()
        self.stakeService = dependencyProvider.stakeService()
        self.storageManager = dependencyProvider.storageManager()
        self.accountsService = dependencyProvider.accountsService()
        self.delegate = delegate
        self.dataHandler = dataHandler
        viewModel = StakeStatusViewModel()
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        checkForPendingChanges()
    }
    
    func pressedButton() {
        stakeService.getChainParameters()
            .showLoadingIndicator(in: self.view)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] chainParametersResponse in
                let params = ChainParametersEntity(delegatorCooldown: chainParametersResponse.delegatorCooldown,
                                                   poolOwnerCooldown: chainParametersResponse.poolOwnerCooldown)
                do {
                    _ = try self?.storageManager.updateChainParms(params)
                    self?.delegate?.pressedRegisterOrUpdate()
                } catch let error {
                    self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            }.store(in: &cancellables)
    }

    func pressedStopButton() {
        stakeService.getChainParameters()
            .zip(transactionService.getTransferCost(transferType: .removeDelegation, costParameters: []))
            .showLoadingIndicator(in: view)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: {[weak self] (chainParametersResponse, transferCost) in
                let params = ChainParametersEntity(delegatorCooldown: chainParametersResponse.delegatorCooldown,
                                                   poolOwnerCooldown: chainParametersResponse.poolOwnerCooldown)
                do {
                    _ = try self?.storageManager.updateChainParms(params)
                    let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                    self?.delegate?.pressedStop(cost: cost, energy: transferCost.energy)
                } catch let error {
                    self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            }.store(in: &cancellables)
    }
    
    func checkForPendingChanges() {
        let transfers = self.storageManager.getTransfers(for: account.address).filter { transfer in
            transfer.transferType == .removeDelegation || transfer.transferType == .updateDelegation || transfer.transferType == .registerDelegation
        }
        
        if transfers.count > 0 {
            self.viewModel.setup(dataHandler: self.dataHandler, pendingChanges: .none, hasUnfinishedTransaction: true)
        } else {
            let pendingChanges: PendingChanges
            if let accountPendingChange = self.account.delegation?.pendingChange {
                switch accountPendingChange.change {
                case .NoChange:
                    pendingChanges = .none
                case .ReduceStake:
                    pendingChanges = .newDelegationAmount(coolDownEndTimestamp: accountPendingChange.effectiveTime ?? "",
                                                          newDelegationAmount: GTU(intValue: Int(accountPendingChange.updatedNewStake ?? "0") ?? 0))
                case .RemoveStake:
                    pendingChanges = .stoppedDelegation(coolDownEndTimestamp: accountPendingChange.effectiveTime ?? "")
                }
            } else {
                if let bakerId = self.account.delegation?.delegationTargetBakerID, bakerId != -1 {
                    // if we delegate to a baker pool, we make sure it was not stopped
                    self.stakeService.getBakerPool(bakerId: bakerId).sink { error in
                        self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    } receiveValue: { bakerPoolResponse in
                        if bakerPoolResponse.bakerStakePendingChange.pendingChangeType == "RemovePool" {
                            let effectiveTime = bakerPoolResponse.bakerStakePendingChange.effectiveTime ?? ""
                            self.viewModel.setup(dataHandler: self.dataHandler,
                                                 pendingChanges: .poolWasDeregistered(coolDownEndTimestamp: effectiveTime),
                                                 hasUnfinishedTransaction: false)
                        }
                    }.store(in: &cancellables)
                    return
                } else {
                    pendingChanges = .none
                }
            }
            self.viewModel.setup(dataHandler: self.dataHandler, pendingChanges: pendingChanges, hasUnfinishedTransaction: false)
        }
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

extension StakeStatusViewModel {
    // swiftlint:disable function_body_length
    func setup(dataHandler: StakeDataHandler,
               pendingChanges: PendingChanges,
               hasUnfinishedTransaction: Bool) {
        setup(dataHandler: dataHandler)
        title = "delegation.status.title".localized
        stopButtonLabel = "delegation.status.stopbutton".localized
        topImageName = "confirm"
        if hasUnfinishedTransaction {
            topImageName = "logo_rotating_arrows"
            topText = "delegation.status.waiting.header".localized
            placeholderText = "delegation.status.waiting.placeholder".localized
            buttonLabel = "delegation.status.updatebutton".localized
            updateButtonEnabled = false
            stopButtonEnabled = false
            rows.removeAll()
            return
        }
        if !dataHandler.hasCurrentData() {
            topImageName = "logo_rotating_arrows"
            topText = "delegation.status.nodelegation.header".localized
            placeholderText = "delegation.status.nodelegation.placeholder".localized
            buttonLabel = "delegation.status.registerbutton".localized
            stopButtonShown = false
            rows.removeAll()
        } else {
            topText = "delegation.status.registered.header".localized
            buttonLabel = "delegation.status.updatebutton".localized
            switch pendingChanges {
            case .none:
                gracePeriodText = nil
                bottomInfoMessage = nil
                bottomImportantMessage = nil
                newAmount = nil
                newAmountLabel = nil
            case .newDelegationAmount(let cooldownTimestampUTC, let newDelegationAmount):
                gracePeriodText = String(format: "delegation.status.graceperiod".localized,
                                         GeneralFormatter.formatDateWithTime(for: GeneralFormatter.dateFrom(timestampUTC: cooldownTimestampUTC)))
                bottomInfoMessage = nil
                bottomImportantMessage = nil
                newAmountLabel = "delegation.status.newamount".localized
                newAmount = newDelegationAmount.displayValueWithGStroke()
                stopButtonEnabled = false
            case .stoppedDelegation(let cooldownTimestampUTC):
                gracePeriodText = String(format: "delegation.status.graceperiod".localized,
                                         GeneralFormatter.formatDateWithTime(for: GeneralFormatter.dateFrom(timestampUTC: cooldownTimestampUTC)))
                bottomInfoMessage = "delegation.status.delegationwillstop".localized
                bottomImportantMessage = nil
                newAmount = nil
                newAmountLabel = nil
                stopButtonEnabled = false
            case .poolWasDeregistered(let cooldownTimestampUTC):
                gracePeriodText = nil
                bottomInfoMessage = nil
                bottomImportantMessage =  String(format: "delegation.status.deregisteredcooldown".localized,
                                        GeneralFormatter.formatDateWithTime(for: GeneralFormatter.dateFrom(timestampUTC: cooldownTimestampUTC)))
                newAmount = nil
                newAmountLabel = nil
            }
        }
    }
}
