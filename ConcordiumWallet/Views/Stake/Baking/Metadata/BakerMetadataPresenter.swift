//
//  BakerMetadataPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 21/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// Add this to your coordinator:
//    func showBakerMetadata() {
//        let vc = BakerMetadataFactory.create(with: BakerMetadataPresenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }

// MARK: -
// MARK: Delegate
protocol BakerMetadataPresenterDelegate: AnyObject {
    func finishedMetadata(dataHandler: StakeDataHandler)
    func closedMetadata()
}

class BakerMetadataViewModel {
    @Published var title: String
    @Published var text: NSAttributedString
    @Published var placeholder: String
    @Published var currentValueLabel: String?
    @Published var currentValue: String
    
    init(currentMetadataUrl: String?) {
        placeholder = "baking.metadata.placeholder".localized
        if let currentMetadataUrl = currentMetadataUrl {
            currentValue = currentMetadataUrl
            currentValueLabel = String(format: "baking.metadata.current".localized, currentMetadataUrl)
            title = "baking.metadata.title.update".localized
            text = "baking.metadata.text.update"
                .localized
                .stringWithHighlightedLinks(["developer.concordium.software": "https://developer.concordium.software"])
        } else {
            currentValue = ""
            title = "baking.metadata.title.create".localized
            text = "baking.metadata.text.create"
                .localized
                .stringWithHighlightedLinks(["developer.concordium.software": "https://developer.concordium.software"])
        }
    }
}

// MARK: -
// MARK: Presenter
protocol BakerMetadataPresenterProtocol: AnyObject {
	var view: BakerMetadataViewProtocol? { get set }
    func viewDidLoad()
    func pressedContinue()
    func pressedClose()
}

class BakerMetadataPresenter: BakerMetadataPresenterProtocol {
    weak var view: BakerMetadataViewProtocol?
    weak var delegate: BakerMetadataPresenterDelegate?
    private let dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: BakerMetadataViewModel
    
    init(delegate: BakerMetadataPresenterDelegate? = nil, dataHandler: StakeDataHandler) {
        self.dataHandler = dataHandler
        self.delegate = delegate
        
        let currentValue: BakerMetadataURLData? = dataHandler.getCurrentEntry()
        viewModel = BakerMetadataViewModel(currentMetadataUrl: currentValue?.metadataURL)
    }

    func viewDidLoad() {
        view?.bind(viewModel: viewModel)
    }
    
    func pressedContinue() {
        self.dataHandler.add(entry: BakerMetadataURLData(metadataURL: viewModel.currentValue))
        
        if dataHandler.containsChanges() || dataHandler.transferType == .registerBaker {
            self.delegate?.finishedMetadata(dataHandler: dataHandler)
        } else {
            self.view?.showAlert(with: BakingAlerts.noChanges)
        }
    }
    
    func pressedClose() {
        self.delegate?.closedMetadata()
    }
}
