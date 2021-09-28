//
//  AccountTransactionsDataPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol AccountTransactionsDataViewProtocol: AnyObject {
    func bind(to viewModel: TransactionsListViewModel)
}

// MARK: Delegate
protocol AccountTransactionsDataPresenterDelegate: AnyObject {
    func transactionSelected(_ transaction: TransactionViewModel)
    func userSelectedDecryption(for transactionWithHash: String)
}

// MARK: -
// MARK: Presenter
protocol AccountTransactionsDataPresenterProtocol: AnyObject {
    var view: AccountTransactionsDataViewProtocol? { get set }
    func viewDidLoad()
    func viewUnload()
    func loadNext()
    
    func userSelectTransaction(_: TransactionViewModel)
    func userSelectedDecryption(for transactionWithHash: String)
}

class AccountTransactionsDataPresenter: AccountTransactionsDataPresenterProtocol {

    weak var view: AccountTransactionsDataViewProtocol?
    weak var delegate: AccountTransactionsDataPresenterDelegate?

    private var account: AccountDataType

    private var viewModel = TransactionsListViewModel()
    private var transactionsFetcher: TransactionsFetcher?

    init(delegate: AccountTransactionsDataPresenterDelegate,
         account: AccountDataType,
         viewModel: TransactionsListViewModel,
         transactionsFetcher: TransactionsFetcher) {
        self.delegate = delegate
        self.account = account
        self.viewModel = viewModel
        self.transactionsFetcher = transactionsFetcher
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }

    func viewUnload() {
        delegate = nil
        transactionsFetcher = nil
    }
    
    func loadNext() {
        transactionsFetcher?.getNextTransactions()
    }
    
    func userSelectTransaction(_ viewModel: TransactionViewModel) {
        delegate?.transactionSelected(viewModel)
    }
    
    func userSelectedDecryption(for transactionWithHash: String) {
        delegate?.userSelectedDecryption(for: transactionWithHash)
    }
}
