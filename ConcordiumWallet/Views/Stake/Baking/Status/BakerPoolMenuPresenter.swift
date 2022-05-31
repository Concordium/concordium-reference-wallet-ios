//
//  BakerPoolMenuPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum BakerPoolMenuAction: BurgerMenuAction {
    case updateBakerStake
    case updatePoolSettings
    case updateBakerKeys
    case stopBaking(isOnCooldown: Bool)
    
    var destructive: Bool {
        if case .stopBaking = self {
            return true
        } else {
            return false
        }
    }
    
    var enabled: Bool {
        if case .stopBaking(true) = self {
            return false
        } else {
            return true
        }
    }
    
    func getDisplayName() -> String {
        switch self {
        case .updateBakerStake:
            return "baking.menu.updatebakerstake".localized
        case .updatePoolSettings:
            return "baking.menu.updatepoolsettings".localized
        case .updateBakerKeys:
            return "baking.menu.updatebakerkeys".localized
        case .stopBaking:
            return "baking.menu.stopbaking".localized
        }
    }
}

protocol BakerPoolMenuPresenterDelegate: AnyObject {
    func pressed(
        action: BakerPoolMenuAction,
        currentSettings: BakerDataType,
        poolInfo: PoolInfo
    )
    func pressedDismiss()
}

class BakerPoolMenuPresenter: BurgerMenuPresenterProtocol {
    weak var view: BurgerMenuViewProtocol?
    weak var delegate: BakerPoolMenuPresenterDelegate?
    
    private let viewModel: BurgerMenuViewModel
    
    private let currentSettings: BakerDataType
    private let poolInfo: PoolInfo
    
    private let stakeService: StakeServiceProtocol
    private let storageManager: StorageManagerProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var actions: [BakerPoolMenuAction] = {
        [
            .updateBakerStake,
            .updatePoolSettings,
            .updateBakerKeys,
            .stopBaking(
                isOnCooldown: currentSettings.pendingChange?.change != .NoChange
            )
        ]
    }()
    
    init(
        currentSettings: BakerDataType,
        poolInfo: PoolInfo,
        delegate: BakerPoolMenuPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider
    ) {
        self.delegate = delegate
        self.viewModel = BurgerMenuViewModel()
        self.currentSettings = currentSettings
        self.poolInfo = poolInfo
        self.stakeService = dependencyProvider.stakeService()
        self.storageManager = dependencyProvider.storageManager()
        self.viewModel.setup(actions: actions)
    }
    
    func viewDidLoad() {
        self.view?.bind(to: viewModel)
    }
    
    func pressedDismiss() {
        self.delegate?.pressedDismiss()
    }
    
    func selectedAction(at index: Int) {
        guard index >= 0 && index < actions.count else {
            return
        }
        
        let action = actions[index]
        
        stakeService.getChainParameters()
            .first()
            .showLoadingIndicator(in: self.view)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] chainParameters in
                guard let self = self else { return }
                let params = ChainParametersEntity(
                    delegatorCooldown: chainParameters.delegatorCooldown,
                    poolOwnerCooldown: chainParameters.poolOwnerCooldown
                )
                
                do {
                    _ = try self.storageManager.updateChainParms(params)
                    self.delegate?.pressed(
                        action: action,
                        currentSettings: self.currentSettings,
                        poolInfo: self.poolInfo
                    )
                } catch {
                    self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            }
            .store(in: &cancellables)
    }
}
