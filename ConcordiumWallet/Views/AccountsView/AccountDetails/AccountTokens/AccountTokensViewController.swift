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
        presenter.cachedTokensPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showErrorMessage(error.localizedDescription)
            } receiveValue: { [weak self] data in
                self?.data = data
                self?.tokensTableView.reloadData()
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
    var itemsCount: Int {
        switch Tabs(rawValue: tabBarViewModel.selectedIndex) {
        case .collectibles:
            return data.filter { $0.unique }.count
        case .fungible:
            return data.filter { !$0.unique }.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard itemsCount > 0 else {
            tableView.setEmptyMessage("No collectibles have been added to this account yet. \n To add more tokens, tap Manage.")
            return 0
        }
        tableView.restoreDefaultState()
        return itemsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountTokensTableViewCell.self), for: indexPath) as? AccountTokensTableViewCell else {
            return UITableViewCell()
        }
        let placeholder = UIImage(systemName: "photo")
        cell.tokenImageView.tintColor = .gray
        let data = data[indexPath.row]
        cell.nameLabel.text = data.name
        cell.tokenImageView.sd_setImage(with: data.thumbnail, placeholderImage: placeholder)
        cell.balanceLabel.text = "\(data.balance) "
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelected(token: data[indexPath.row])
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
