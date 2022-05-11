//
//  BakerPoolSettingsPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 14/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum BakerPoolSetting: String {
    case open = "openForAll"
    case closedForNew = "closedForNew"
    case closed = "closedForAll"
    
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
    @Published var showsCloseForNew: Bool = false
    
    init(currentSettings: BakerPoolSetting?) {
        if let currentSettings = currentSettings {
            currentValue = String(format: "baking.poolsettings.current".localized, currentSettings.getDisplayValue())
            switch currentSettings {
            case .open:
                showsCloseForNew = true
                selectedPoolSettingIndex = 0
            case .closedForNew:
                showsCloseForNew = true
                selectedPoolSettingIndex = 1
            case .closed:
                selectedPoolSettingIndex = 1 // if the current state of the pool is closed, we don't show closed for new so the index is 1
            }
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
    func finishedPoolSettings(dataHandler: StakeDataHandler)
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
    var poolSettings: BakerPoolSetting
    var viewModel: BakerPoolSettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(delegate: BakerPoolSettingsPresenterDelegate? = nil, dataHandler: StakeDataHandler) {
        self.delegate = delegate
        self.dataHandler = dataHandler
        let poolSettingsData: BakerPoolSettingsData? = dataHandler.getCurrentEntry()
        self.poolSettings = poolSettingsData?.poolSettings ?? .open // default will be open
        self.viewModel = BakerPoolSettingsViewModel(currentSettings: poolSettingsData?.poolSettings)
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        self.view?.poolSettingPublisher.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] selectedOption in
            guard let self = self else { return }
            self.viewModel.selectedPoolSettingIndex = selectedOption
            switch selectedOption {
            case 0:
                self.poolSettings = .open
            case 1:
                if self.viewModel.showsCloseForNew {
                    self.poolSettings = .closedForNew
                } else {
                    self.poolSettings = .closed
                }
            case 2:
                self.poolSettings = .closed
            default:
                break
            }
            
        }).store(in: &cancellables)
    }
    
    func pressedContinue() {
        self.dataHandler.add(entry: BakerPoolSettingsData(poolSettings: poolSettings))
        switch dataHandler.transferType {
        case .registerBaker:
            self.delegate?.finishedPoolSettings(dataHandler: dataHandler)
        case .updateBakerPool:
            self.delegate?.finishedPoolSettings(dataHandler: dataHandler)
        default:
            break // Should never happen
        }
    }
    
    func pressedClose() {
        self.delegate?.closedPoolSettings()
    }
}
