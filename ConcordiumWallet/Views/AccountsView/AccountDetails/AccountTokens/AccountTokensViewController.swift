//
//  AccountTokensViewController.swift
//  ConcordiumWallet
//

import BigInt
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
    struct AccountTokensViewModel {
        let name: String
        let symbol: String?
        let thumbnailURL: URL?
        let thumbnailImage: UIImage?
        let unique: Bool?
        let balance: String
    }

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
    var fungibleTokens: [CIS2TokenSelectionRepresentable] = []
    var nfts: [CIS2TokenSelectionRepresentable] = []
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
            .map { ($0.filter { !$0.unique }, $0.filter { $0.unique }) }
            .map { fts, nfts in
                (fts.sorted(), nfts.sorted())
            }
            .sink { [weak self] error in
                self?.showErrorMessage(error.localizedDescription)
            } receiveValue: { [weak self] fts, nfts in
                guard let self = self else { return }
                self.fungibleTokens = fts
                // Hardcode CCD in front of the FTs array.
                self.fungibleTokens.insert(
                    .init(
                        contractName: "",
                        tokenId: "",
                        balance: BigInt(presenter.account.finalizedBalance),
                        contractIndex: "",
                        name: "CCD",
                        symbol: "CCD",
                        decimals: 6,
                        description: "",
                        thumbnail: nil, 
                        display: nil,
                        unique: false,
                        accountAddress: self.presenter.account.address
                    ),
                    at: 0
                )
                self.nfts = nfts
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
            return nfts
        case .fungible:
            return fungibleTokens
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

        if indexPath.row == 0, Tabs(rawValue: tabBarViewModel.selectedIndex) == .some(.fungible) {
            cell.tokenImageView.image = UIImage(named: "concordium_logo")
            return cell
        }
        cell.tokenImageView.sd_setImage(with: data.thumbnail, placeholderImage: UIImage(systemName: "photo"))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0, Tabs(rawValue: tabBarViewModel.selectedIndex) == .some(.fungible) { return }
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
