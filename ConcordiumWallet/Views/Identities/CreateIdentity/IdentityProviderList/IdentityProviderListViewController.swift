//
//  IdentityProviderListViewController.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 10/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class IdentityProviderListFactory {
    class func create(with presenter: IdentityProviderListPresenter) -> IdentityProviderListViewController {
        IdentityProviderListViewController.instantiate(fromStoryboard: "Identity") {coder in
            return IdentityProviderListViewController(coder: coder, presenter: presenter)
        }
    }
}

// MARK: View -
protocol IdentityProviderListViewProtocol: Loadable, ShowError {
    func bind(to viewModel: IdentityProviderListViewModel)
}

class IdentityProviderListViewController: BaseViewController, Storyboarded {

	var presenter: IdentityProviderListPresenterProtocol

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<SingleSection, IdentityProviderViewModel>?
    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, presenter: IdentityProviderListPresenterProtocol) {
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

        title = "identity_provider_list_title".localized
        detailsLabel.text = String(format: "identityProviders.details".localized, presenter.getIdentityName())
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        dataSource = UITableViewDiffableDataSource<SingleSection, IdentityProviderViewModel>(tableView: tableView, cellProvider: createCell)
        tableView.sizeHeaderToFit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: IdentityProviderViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityProviderCell", for: indexPath) as? IdentityProviderCell
        cell?.titleLabel?.text = viewModel.identityName
        cell?.iconImageView?.image = UIImage.decodeBase64(toImage: viewModel.iconEncoded)
        cell?.privacyPolicyButton?.setTitle("privacypolicy".localized, for: .normal)
        return cell
    }

    @objc func closeButtonTapped() {
        presenter.closeIdentityProviderList()
    }
}

extension IdentityProviderListViewController: IdentityProviderListViewProtocol {
    func bind(to viewModel: IdentityProviderListViewModel) {
        viewModel.$identityProviders.sink {
            var snapshot = NSDiffableDataSourceSnapshot<SingleSection, IdentityProviderViewModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems($0)
            self.dataSource?.apply(snapshot)
            self.tableView.reloadData()
        }.store(in: &cancellables)
    }
}

extension IdentityProviderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelected(identityProviderIndex: indexPath.row)
    }
}

public extension UITableView {
    func sizeHeaderToFit() {
        if let headerView = tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            
            tableHeaderView = headerView
        }
    }
}
