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
    case addressBook(title: String)
    case import_(title: String)
    case export(title: String)
    case update(title: String)
    case validate(title: String)
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
        case .addressBook:
            presenter.userSelectedAddressBook()
        case .import_:
            presenter.userSelectedImport()
        case .export:
            presenter.userSelectedExport()
        case .update:
            presenter.userSelectedUpdate()
        case .about:
            presenter.userSelectedAbout()
        case .validate:
            presenter.userSelectedValidate()
        }
    }
}

extension MoreMenuViewController {
    private func setupUI() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, MenuCell>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.addressBook(title: "more.addressBook".localized)])
        snapshot.appendItems([.import_(title: "more.import".localized)])
        snapshot.appendItems([.export(title: "more.export".localized)])
        snapshot.appendItems([.update(title: "more.update".localized)])
        snapshot.appendItems([.validate(title: "more.validateIdsAndAccounts".localized)])
        snapshot.appendItems([.about(title: "more.about".localized)])
                
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot)
        }
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: MenuCell) -> UITableViewCell? {
        switch viewModel {
        case .addressBook(let title),
             .import_(let title),
             .export(let title),
             .update(let title),
             .validate(let title),
             .about(let title):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCellView", for: indexPath) as! MenuItemCellView
            cell.menuItemTitleLabel?.text = title
            return cell
        }
    }
}
