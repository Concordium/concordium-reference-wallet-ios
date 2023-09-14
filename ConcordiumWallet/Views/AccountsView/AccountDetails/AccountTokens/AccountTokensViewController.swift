//
//  AccountTokensViewController.swift
//  ConcordiumWallet
//

import Combine
import SDWebImage
import UIKit
class AccountTokensViewFactory {
    class func create(with presenter: AccountTokensPresenterProtocol) -> AccountTokensViewController {
        AccountTokensViewController.instantiate(fromStoryboard: "Account") { coder in
            let vc = AccountTokensViewController(coder: coder, presenter: presenter)
            return vc
        }
    }
}

class AccountTokensViewController: BaseViewController, Storyboarded {
    enum Tabs: Int, CaseIterable {
        case fungible
        case collectibles
        var titleLabel: String {
            switch self {
            case .fungible:
                return "Fungible"
            case .collectibles:
                return "Collectibles"
            }
        }
    }

    @IBAction func manageButtonTapped(_ sender: UIButton) {
        presenter.showManageTokensView()
    }

    @IBOutlet var tabBarView: UIView!
    @IBOutlet var tokensTableView: UITableView!
    var data: [CIS2TokenSelectionRepresentable] = []
    var tabBarViewModel: MaterialTabBar.ViewModel = .init()
    private var presenter: AccountTokensPresenterProtocol
    private var cancellables: Set<AnyCancellable> = []

    init?(coder: NSCoder, presenter: AccountTokensPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tokensTableView.delegate = self
        tokensTableView.dataSource = self
        presenter
            .cachedTokensPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] in
                guard let self = self else { return $0 }
                var currentArray = $0
                currentArray.insert(
                    .init(
                        contractName: "",
                        tokenId: "",
                        balance: presenter.account.totalForecastBalance,
                        contractIndex: "",
                        name: "CCD",
                        symbol: "CCD",
                        decimals: nil,
                        description: "",
                        thumbnail: nil,
                        unique: false,
                        accountAddress: self.presenter.account.address
                    ),
                    at: 0
                )
                return currentArray
            }
            .sink { [weak self] error in
                self?.showErrorMessage(error.localizedDescription)
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.data = data
                self.tokensTableView.reloadData()
            }
            .store(in: &cancellables)

        tabBarViewModel.tabs = Tabs.allCases.map { $0.titleLabel }
        show(MaterialTabBar(viewModel: tabBarViewModel), in: tabBarView)

        tabBarViewModel
            .$selectedIndex
            .receive(on: DispatchQueue.main)
            .compactMap { Tabs(rawValue: $0) }
            .sink { [weak self] _ in
                self?.tokensTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension AccountTokensViewController: UITableViewDelegate {}

extension AccountTokensViewController: UITableViewDataSource {
    private var currentTabItems: [CIS2TokenSelectionRepresentable] {
        switch Tabs(rawValue: tabBarViewModel.selectedIndex) {
        case .collectibles:
            return data.filter { $0.unique ?? false }
        case .fungible:
            return data.filter { !($0.unique ?? false) }
        default: return []
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentTabItems.count > 0 else {
            tableView.setEmptyMessage("No collectibles have been added to this account yet. \n To add more tokens, tap Manage.")
            return 0
        }
        tableView.restoreDefaultState()
        return currentTabItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountTokensTableViewCell.self), for: indexPath) as? AccountTokensTableViewCell else {
            return UITableViewCell()
        }
        let data = currentTabItems[indexPath.row]
        cell.tokenImageView.tintColor = .gray
        cell.nameLabel.text = data.name
        cell.balanceLabel.text = data.balanceDisplayValue
        cell.selectionStyle = .none

        guard indexPath.row != 0 else {
            cell.tokenImageView.image = UIImage(named: "concordium_logo")
            return cell
        }

        let placeholder = UIImage(systemName: "photo")
        if let url = data.thumbnail {
            cell.tokenImageView.sd_setImage(with: url, placeholderImage: placeholder)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        presenter.userSelected(token: currentTabItems[indexPath.row])
    }
}

private extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        backgroundView = messageLabel
        separatorStyle = .none
    }

    func restoreDefaultState() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
