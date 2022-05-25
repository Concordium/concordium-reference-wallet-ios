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
protocol StakeReceiptViewProtocol: ShowAlert, Loadable {
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
    
    var dataSource: UITableViewDiffableDataSource<String, StakeRowViewModel>?
    
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

        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        dataSource = UITableViewDiffableDataSource<String, StakeRowViewModel>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none
        
        presenter.view = self
        presenter.viewDidLoad()
//        showCloseButton()
        
    }
    func showCloseButton() {
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
    }

    @objc func closeButtonTapped() {
        presenter.closeButtonTapped()
    }
    
    // swiftlint:disable function_body_length
    func bind(viewModel: StakeReceiptViewModel) {
        viewModel.$title
            .sink { [weak self] title in
                self?.title = title
            }.store(in: &cancellables)
        
        viewModel.$text
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                if let text = text {
                    self.topTextLabel.text = text
                    self.topTextLabel.isHidden = false
                } else {
                    self.topTextLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$showsSubmitted
            .compactMap { !$0 }
            .assign(to: \.isHidden, on: submittedView)
            .store(in: &cancellables)
        
        viewModel.$receiptHeaderText
            .compactMap { $0 }
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
            .compactMap { $0 }
            .assign(to: \.text, on: transactionFeeLabel)
            .store(in: &cancellables)
        
        viewModel.$rows.sink { rows in
            var snapshot = NSDiffableDataSourceSnapshot<String, StakeRowViewModel>()
            snapshot.appendSections([""])
            snapshot.appendItems(rows, toSection: "")

            if rows.count > 0 {
                self.dataSource?.apply(snapshot)
            }
            self.tableView.reloadData()
        }.store(in: &cancellables)
        
        viewModel.$showsBackButton.sink { [weak self] showBack in
           
            if showBack {
                self?.showCloseButton()
                self?.navigationItem.setHidesBackButton(false, animated: true)
            } else {
                self?.navigationItem.rightBarButtonItem = nil
                self?.navigationItem.setHidesBackButton(true, animated: true)
            }
        }.store(in: &cancellables)
        
        viewModel.$buttonLabel
            .filter { !$0.isEmpty }
            .sink { [weak self] text in
                self?.nextButton.setTitle(text, for: .normal)
            }
            .store(in: &cancellables)
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: StakeRowViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StakeEntryCell", for: indexPath) as? StakeEntryCell
        cell?.headerLabel.text = viewModel.headerLabel
        cell?.valueLabel.text = viewModel.valueLabel
        return cell
    }

    @IBAction func pressedButton(_ sender: UIButton) {
        presenter.pressedButton()
    }
}
