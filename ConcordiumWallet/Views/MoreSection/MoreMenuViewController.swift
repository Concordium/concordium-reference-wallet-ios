//
//  MoreMenuViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 24/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

// For future use, other cell types will be added
enum MenuCell: Hashable {
    case identities(title: String)
    case addressBook(title: String)
    case update(title: String)
    case recovery(title: String)
    case about(title: String)
    
}

class MoreMenuFactory {
    class func create(with presenter: MoreMenuPresenter) -> MoreMenuViewController {
        MoreMenuViewController.instantiate(fromStoryboard: "More") { coder in
            return MoreMenuViewController(coder: coder, presenter: presenter)
        }
    }
}

class MoreMenuViewController: BaseViewController, MoreMenuViewProtocol, Storyboarded {
    typealias MoreMenuDataSource = UITableViewDiffableDataSource<SingleSection, MenuCell>
    var presenter: MoreMenuPresenterProtocol

    @IBOutlet weak var tableView: UITableView!
    var dataSource: MoreMenuDataSource?

    init?(coder: NSCoder, presenter: MoreMenuPresenterProtocol) {
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

        title = "more_tab_title".localized

        tableView.tableFooterView = UIView(frame: .zero)

        dataSource = MoreMenuDataSource(tableView: tableView, cellProvider: createCell)
        setupUI()

        #if MOCK
        MockedData.addMockButton(in: self)
        #endif
    }
}

extension MoreMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let moreMenuDataSource = tableView.dataSource as? MoreMenuDataSource else {
            return
        }
        let menuCell = moreMenuDataSource.snapshot().itemIdentifiers[indexPath.row]
        switch menuCell {
        case .identities:
            presenter.userSelectedIdentities()
        case .addressBook:
            presenter.userSelectedAddressBook()
        case .update:
            presenter.userSelectedUpdate()
        case .recovery:
            presenter.userSelectedRecovery()
        case .about:
            presenter.userSelectedAbout()
        }
    }
}

extension MoreMenuViewController {
    private func setupUI() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, MenuCell>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.identities(title: "more.identities".localized)])
        snapshot.appendItems([.addressBook(title: "more.addressBook".localized)])
        snapshot.appendItems([.update(title: "more.update".localized)])
        snapshot.appendItems([.recovery(title: "more.recovery".localized)])
        snapshot.appendItems([.about(title: "more.about".localized)])
                
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot)
        }
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: MenuCell) -> UITableViewCell? {
        switch viewModel {
        case
                .identities(let title),
                .addressBook(let title),
                .update(let title),
                .recovery(let title),
                .about(let title):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCellView", for: indexPath) as! MenuItemCellView
            cell.menuItemTitleLabel?.text = title
            return cell
        }
    }
}
