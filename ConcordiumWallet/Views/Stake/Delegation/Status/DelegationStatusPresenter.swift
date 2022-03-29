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
    case newDelegationAmount(remainingCooldownInDays: Int, newDelegationAmount: GTU)
    case stoppedDelegation(remainingCooldownInDays: Int)
    case poolWasDeregistered(remainingCooldownInDays: Int)
}

// MARK: -
// MARK: Delegate
protocol DelegationStatusPresenterDelegate: AnyObject {
    func pressedStop(cost: GTU, energy: Int)
    func pressedRegisterOrUpdate()
}

class DelegationStatusPresenter: StakeStatusPresenterProtocol {

    weak var view: StakeStatusViewProtocol?
    weak var delegate: DelegationStatusPresenterDelegate?

    private var viewModel: StakeStatusViewModel
    private var dataHandler: StakeDataHandler
    private var transactionService: TransactionsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(dataHandler: StakeDataHandler,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         delegate: DelegationStatusPresenterDelegate? = nil) {
        self.transactionService = dependencyProvider.transactionsService()
        self.delegate = delegate
        self.dataHandler = dataHandler
        viewModel = StakeStatusViewModel(dataHandler: dataHandler)
        
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        //TODO: check for unfinishedTransactions and pending changes
        viewModel.setup(dataHandler: dataHandler, pendingChanges: .none, hasUnfinishedTransaction: false)
    }
    func pressedButton() {
        delegate?.pressedRegisterOrUpdate()
    }
    func pressedStopButton() {
        transactionService.getTransferCost(transferType: .removeDelegation, costParameters: [])
            .showLoadingIndicator(in: view).sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: {[weak self] transferCost in
                let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                self?.delegate?.pressedStop(cost: cost, energy: transferCost.energy)
            }.store(in: &cancellables)
    }
}

extension StakeStatusViewModel {
    func setup(dataHandler: StakeDataHandler, pendingChanges: PendingChanges, hasUnfinishedTransaction: Bool) {
        title = "delegation.status.title".localized
        stopButtonLabel = "delegation.status.stopbutton".localized
        if hasUnfinishedTransaction {
            topText = "delegation.status.waiting.header".localized
            placeholderText = "delegation.status.waiting.placeholder".localized
            updateButtonEnabled = false
            stopButtonEnabled = false
            return
        }
        if !dataHandler.hasCurrentData() {
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
            case .newDelegationAmount(let remainingCooldownInDays, let newDelegationAmount):
                gracePeriodText = String(format:"delegation.status.graceperiod".localized, remainingCooldownInDays)
                bottomInfoMessage = nil
                bottomImportantMessage = nil
                newAmountLabel = "delegation.status.newamount".localized
                newAmount = newDelegationAmount.displayValueWithGStroke()
                stopButtonEnabled = false
            case .stoppedDelegation(let remainingCooldownInDays):
                gracePeriodText = String(format:"delegation.status.graceperiod".localized, remainingCooldownInDays)
                bottomInfoMessage = "delegation.status.delegationwillstop".localized
                bottomImportantMessage = nil
                newAmount = nil
                newAmountLabel = nil
                stopButtonEnabled = false
            case .poolWasDeregistered(let remainingCooldownInDays):
                gracePeriodText = nil
                bottomInfoMessage = nil
                bottomImportantMessage =  String(format: "delegation.status.deregisteredcooldown".localized, remainingCooldownInDays)
                newAmount = nil
                newAmountLabel = nil
            }
        }
    }
}
