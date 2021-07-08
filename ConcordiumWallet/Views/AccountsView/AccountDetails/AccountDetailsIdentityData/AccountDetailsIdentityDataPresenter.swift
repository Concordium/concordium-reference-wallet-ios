//
//  AccountDetailsIdentityDataPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

class IdentityDataViewModel: Hashable {
    var key: String = ""
    var value: String = ""
    var identiyProviderName: String = ""
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(value)
        hasher.combine(identiyProviderName)
    }

    static func == (lhs: IdentityDataViewModel, rhs: IdentityDataViewModel) -> Bool {
        lhs.key == rhs.key
    }
}

class IdentityDataListViewModel {
    @Published var dataList = [IdentityDataViewModel]()
}

// MARK: View
protocol AccountDetailsIdentityDataViewProtocol: AnyObject {
    func bind(to viewModel: IdentityDataListViewModel)
}

// MARK: -
// MARK: Presenter
protocol AccountDetailsIdentityDataPresenterProtocol: AnyObject {
	var view: AccountDetailsIdentityDataViewProtocol? { get set }
    func viewDidLoad()
}

class AccountDetailsIdentityDataPresenter: AccountDetailsIdentityDataPresenterProtocol {

    weak var view: AccountDetailsIdentityDataViewProtocol?
    
    private var account: AccountDataType
    private var viewModel = IdentityDataListViewModel()

    init(account: AccountDataType) {
        self.account = account
        
        let identityProviderName = account.identity?.identityProviderName ?? ""
        for identityData in account.revealedAttributes {
            let dataViewModel = IdentityDataViewModel()
            if let keyEnum = ChosenAttributeKeys(rawValue: identityData.key) {
                dataViewModel.key = AttributeFormatter.format(key: keyEnum)
            }
            dataViewModel.value = identityData.value
            dataViewModel.identiyProviderName = identityProviderName
            viewModel.dataList.append(dataViewModel)
        }
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}
