//
//  AccountDetailsIdentityDataViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class AccountDetailsIdentityDataFactory {
    class func create(with presenter: AccountDetailsIdentityDataPresenter) -> AccountDetailsIdentityDataViewController {
        AccountDetailsIdentityDataViewController.instantiate(fromStoryboard: "Account") {coder in
            return AccountDetailsIdentityDataViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountDetailsIdentityDataViewController: BaseViewController, AccountDetailsIdentityDataViewProtocol, Storyboarded {

	var presenter: AccountDetailsIdentityDataPresenterProtocol
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<SingleSection, IdentityDataViewModel>?

    init?(coder: NSCoder, presenter: AccountDetailsIdentityDataPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)

        dataSource = UITableViewDiffableDataSource<SingleSection, IdentityDataViewModel>(tableView: tableView, cellProvider: createCell)
        
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: IdentityDataViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDetailsIdentityDataCellView",
                                                 for: indexPath) as? AccountDetailsIdentityDataCellView
        cell?.keyLabel?.text = viewModel.key
        cell?.valueLabel?.text = viewModel.value
        cell?.identityProviderLabel?.text = viewModel.identiyProviderName
        return cell
    }
    
    func bind(to viewModel: IdentityDataListViewModel) {
        viewModel.$dataList.sink {
            var snapshot = NSDiffableDataSourceSnapshot<SingleSection, IdentityDataViewModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems($0)
            // The async because of run time warning saying "UITableView was told to layout its visible cells
            // and other contents without being in the view hierarchy "
            // see: https://stackoverflow.com/questions/58130124/uitableviewalertforlayoutoutsideviewhierarchy-when-uitableview-doesnt-have-wind
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot)
            }
        }.store(in: &cancellables)
    }
    
    func hasIdentities() -> Bool {
        if self.dataSource != nil {
            return self.dataSource!.tableView(tableView, numberOfRowsInSection: 0) > 0
        } else {
            return false
        }
    }
}
