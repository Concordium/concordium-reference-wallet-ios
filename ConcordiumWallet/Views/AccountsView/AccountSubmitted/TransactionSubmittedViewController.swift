//
//  TransactionSubmittedViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/16/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class TransactionSubmittedFactory {
    class func create(with presenter: TransactionSubmittedPresenter) -> TransactionSubmittedViewController {
        TransactionSubmittedViewController.instantiate(fromStoryboard: "SendFund") {coder in
            return TransactionSubmittedViewController(coder: coder, presenter: presenter)
        }
    }
}

class TransactionSubmittedViewController: BaseViewController, TransactionSubmittedViewProtocol, Storyboarded {

	var presenter: TransactionSubmittedPresenterProtocol

    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var transactionAmountLabel: UILabel!
    
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    @IBOutlet weak var transactionSummaryLabel: UILabel!
    @IBOutlet weak var transactionMemoLabel: UILabel!
    
    @IBOutlet weak var transactionSubmittedLabel: UILabel!
    
    @IBOutlet weak var shieldedWaterMark: UIImageView!
    
    init?(coder: NSCoder, presenter: TransactionSubmittedPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()
    }
    
    func bind(to viewModel: TransactionSubmittedViewModel) {
        viewModel.$recipient.sink { [weak self] (recipient) in
            self?.recipientNameLabel.text = recipient.name
            self?.recipientAddressLabel.text = recipient.address
        }.store(in: &cancellables)
        
        viewModel.$amount.sink { [weak self] amount in
            self?.transactionAmountLabel.text = amount
        }.store(in: &cancellables)
        
        viewModel.$transferSummary.sink { [weak self] summary in
            self?.transactionSummaryLabel.text = summary
        }.store(in: &cancellables)
        
        viewModel.$visibleWaterMark.sink { [weak self] visible in
            self?.shieldedWaterMark.isHidden = !visible
        }.store(in: &cancellables)
        
        viewModel.$submitedText.sink { [weak self] text in
            self?.transactionSubmittedLabel.text = text
        }.store(in: &cancellables)
        
        viewModel.$memoText.sink { [weak self] memoText in
            self?.transactionMemoLabel.text = memoText
        }.store(in: &cancellables)
    }
    
    @IBAction func okTapped(_ sender: Any) {
        presenter.userTappedOk()
    }
}
