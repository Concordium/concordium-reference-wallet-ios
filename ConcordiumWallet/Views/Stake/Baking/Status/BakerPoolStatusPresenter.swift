//
//  BakerPoolStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum BakerPoolStatus {
    case pendingRegistration
    case registered(currentSettings: BakerDataType)
}

protocol BakerPoolStatusPresenterDelegate: AnyObject {
    func pressedOpenMenu(currentSettings: BakerDataType, poolInfo: PoolInfo)
    func pressedClose()
}

class BakerPoolStatusPresenter: StakeStatusPresenterProtocol {
    
    weak var view: StakeStatusViewProtocol?
    weak var delegate: BakerPoolStatusPresenterDelegate?
    
    private let viewModel: StakeStatusViewModel
    private let account: AccountDataType
    private let status: BakerPoolStatus
    private var poolInfo: PoolInfo?
    private let stakeService: StakeServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        account: AccountDataType,
        status: BakerPoolStatus,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        delegate: BakerPoolStatusPresenterDelegate? = nil
    ) {
        self.viewModel = StakeStatusViewModel()
        self.delegate = delegate
        self.account = account
        self.status = status
        self.stakeService = dependencyProvider.stakeService()
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        if case let .registered(currentSettings) = status {
            stakeService.getBakerPool(bakerId: currentSettings.bakerID)
                .showLoadingIndicator(in: self.view)
                .sink { [weak self] error in
                    self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                } receiveValue: { [weak self] bakerPoolResponse in
                    guard let self = self else { return }
                    self.poolInfo = bakerPoolResponse.poolInfo
                    self.viewModel.setup(
                        withAccount: self.account,
                        currentSettings: currentSettings,
                        poolInfo: bakerPoolResponse.poolInfo
                    )
                }
                .store(in: &cancellables)

        } else {
            viewModel.setupPending(withAccount: account)
        }
    }
    
    func pressedButton() {
        if let poolInfo = poolInfo, case let .registered(currentSettings) = status {
            self.delegate?.pressedOpenMenu(currentSettings: currentSettings, poolInfo: poolInfo)
        }
    }
    
    func pressedStopButton() {
        // Stop button is not available
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }

}

private extension StakeStatusViewModel {
    func setup(
        withAccount account: AccountDataType,
        currentSettings: BakerDataType,
        poolInfo: PoolInfo
    ) {
        var updatedRows: [FieldValue] = [
            BakerAccountData(accountAddress: account.address),
            BakerAmountData(amount: GTU(intValue: currentSettings.stakedAmount)),
            BakerIDData(id: currentSettings.bakerID),
            RestakeBakerData(restake: currentSettings.restakeEarnings)
        ]
        
        if let poolSetting = BakerPoolSetting(rawValue: poolInfo.openStatus) {
            updatedRows.append(BakerPoolSettingsData(poolSettings: poolSetting))
        }

        title = "baking.status.title".localized
        topImageName = "confirm"
        topText = "baking.status.registered.header".localized
        placeholderText = nil
        
        buttonLabel = "baking.status.updatebutton".localized
        updateButtonEnabled = true
        stopButtonShown = false
        if let pendingChange = currentSettings.pendingChange, let timestamp = pendingChange.effectiveTime, pendingChange.change == .RemoveStake {
            bottomInfoMessage = String(
                format: "baking.status.pendingchange".localized,
                GeneralFormatter.formatDateWithTime(for: GeneralFormatter.dateFrom(timestampUTC: timestamp))
            )
            bottomImportantMessage = "baking.status.removingbaker".localized
        }
        rows = updatedRows.flatMap { $0.displayValues.map { StakeRowViewModel(displayValue: $0) } }
    }
    
    func setupPending(withAccount account: AccountDataType) {
        title = "baking.status.title".localized
        topImageName = "logo_rotating_arrows"
        topText = "baking.status.waiting.header".localized
        placeholderText = "baking.status.waiting.placeholder".localized
        
        buttonLabel = "baking.status.updatebutton".localized
        updateButtonEnabled = false
        stopButtonShown = false
        rows = []
    }
}
