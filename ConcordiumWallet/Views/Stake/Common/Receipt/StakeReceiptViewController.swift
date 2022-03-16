//
//  StakeReceiptViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol StakeReceiptViewProtocol: ShowAlert {
    func bind(viewModel: StakeReceiptViewModel)
}

class StakeReceiptFactory {
    class func create(with presenter: StakeReceiptPresenterProtocol) -> StakeReceiptViewController {
        StakeReceiptViewController.instantiate(fromStoryboard: "Stake") {coder in
            return StakeReceiptViewController(coder: coder, presenter: presenter)
        }
    }
}

class StakeReceiptViewController: BaseViewController, StakeReceiptViewProtocol, Storyboarded {

    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var submittedView: UIView!
    @IBOutlet weak var receiptHeaderView: UIView!
    @IBOutlet weak var receiptHeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var receiptFooterHeaderView: UIView!
    @IBOutlet weak var receiptFooterLabel: UILabel!
    @IBOutlet weak var nextButton: StandardButton!
    
    var dataSource: UITableViewDiffableDataSource<String, StakeReceiptRowViewModel>?
    
    var presenter: StakeReceiptPresenterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init?(coder: NSCoder, presenter: StakeReceiptPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = UITableViewDiffableDataSource<String, StakeReceiptRowViewModel>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none
        
        presenter.view = self
        presenter.viewDidLoad()
        
      
    }
    
    func bind(viewModel: StakeReceiptViewModel) {
        viewModel.$title
            .sink { [weak self] title in
                self?.title = title
            }.store(in: &cancellables)
        
        viewModel.$text
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                if let text = text  {
                    self.topTextLabel.text = text
                    self.topTextLabel.isHidden = false
                } else {
                    self.topTextLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$showsSubmitted
            .compactMap{ !$0 }
            .assign(to: \.isHidden, on: submittedView)
            .store(in: &cancellables)
        
        viewModel.$receiptHeaderText
            .compactMap{ $0 }
            .assign(to: \.text, on: receiptHeaderLabel)
            .store(in: &cancellables)
        
        viewModel.$receiptFooterText
            .sink(receiveValue: { [weak self] footerText in
                guard let self = self else { return }
                if let footerText = footerText {
                    self.receiptFooterLabel.text = footerText
                    self.receiptFooterHeaderView.isHidden = false
                } else {
                    self.receiptFooterHeaderView.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$transactionFeeText
            .compactMap{ $0 }
            .assign(to: \.text, on: transactionFeeLabel)
            .store(in: &cancellables)
        
        viewModel.$rows.sink { rows in
            var snapshot = NSDiffableDataSourceSnapshot<String, StakeReceiptRowViewModel>()
            snapshot.appendSections([""])
            snapshot.appendItems(rows, toSection: "")

            if rows.count > 0 {
                self.dataSource?.apply(snapshot)
            }
            self.tableView.reloadData()
        }.store(in: &cancellables)
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: StakeReceiptRowViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StakeReceiptCell", for: indexPath) as? StakeReceiptCell
        cell?.headerLabel.text = viewModel.headerLabel
        cell?.valueLabel.text = viewModel.valueLabel
        return cell
    }
    
    
    @IBAction func pressedButton(_ sender: UIButton) {
        presenter.pressedButton()
    }
}
