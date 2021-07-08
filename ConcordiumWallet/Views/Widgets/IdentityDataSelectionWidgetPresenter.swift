//
//  IdentityDataSelectionWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

struct IdentityRowSelectionViewModel {
    var titleKey: ChosenAttributeKeys
    var title: String
    var details: String
    var isChecked: Bool
}

// MARK: View
protocol IdentityDataSelectionWidgetViewProtocol: AnyObject {
    func reloadData()
}

// MARK: -
// MARK: Delegate
protocol IdentityDataSelectionWidgetPresenterDelegate: AnyObject {
    func userChangeSelected(account: AccountDataType)
}

// MARK: -
// MARK: Presenter
protocol IdentityDataSelectionWidgetPresenterProtocol: AnyObject {
    var view: IdentityDataSelectionWidgetViewProtocol? { get set }
    func viewDidLoad()

    func countOfData() -> Int
    func dataItem(index: Int) -> IdentityRowSelectionViewModel

    func userCheckedItem(at index: Int)
}

class IdentityDataSelectionWidgetPresenter: IdentityDataSelectionWidgetPresenterProtocol {

    lazy var dataViewModels: [IdentityRowSelectionViewModel] = {
        identityViewModel.data.filter { $0.key == ChosenAttributeKeys.countryOfResidence ||
            $0.key == ChosenAttributeKeys.nationality ||
            $0.key == ChosenAttributeKeys.idDocType ||
            $0.key == ChosenAttributeKeys.idDocIssuer }  // only allow this 4 fields, as per new specifications
            .map {
                IdentityRowSelectionViewModel(titleKey: $0.key,
                                              title: AttributeFormatter.format(key: $0.key),
                                              details: $0.value,
                                              isChecked: false)
        }.sorted(by: { $0.title < $1.title })
    }()

    func countOfData() -> Int {
        dataViewModels.count
    }

    func dataItem(index: Int) -> IdentityRowSelectionViewModel {
        dataViewModels[realIndex(for: index)]
    }

    weak var view: IdentityDataSelectionWidgetViewProtocol?
    weak var delegate: IdentityDataSelectionWidgetPresenterDelegate?

    var identityViewModel: IdentityDetailsInfoViewModel
    var account: AccountDataType

    init(delegate: IdentityDataSelectionWidgetPresenterDelegate, account: AccountDataType) {
        self.delegate = delegate
        self.identityViewModel = IdentityDetailsInfoViewModel(identity: account.identity!)
        self.account = account
    }

    func viewDidLoad() {
        view?.reloadData()
    }

    func userCheckedItem(at index: Int) {
        let rIndex = realIndex(for: index)
        guard rIndex >= 0 else {
            return
        }
        dataViewModels[rIndex].isChecked = !dataViewModels[rIndex].isChecked

        account.revealedAttributes = dataViewModels
                .filter { $0.isChecked }
                .reduce(into: [String: String]()) { (dict, model) in
                    dict[model.titleKey.rawValue] = model.details
        }
        self.delegate?.userChangeSelected(account: account)

        view?.reloadData()
    }
}

extension IdentityDataSelectionWidgetPresenter {
    func realIndex(for index: Int) -> Int {
        index
    }
}
