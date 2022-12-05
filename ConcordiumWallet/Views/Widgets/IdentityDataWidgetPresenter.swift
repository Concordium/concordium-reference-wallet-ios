//
//  IdentityDataWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol IdentityDataWidgetViewProtocol: AnyObject {
    func reloadData()
}

// MARK: -
// MARK: Delegate
protocol IdentityDataWidgetPresenterDelegate: AnyObject {

}

// MARK: -
// MARK: Presenter
protocol IdentityDataWidgetPresenterProtocol: AnyObject {
	var view: IdentityDataWidgetViewProtocol? { get set }
    func viewDidLoad()

    func countOfData() -> Int
    func dataItem(index: Int) -> [String: String]
}

class IdentityDataWidgetPresenter: IdentityDataWidgetPresenterProtocol {
    
    var identityDataAsArray: [ChosenAttributeFormattedTuple] {
        identityViewModel.data.sorted(by: { $0.key.rawValue < $1.key.rawValue })
            .map { ($0.key, $0.value) }
    }

    func countOfData() -> Int {
        identityDataAsArray.count + 1 // For the header
    }

    func dataItem(index: Int) -> [String: String] {
        let realIndex = index - 1 // For the header
        let formattedTitle = AttributeFormatter.format(key: identityDataAsArray[realIndex].key)
        return [formattedTitle: identityDataAsArray[realIndex].value]
    }

    weak var view: IdentityDataWidgetViewProtocol?
    weak var delegate: IdentityDataWidgetPresenterDelegate?

    var identityViewModel: IdentityDetailsInfoViewModel

    init(identity: IdentityDataType) {
        self.identityViewModel = IdentityDetailsInfoViewModel(identity: identity)
    }

    init(identityViewModel: IdentityDetailsInfoViewModel) {
        self.identityViewModel = identityViewModel
    }

    func viewDidLoad() {
        view?.reloadData()
    }
}
