//
//  StakeReceiptPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

//Add this to your coordinator:
//    func showStakeReceipt() {
//        let vc = StakeReceiptFactory.create(with: StakeReceiptPresenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }

class StakeReceiptRowViewModel: Hashable {
    var headerLabel: String
    var valueLabel: String
    private var field: Field
    
    init(entry: StakeData) {
        headerLabel = entry.getKeyLabel()
        valueLabel = entry.getDisplayValue()
        field = entry.field
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(field.getLabelText())
    }
    static func == (lhs: StakeReceiptRowViewModel, rhs: StakeReceiptRowViewModel) -> Bool {
        return lhs.field == rhs.field
    }
}

class StakeReceiptViewModel {
    @Published var title: String = ""
    @Published var text: String?
    @Published var receiptHeaderText: String = ""
    @Published var transactionFeeText: String = ""
    @Published var receiptFooterText: String?
    
    @Published var showsSubmitted: Bool = false
    @Published var buttonLabel: String = ""
    @Published var rows: [StakeReceiptRowViewModel]
    
    
    init(dataHandler: StakeDataHandler) {
        rows = dataHandler.getAllOrdered().map { StakeReceiptRowViewModel(entry: $0) }
    }
}

// MARK: -
// MARK: Presenter
protocol StakeReceiptPresenterProtocol: AnyObject {
	var view: StakeReceiptViewProtocol? { get set }
    func viewDidLoad()
    func pressedButton()
    
}

