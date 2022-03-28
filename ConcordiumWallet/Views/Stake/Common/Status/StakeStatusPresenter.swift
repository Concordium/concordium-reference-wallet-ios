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
    
    
    @Published var transactionFeeText: String = ""
    @Published var receiptFooterText: String?
    
    @Published var stopButtonEnabled: Bool = false
    @Published var stopButtonShown: Bool = false
    
    @Published var updateButtonEnabled: Bool = false
    @Published var buttonLabel: String = ""
    @Published var rows: [StakeRowViewModel]
    
    init(dataHandler: StakeDataHandler) {
        rows = dataHandler.getAllOrdered().map { StakeRowViewModel(entry: $0) }
    }
}


// MARK: -
// MARK: Presenter
protocol StakeStatusPresenterProtocol: AnyObject {
	var view: StakeStatusViewProtocol? { get set }
    func viewDidLoad()
}

