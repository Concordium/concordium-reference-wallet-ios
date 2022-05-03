//
//  BakerPoolMenuPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum BakerPoolMenuAction: CaseIterable, BurgerMenuAction {
    case updateBakerStake
    case updatePoolSettings
    case updateBakerKeys
    case stopBaking
    
    var destructive: Bool {
        return self == .stopBaking
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
    
    init(
        currentSettings: BakerDataType,
        poolInfo: PoolInfo,
        delegate: BakerPoolMenuPresenterDelegate? = nil
    ) {
        self.delegate = delegate
        self.viewModel = BurgerMenuViewModel()
        self.viewModel.setup(actions: BakerPoolMenuAction.allCases)
        self.currentSettings = currentSettings
        self.poolInfo = poolInfo
    }
    
    func viewDidLoad() {
        self.view?.bind(to: viewModel)
    }
    
    func pressedDismiss() {
        self.delegate?.pressedDismiss()
    }
    
    func selectedAction(at index: Int) {
        guard index > 0 && index < BakerPoolMenuAction.allCases.count else {
            return
        }
        
        self.delegate?.pressed(
            action: BakerPoolMenuAction.allCases[index],
            currentSettings: currentSettings,
            poolInfo: poolInfo
        )
    }
}
