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
    @Published var text: String
    @Published var currentValue: String?
    
    init(currentMetadataUrl: String?) {
        if let currentMetadataUrl = currentMetadataUrl {
            currentValue = String(format: "baking.metadata.current".localized, currentMetadataUrl)
            title = "baking.metadata.title.update".localized
            text = "baking.metadata.text.update".localized
        } else {
            title = "baking.metadata.title.create".localized
            text = "baking.metadata.text.create".localized
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
    var metadataUrl: String?
    var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    var viewModel: BakerMetadataViewModel
    
    init(delegate: BakerMetadataPresenterDelegate? = nil, dataHandler: StakeDataHandler) {
        self.dataHandler = dataHandler
        self.delegate = delegate
        
        let currentValue: BakerMetadataURLData? = dataHandler.getCurrentEntry()
        viewModel = BakerMetadataViewModel(currentMetadataUrl: currentValue?.metadataURL)
    }

    func viewDidLoad() {
        view?.metadataPublisher.sink(receiveValue: { [weak self] metadataUrl in
            if !metadataUrl.isEmpty {
                self?.metadataUrl = metadataUrl
            }
        }).store(in: &cancellables)
        
        view?.bind(viewModel: viewModel)
    }
    
    func pressedContinue() {
        if let metadataUrl = metadataUrl, !metadataUrl.isEmpty {
            self.dataHandler.add(entry: BakerMetadataURLData(metadataURL: metadataUrl))
        }
        self.delegate?.finishedMetadata(dataHandler: dataHandler)
    }
    
    func pressedClose() {
        self.delegate?.closedMetadata()
    }
}