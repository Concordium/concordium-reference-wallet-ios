//
//  AccountTransactionsDataViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

enum TransactionCell: Hashable {
    case transaction(TransactionViewModel)
    case loading
}

class AccountTransactionsDataFactory {
    class func create(with presenter: AccountTransactionsDataPresenter) -> AccountTransactionsDataViewController {
        AccountTransactionsDataViewController.instantiate(fromStoryboard: "Account") { coder in
            return AccountTransactionsDataViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountTransactionsDataViewController: BaseViewController, AccountTransactionsDataViewProtocol, Storyboarded {
    private let tableHeaderHeight: CGFloat = 22
    private let estimatedRowHeight: CGFloat = 85

    var presenter: AccountTransactionsDataPresenterProtocol?
    private var cancellables: [AnyCancellable] = []

    @IBOutlet weak var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<String, TransactionCell>?

    init?(coder: NSCoder, presenter: AccountTransactionsDataPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)

        dataSource = UITableViewDiffableDataSource<String, TransactionCell>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none

        tableView.prefetchDataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = estimatedRowHeight
        
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: TransactionCell) -> UITableViewCell? {
        switch viewModel {
            case .loading:
                return tableView.dequeueReusableCell(withIdentifier: "AccountTransactionsLoadingCell",
                                                     for: indexPath) as? AccountTransactionsLoadingCellView
            case .transaction(let transactionVM):
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTransactionsDataCellView", for: indexPath)
                    as? AccountTransactionsDataCellView
                cell?.delegate = self
                cell?.transactionHash = transactionVM.details.transactionHash
                updateCellUI(cell, for: transactionVM)
                return cell
        }
    }
    
    private func updateCellUI(_ cell: AccountTransactionsDataCellView?,
                              for viewModel: TransactionViewModel) {
        let cellVM = TransactionCellViewModel(transactionVM: viewModel)
        cell?.updateUIBasedOn(cellVM)
    }

    func bind(to viewModel: TransactionsListViewModel) {
        viewModel.$transactions.sink { transactions in
            var snapshot = NSDiffableDataSourceSnapshot<String, TransactionCell>()
            for viewModel in transactions {
                let section = String(GeneralFormatter.formatDate(for: viewModel.date))
                if snapshot.sectionIdentifiers.last != section {
                    snapshot.appendSections([section])
                }
                snapshot.appendItems([.transaction(viewModel)], toSection: section)
            }
            var addLoadingCell = true
            if let lastSection = snapshot.sectionIdentifiers.last {
                if let vm = snapshot.itemIdentifiers(inSection: lastSection).last {
                    if case .transaction(let transactionVM) = vm {
                        if transactionVM.isLast {
                            addLoadingCell = false
                        }
                    }
                }
                
                if addLoadingCell {
                    snapshot.appendItems([.loading], toSection: lastSection)
                }
            }
            
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot)
            }
        }.store(in: &cancellables)
    }
}

extension AccountTransactionsDataViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastSection = tableView.numberOfSections - 1
        let lastIndexPath = IndexPath(row: tableView.numberOfRows(inSection: lastSection) - 1, section: lastSection)
        if indexPaths.contains(lastIndexPath) {
            presenter?.loadNext()
        }
    }
}

extension AccountTransactionsDataViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = dataSource?.itemIdentifier(for: indexPath) {
            switch viewModel {
                case .transaction(let transactionVM):
                    presenter?.userSelectTransaction(transactionVM)
                    tableView.deselectRow(at: indexPath, animated: true)
                default:
                    break
            }
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: tableHeaderHeight))
        headerView.backgroundColor = .headerCellColor
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.frame.size.width, height: tableHeaderHeight))
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.textColor = .primary
        titleLabel.font = Fonts.cellHeading

        headerView.addSubview(titleLabel)
        let diffableDataSource = tableView.dataSource as? UITableViewDiffableDataSource<String, TransactionCell>
        titleLabel.text = diffableDataSource?.snapshot().sectionIdentifiers[section]
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableHeaderHeight
    }
}

extension AccountTransactionsDataViewController: AccountTransactionsDataCellViewDelegate {
    func lockButtonPressed(from cell: AccountTransactionsDataCellView) {
        if cell.transactionHash != nil {
            presenter?.userSelectedDecryption(for: cell.transactionHash!)
        }
    }
}
