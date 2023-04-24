//
//  TransactionDetailViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 5/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

typealias TransactionsDetailDataSource = UITableViewDiffableDataSource<SingleSection, TransactionDetailCell>
typealias TransactionDetailSnapShot = NSDiffableDataSourceSnapshot<SingleSection, TransactionDetailCell>

struct TransactionDetailItemViewModel: Hashable {
    var title: String
    var value: String
    var displayValue: String
    var displayCopy: Bool = true
}

enum TransactionDetailCell: Hashable {
    case info(TransactionViewModel)
    case error(String)
    case origin(TransactionDetailItemViewModel)
    case from(TransactionDetailItemViewModel)
    case to(TransactionDetailItemViewModel)
    case transactionHash(TransactionDetailItemViewModel)
    case blockHash(TransactionDetailItemViewModel)
    case details(TransactionDetailItemViewModel)
}

class TransactionDetailFactory {
    class func create(with presenter: TransactionDetailPresenter) -> TransactionDetailViewController {
        TransactionDetailViewController.instantiate(fromStoryboard: "Account") { coder in
            return TransactionDetailViewController(coder: coder, presenter: presenter)
        }
    }
}

class TransactionDetailViewController: BaseViewController, TransactionDetailViewProtocol, Storyboarded, ShowToast {
    
    var presenter: TransactionDetailPresenterProtocol
    
    private let estimatedRowHeight: CGFloat = 80
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: TransactionsDetailDataSource?
       
    init?(coder: NSCoder, presenter: TransactionDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "accountDetails.title".localized
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.applyConcordiumEdgeStyle()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = estimatedRowHeight

        dataSource = TransactionsDetailDataSource(tableView: tableView, cellProvider: createCell)

        presenter.view = self
        presenter.viewDidLoad()
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: TransactionDetailCell) -> UITableViewCell? {
        switch viewModel {
        case .info(let transaction):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTransactionsDataCellView", for: indexPath)
                as? AccountTransactionsDataCellView
            updateCellUI(cell, for: transaction)
            return cell
            
        case .origin(let vm), .to(let vm), .from(let vm), .blockHash(let vm), .transactionHash(let vm), .details(let vm):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailInfoCellView",
                                                     for: indexPath) as? TransactionDetailInfoCellView
            cell?.infoTitleLabel?.text = vm.title
            cell?.detailsLabel?.text = vm.displayValue
            cell?.copyImage?.isHidden = !vm.displayCopy
            return cell
            
        case .error(let errorText):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailErrorCellView",
                                                     for: indexPath) as? TransactionDetailErrorCellView
            cell?.errorLabel?.text = errorText
            return cell
        }
    }
    
    private func updateCellUI(_ cell: AccountTransactionsDataCellView?,
                              for viewModel: TransactionViewModel) {
        let cellVM = TransactionCellViewModel(transactionVM: viewModel)
        cell?.updateUIBasedOn(cellVM, useFullDate: true)
    }
    
    func setupUI(viewModel: TransactionViewModel) {
        var snapshot = TransactionDetailSnapShot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems([.info(viewModel)])
        snapshot.appendItems(getRejectReasonCell(viewModel: viewModel))
        snapshot.appendItems(getOriginCell(viewModel: viewModel))
        snapshot.appendItems(getFromAddressCell(viewModel: viewModel))
        snapshot.appendItems(createToAddressCell(viewModel: viewModel))
        snapshot.appendItems(getTransactionHashCell(viewModel: viewModel))
        snapshot.appendItems(createBlockHashCell(viewModel: viewModel))
        snapshot.appendItems(createDetailsCell(viewModel: viewModel))
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot)
        }
    }
    
    private func getRejectReasonCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        if let rejectReason = viewModel.details.rejectReason {
            return [.error(rejectReason)]
        }
        return []
    }
    
    private func getOriginCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        if let origin = viewModel.details.origin {
            let title = "accountDetails.origin".localized
            let value = origin
            let displayValue: String
            if value.count >= 8 {
                displayValue = String(value[..<value.index(value.startIndex, offsetBy: 8)])
            } else {
                displayValue = value
            }
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: displayValue)
            return [.origin(displayVM)]
        }
        return []
    }
    
    private func getFromAddressCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        if let fromAddressValue = viewModel.details.fromAddressValue {
            let title = "accountDetails.fromAddress".localized + (viewModel.details.fromAddressName ?? "")
            let value = fromAddressValue
            
            if value.count == 0 {
                return []
            }
            let displayValue: String
            if value.count >= 8 {
                displayValue = String(value[..<value.index(value.startIndex, offsetBy: 8)])
            } else {
                displayValue = value
            }
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: displayValue)
            return [.from(displayVM)]
        }
        return []
    }
    
    private func createToAddressCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        if let toAddressValue = viewModel.details.toAddressValue {
            let title = "accountDetails.toAddress".localized + (viewModel.details.toAddressName ?? "")
            let value = toAddressValue
            let displayValue: String
            if value.count >= 8 {
                displayValue = String(value[..<value.index(value.startIndex, offsetBy: 8)])
            } else {
                displayValue = value
            }
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: displayValue)
            return [.to(displayVM)]
        }
        return []
    }
    
    private func getTransactionHashCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        if let transactionHash = viewModel.details.transactionHash {
            let title = "accountDetails.transactionHash".localized
            let value = transactionHash
            let displayValue = String(value[..<value.index(value.startIndex, offsetBy: 8)])
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: displayValue)
            return [.transactionHash(displayVM)]
        }
        return []
    }
    
    private func createBlockHashCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        var blockHashValue = ""
        if viewModel.status == .received {
            blockHashValue = "accountDetails.submitted".localized
        } else if viewModel.status == .absent {
            blockHashValue = "accountDetails.failed".localized
        }
        if let blockHashes = viewModel.details.blockHashes, blockHashes.count > 0 {
            blockHashValue = blockHashes.joined(separator: "\n")
        }
        if !blockHashValue.isEmpty {
            let title = "accountDetails.blockHash".localized
            let value = blockHashValue
            var displayValue = value
            if value.count > 9 { // Value can be "Failed", otherwise cut first 8 chars from blockhash.
                displayValue = String(value[..<value.index(value.startIndex, offsetBy: 8)])
            }
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: displayValue)
            return [.blockHash(displayVM)]
        }
        return []
    }
    
    private func createDetailsCell(viewModel: TransactionViewModel) -> [TransactionDetailCell] {
        var detailsValue = ""
        if let details = viewModel.details.details, details.count > 0 {
            detailsValue = details.joined(separator: "\n")
        }
        if !detailsValue.isEmpty {
            let title = "accountDetails.details".localized
            let value = detailsValue
            // let displayValue = detailsValue
            let displayVM = TransactionDetailItemViewModel(title: title, value: value, displayValue: detailsValue, displayCopy: false)
            return [.details(displayVM)]
        }
        return []
    }
}

extension TransactionDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vm = dataSource?.itemIdentifier(for: indexPath) {
            switch vm {
            case .info:
                break
                
            case .origin(let vm), .to(let vm), .from(let vm), .blockHash(let vm), .transactionHash(let vm), .details(let vm):
                CopyPasterHelper.copy(string: vm.value)
                self.showToast(withMessage: "general.copied".localized + " " + vm.value)
            case .error:
                break
            }
        }
    }
}
