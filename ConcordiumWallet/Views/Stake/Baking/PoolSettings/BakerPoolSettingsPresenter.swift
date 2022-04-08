//
//  BakerPoolSettingsPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 14/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum BakerPoolSetting {
    case open
    case closedForNew
    case closed
    
    func getDisplayValue() -> String {
        switch self {
        case .open:
            return "baking.open".localized
        case .closedForNew:
            return "baking.closedfornew".localized
        case .closed:
            return "baking.closed".localized
        }
    }
}

class BakerPoolSettingsViewModel {
    @Published var title: String
    @Published var text: String
    @Published var selectedPoolSettingIndex: Int = 0
    @Published var currentValue: String?
    
    init(currentSettings: BakerPoolSetting?) {
        if let currentSettings = currentSettings {
            currentValue = String(format: "baking.poolsettings.current".localized, currentSettings.getDisplayValue())
            title = "baking.poolsettings.title.update".localized
            text = "baking.poolsettings.text.update".localized
        } else {
            title = "baking.poolsettings.title.create".localized
            text = "baking.poolsettings.text.create".localized
        }
    }
    
}

// MARK: -
// MARK: Delegate
protocol BakerPoolSettingsPresenterDelegate: AnyObject {
    func finishedPoolSettings()
    func closedPoolSettings()
}

// MARK: -
// MARK: Presenter
protocol BakerPoolSettingsPresenterProtocol: AnyObject {
	var view: BakerPoolSettingsViewProtocol? { get set }
    func viewDidLoad()
    func pressedContinue()
    func pressedClose()
}

class BakerPoolSettingsPresenter: BakerPoolSettingsPresenterProtocol {
    
    weak var view: BakerPoolSettingsViewProtocol?
    weak var delegate: BakerPoolSettingsPresenterDelegate?
    var dataHandler: StakeDataHandler
    
    var viewModel: BakerPoolSettingsViewModel
    
    init(delegate: BakerPoolSettingsPresenterDelegate? = nil, dataHandler: StakeDataHandler) {
        self.delegate = delegate
        self.dataHandler = dataHandler
        let poolSettingsData: BakerPoolSettingsData? = dataHandler.getCurrentEntry()
        self.viewModel = BakerPoolSettingsViewModel(currentSettings: poolSettingsData?.poolSettings)
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    func pressedContinue() {
        self.delegate?.finishedPoolSettings()
    }
    
    func pressedClose() {
        self.delegate?.closedPoolSettings()
    }
}
