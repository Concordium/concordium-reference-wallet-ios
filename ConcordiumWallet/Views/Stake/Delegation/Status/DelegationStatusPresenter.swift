//
//  DelegationStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation


// MARK: -
// MARK: Delegate
protocol DelegationStatusPresenterDelegate: AnyObject {

}

class DelegationStatusPresenter: StakeStatusPresenterProtocol {

    weak var view: StakeStatusViewProtocol?
    weak var delegate: DelegationStatusPresenterDelegate?

    var viewModel: StakeStatusViewModel
    var dataHandler: StakeDataHandler
    init(dataHandler: StakeDataHandler, delegate: DelegationStatusPresenterDelegate? = nil) {
        self.delegate = delegate
        self.dataHandler = dataHandler
        viewModel = StakeStatusViewModel(dataHandler: dataHandler)
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
}
