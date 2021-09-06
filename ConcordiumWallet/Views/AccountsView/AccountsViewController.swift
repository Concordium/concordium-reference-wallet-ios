//
//  AccountsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import MessageUI
import UIKit

class AccountsFactory {
    class func create(with presenter: AccountsPresenter) -> AccountsViewController {
        AccountsViewController.instantiate(fromStoryboard: "Account") { coder in
            return AccountsViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountsViewController: BaseViewController, Storyboarded, AccountsViewProtocol, ShowToast, SupportMail {

    var presenter: AccountsPresenterProtocol?
    private weak var updateTimer: Timer?
    
    // Labels
    @IBOutlet weak var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<String, AccountViewModel>?

    private var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var newIdentityMessageLabel: UILabel!

    @IBOutlet weak var noAccountsMessageLabel: UILabel!
    @IBOutlet weak var createNewButton: StandardButton!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var atDisposalLockImageView: UIImageView!
    @IBOutlet weak var atDisposalLabel: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    
    init?(coder: NSCoder, presenter: AccountsPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "accounts_tab_title".localized
        presenter?.view = self
        presenter?.viewDidLoad()

        dataSource = UITableViewDiffableDataSource<String, AccountViewModel>(tableView: tableView, cellProvider: createCell)
//        tableView.applyConcordiumEdgeStyle()
        tableView.layer.masksToBounds = false
        tableView.backgroundColor = .white
        dataSource?.defaultRowAnimation = .none

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
        startRefreshTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        presenter?.refresh()
        tableView.refreshControl?.endRefreshing()
    }

    func startRefreshTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0,
                                           target: self,
                                           selector: #selector(refreshOnTimerCallback),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    func stopRefreshTimer() {
        if updateTimer != nil {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    
    @objc func refreshOnTimerCallback() {
        presenter?.refresh()
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: AccountViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountCell
       
        let stateCancelable = viewModel.$state.sink(receiveValue: { (state: SubmissionStatusEnum) in
                 switch state {
                 case .finalized:
                    cell?.showStatusImage(nil)
                 case .absent:
                    cell?.showStatusImage(UIImage(named: "problem_icon"))
                 case .received, .committed:
                    cell?.showStatusImage(UIImage(named: "pending"))
                 }
             })
        cell?.cancellables.append(stateCancelable)
        
        let isExpandedCancelable = viewModel.expandedChanged.sink { (isExpanded) in
            cell?.setExpanded(isExpanded)
            if let snap = self.dataSource?.snapshot() {
                DispatchQueue.main.async {
                    self.dataSource?.apply(snap, animatingDifferences: true)
                }
            }
        }
        cell?.cancellables.append(isExpandedCancelable)
        let showLock = (viewModel.shieldedLockStatus == .partiallyDecrypted || viewModel.shieldedLockStatus == .encrypted )
        
        cell?.setupStaticStrings(accountTotal: viewModel.totalName,
                                 publicBalance: viewModel.generalName,
                                 atDisposal: viewModel.atDisposalName,
                                 staked: viewModel.stakedName,
                                 shieldedBalance: viewModel.shieldedName)
        cell?.setup(accountName: viewModel.name,
                    accountOwner: viewModel.owner,
                    isInitialAccount: viewModel.isInitialAccount,
                    isBaking: viewModel.isBaking,
                    isReadOnly: viewModel.isReadOnly,
                    totalAmount: viewModel.totalAmount,
                    showLock: showLock,
                    publicBalanceAmount: viewModel.generalAmount,
                    atDisposalAmount: viewModel.atDisposalAmount,
                    stakedAmount: viewModel.stakedAmount,
                    shieldedAmount: viewModel.shieldedAmount,
                    isExpanded: viewModel.isExpanded,
                    isExpandable: true)
        cell?.delegate = self
        cell?.cellRow = indexPath.section
        return cell
    }

    func bind(to viewModel: AccountsListViewModel) {
        viewModel.$viewState.sink {
            self.setupUI(state: $0)
        }.store(in: &cancellables)
        
        viewModel.$accounts
            .receive(on: RunLoop.main)
            .sink {
                var snapshot = NSDiffableDataSourceSnapshot<String, AccountViewModel>()
                
                for account in $0 {
                    snapshot.appendSections([account.address])
                    snapshot.appendItems([account], toSection: account.address)
                }
                
                if $0.count > 0 {
                    self.dataSource?.apply(snapshot)
                }
                self.tableView.reloadData()
                
        }.store(in: &cancellables)
        
        viewModel.$totalBalance
                .map { $0.displayValue() }
                .assign(to: \.text, on: totalBalanceLabel)
                .store(in: &cancellables)
        
        viewModel.$staked
            .map { $0.displayValueWithGStroke() }
            .assign(to: \.text, on: stakedLabel)
            .store(in: &cancellables)
        
        viewModel.$atDisposal
            .map {
                if viewModel.totalBalanceLockStatus != ShieldedAccountEncryptionStatus.decrypted {
                    return $0.displayValueWithGStroke() + " + "
                } else {
                    return $0.displayValueWithGStroke()
                }
        }.assign(to: \.text, on: atDisposalLabel)
            .store(in: &cancellables)
        
        viewModel.$totalBalanceLockStatus
            .map { $0 == ShieldedAccountEncryptionStatus.decrypted ? nil : UIImage(named: "Icon_Lock_Negative")}
            .sink { self.atDisposalLockImageView.image = $0}
            .store(in: &cancellables)
        
        viewModel.$totalBalanceLockStatus
            .map { $0 == ShieldedAccountEncryptionStatus.decrypted }
        .assign(to: \.isHidden, on: lockView)
        .store(in: &cancellables)
    }

    func showIdentityFailed(reference: String, completion: @escaping () -> Void) {
        let ac = UIAlertController(title: "identityfailed.title".localized, message: nil, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "identityfailed.tryagain".localized, style: .default) { _ in
            completion()
        }
        
        ac.addAction(continueAction)
        
        if canSendMail {
            let supportAction = UIAlertAction(title: "identityfailed.contactsupport".localized, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                self.launchSupport(
                    presenter: self,
                    delegate: self,
                    recipient: AppConstants.Support.supportMail,
                    subject: String(format: "supportmail.subject".localized, reference),
                    body: String(format: "supportmail.body".localized, reference)
                )
                
            }
            ac.message = "identityfailed.message".localized
            ac.addAction(supportAction)
        } else {
            let copyAction = UIAlertAction(title: "identityfailed.copyreference".localized, style: .default) { [weak self] _ in
                UIPasteboard.general.string = reference
                self?.showToast(withMessage: "general.copied".localized + " " + reference)
            }
            ac.message = "identityfailed.nomail.message".localized
            ac.addAction(copyAction)
        }
                
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    func setupUI(state: AccountsUIState) {
        var shouldShowAddAccountButtonInTopBar = false
        switch state {
        case .newIdentity:
            tableView.isHidden = true
            createNewButton.setTitle("accounts.createNewIdentity".localized, for: .normal)
            newIdentityMessageLabel.isHidden = false
            noAccountsMessageLabel.isHidden = false
            createNewButton.isHidden = false
        case .newAccount:
            tableView.isHidden = true
            newIdentityMessageLabel.isHidden = true
            noAccountsMessageLabel.isHidden = false
            createNewButton.isHidden = false
            createNewButton.setTitle("accounts.createNewAccount".localized, for: .normal)
            shouldShowAddAccountButtonInTopBar = true
        case .showAccounts:
            tableView.isHidden = false
            newIdentityMessageLabel.isHidden = true
            noAccountsMessageLabel.isHidden = true
            createNewButton.isHidden = true
            shouldShowAddAccountButtonInTopBar = true
        }

        if shouldShowAddAccountButtonInTopBar {
            let rightButtonImage = UIImage(named: "add_icon")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightButtonImage,
                                                                style: .plain,
                                                                target: self, action: #selector(createNewButtonPressed))
        }
    }

    @IBAction func createNewButtonPressed(_ sender: Any) {
        presenter?.userPressedCreate()
    }
}

extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.userSelected(accountIndex: indexPath.section, balanceIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

extension AccountsViewController: AccountCellDelegate {
     func cellCheckTapped(cellRow: Int, index: Int) {
        presenter?.userSelected(accountIndex: cellRow, balanceIndex: index)
    }
    
    func tappedExpanded(cellRow: Int) {
        presenter?.toggleExpand(accountIndex: cellRow)
    }
}

extension AccountsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
