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
        case manage
        var titleLabel: String {
            switch self {
            case .fungible:
                return "Fungible"
            case .collectibles:
                return "Collectibles"
            case .manage:
                return "Manage"
            }
        }
    }

    @IBOutlet var tabBarView: UIView!
    @IBOutlet var tokensTableView: UITableView!
    var data: [CIS2TokenSelectionRepresentable]
    var tabBarViewModel: MaterialTabBar.ViewModel = .init()
    var cancellables: [AnyCancellable] = []
    private var presenter: AccountTokensPresenterProtocol

    init?(coder: NSCoder, presenter: AccountTokensPresenterProtocol) {
        self.presenter = presenter
        data = self.presenter.fetchCachedTokens()
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tokensTableView.delegate = self
        tokensTableView.dataSource = self
        tabBarViewModel.tabs = Tabs.allCases.map { $0.titleLabel }
        show(MaterialTabBar(viewModel: tabBarViewModel), in: tabBarView)

        tabBarViewModel
            .$selectedIndex
            .receive(on: DispatchQueue.main)
            .compactMap { Tabs(rawValue: $0) }
            .sink { [weak self] tab in
                switch tab {
                case .manage:
                    self?.presenter.showManageTokensView()
                default:
                    self?.data = self?.presenter.fetchCachedTokens() ?? []
                    self?.tokensTableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
}

extension AccountTokensViewController: UITableViewDelegate {}

extension AccountTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Tabs(rawValue: tabBarViewModel.selectedIndex) {
        case .collectibles:
            return data.filter { $0.unique }.count
        case .fungible:
            return data.filter { !$0.unique }.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountTokensTableViewCell.self), for: indexPath) as? AccountTokensTableViewCell else {
            return UITableViewCell()
        }
        let data = data[indexPath.row]
        cell.nameLabel.text = data.name
        cell.tokenImageView.sd_setImage(with: data.thumbnail, placeholderImage: UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate).withTintColor(.gray))
        cell.balanceLabel.text = "\(data.balance) "
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelected(token: data[indexPath.row])
    }
}
