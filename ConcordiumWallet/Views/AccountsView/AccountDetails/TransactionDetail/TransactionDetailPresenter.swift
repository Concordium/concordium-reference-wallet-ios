//
//  TransactionDetailPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 5/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol TransactionDetailViewProtocol: AnyObject {
    func setupUI(viewModel: TransactionViewModel)
}

// MARK: -
// MARK: Delegate
protocol TransactionDetailPresenterDelegate: AnyObject {
}

// MARK: -
// MARK: Presenter
protocol TransactionDetailPresenterProtocol: AnyObject {
	var view: TransactionDetailViewProtocol? { get set }
    func viewDidLoad()
}

class TransactionDetailPresenter: TransactionDetailPresenterProtocol {

    weak var view: TransactionDetailViewProtocol?
    weak var delegate: TransactionDetailPresenterDelegate?
    
    @Published private var viewModel: TransactionViewModel

    init(delegate: TransactionDetailPresenterDelegate? = nil, viewModel: TransactionViewModel) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    func viewDidLoad() {
        view?.setupUI(viewModel: viewModel)
    }
}
