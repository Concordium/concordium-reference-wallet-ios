//
//  AccountTokensViewController.swift
//  ConcordiumWallet
//

import UIKit
import Combine

struct Token {
    var id: String
    var token: String
    var isSelected = false
    var contractIndex: String
    var subIndex: String
    var isCCDToken = false
    var symbol: String
    var atDisposal: Float = 0.0

    init(id: String, token: String, isSelected: Bool, contractIndex: String, subIndex: String, isCCDToken: Bool = false, symbol: String = "") {
        self.id = id
        self.token = token
        self.isSelected = isSelected
        self.contractIndex = contractIndex
        self.subIndex = subIndex
        self.isCCDToken = isCCDToken
        self.symbol = symbol
    }
    
    static var mocked: [Token] = [
        .init(id: "", token: "CCD", isSelected: false, contractIndex: "0", subIndex: "0", symbol: "CCD"),
        .init(id: "", token: "USDT", isSelected: false, contractIndex: "0", subIndex: "0", symbol: "USDT"),
        .init(id: "", token: "wCCD", isSelected: false, contractIndex: "0", subIndex: "0", symbol: "wCCD")
    ]
}

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

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var tokensTableView: UITableView!
    var data: [Token] = Token.mocked
    var tabBarViewModel: MaterialTabBar.ViewModel = .init()
    var cancellables: [AnyCancellable] = []
    private var presenter: AccountTokensPresenterProtocol
    
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
        tabBarViewModel.tabs = Tabs.allCases.map { $0.titleLabel }
        show(MaterialTabBar(viewModel: tabBarViewModel), in: tabBarView)
        
        tabBarViewModel
            .$selectedIndex
            .receive(on: DispatchQueue.main)
            .compactMap { Tabs(rawValue: $0) }
            .sink { [weak self] tab in
                switch tab {
                case .collectibles:
                    break // TODO: add filtering
                case .fungible:
                    break // TODO: add filtering
                case .manage:
                    self?.presenter.showManageTokensView()
                }
            }
            .store(in: &cancellables)
    }
}

extension AccountTokensViewController: UITableViewDelegate {}

extension AccountTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountTokensTableViewCell.self), for: indexPath) as? AccountTokensTableViewCell else {
            return UITableViewCell()
        }
        let data = data[indexPath.row]
        cell.tokenImageView.image = UIImage(named: "ccd_coins") // TODO: Change it to icon fetched from the internet
        cell.amountLabel.text = "\(data.atDisposal) \(data.symbol)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.userSelected(token: data[indexPath.row])
    }
}
