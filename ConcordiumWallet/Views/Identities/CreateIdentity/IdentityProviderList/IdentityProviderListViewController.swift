//
//  IdentityProviderListViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 10/02/2020.
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
protocol IdentityProviderListViewProtocol: Loadable, ShowAlert {
    func bind(to viewModel: IdentityProviderListViewModel)
}

class IdentityProviderListViewController: BaseViewController, Storyboarded {

	var presenter: IdentityProviderListPresenterProtocol

    @IBOutlet weak var detailsTextView: UITextView!
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

        detailsTextView.delegate = self

        title = "identity_provider_list_title".localized
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        dataSource = UITableViewDiffableDataSource<SingleSection, IdentityProviderViewModel>(
            tableView: tableView,
            cellProvider: IdentityProviderListViewController.createCell)
        tableView.sizeHeaderToFit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    private static func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: IdentityProviderViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityProviderCell", for: indexPath) as? IdentityProviderCell
        cell?.titleLabel?.text = viewModel.identityName
        cell?.iconImageView?.image = UIImage.decodeBase64(toImage: viewModel.iconEncoded)
        cell?.privacyPolicyButton?.setTitle("privacypolicy".localized, for: .normal)
        return cell
    }

    private func setIdentityProviderLinksIfNeeded(identities: [IdentityProviderViewModel]) {
        guard !identities.isEmpty else { return }

        let identitiesList = identities.map { $0.identityName }.joined(separator: "\n\n")
        let originalText = "identityProviders.details".localized + "\n\n" + identitiesList
        let attributedOriginalText = NSMutableAttributedString(string: originalText)

        let style = NSMutableParagraphStyle()
        style.alignment = .justified

        for identity in identities {
            let linkRange = attributedOriginalText.mutableString.range(of: identity.identityName)
            let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
            attributedOriginalText.addAttribute(.link, value: identity.url ?? "", range: linkRange)
            attributedOriginalText.addAttribute(.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: fullRange)
            attributedOriginalText.addAttribute(.foregroundColor, value: UIColor.text, range: fullRange)
        }

        detailsTextView.linkTextAttributes = [
            .underlineColor: UIColor.text,
            .underlineStyle: 1
        ]
        detailsTextView.attributedText = attributedOriginalText
        tableView.sizeHeaderToFit()
    }

    @objc func closeButtonTapped() {
        presenter.closeIdentityProviderList()
    }
}

// MARK: - IdentityProviderListViewProtocol
extension IdentityProviderListViewController: IdentityProviderListViewProtocol {
    func bind(to viewModel: IdentityProviderListViewModel) {
        viewModel.$identityProviders.sink { [weak self] in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<SingleSection, IdentityProviderViewModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems($0)
            self.dataSource?.apply(snapshot)
            self.tableView.reloadData()
            self.setIdentityProviderLinksIfNeeded(identities: $0)
        }.store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate
extension IdentityProviderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelected(identityProviderIndex: indexPath.row)
    }
}

// MARK: - UITextViewDelegate
extension IdentityProviderListViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard !URL.absoluteString.isEmpty else { return false }
        presenter.userSelectedIdentitiyProviderInfo(url: URL)
        return false
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
