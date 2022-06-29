//
//  StakeStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class StakeStatusViewModel {
    @Published var title: String = ""
    @Published var topText: String = ""
    @Published var topImageName: String = ""
    @Published var placeholderText: String?
    
    @Published var gracePeriodText: String?
    @Published var bottomInfoMessage: String?
    @Published var bottomImportantMessage: String?
    
    @Published var newAmount: String?
    @Published var newAmountLabel: String?
     
    @Published var stopButtonEnabled: Bool = true
    @Published var stopButtonShown: Bool = true
    @Published var stopButtonLabel: String = ""
    
    @Published var updateButtonEnabled: Bool = true
    @Published var buttonLabel: String = ""
    
    @Published var rows: [StakeRowViewModel]
    
    init() {
        rows = []
    }
    
    convenience init(dataHandler: StakeDataHandler) {
        self.init()
        setup(dataHandler: dataHandler)
    }
    
    func setup(dataHandler: StakeDataHandler) {
        rows = dataHandler
            .getCurrentOrdered()
            .map { StakeRowViewModel(displayValue: $0) }
    }
}

// MARK: -
// MARK: Presenter
protocol StakeStatusPresenterProtocol: AnyObject {
	var view: StakeStatusViewProtocol? { get set }
    func viewDidLoad()
    func pressedButton()
    func pressedStopButton()
    func closeButtonTapped()
    func updateStatus()
}
