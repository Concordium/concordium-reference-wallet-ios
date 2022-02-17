//
//  AccountDetailsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/30/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTabs_TabBarView
import Combine

class AccountDetailsFactory {
    class func create(with presenter: AccountDetailsPresenter) -> AccountDetailsViewController {
        AccountDetailsViewController.instantiate(fromStoryboard: "Account") { coder in
            return AccountDetailsViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountDetailsViewController: BaseViewController, AccountDetailsViewProtocol, Storyboarded, ShowAlert {
    
    var presenter: AccountDetailsPresenterProtocol
    var isShielded: Bool = false
    private weak var updateTimer: Timer?
    
    @IBOutlet weak var detailsTabBar: MDCTabBarView!
    
    @IBOutlet weak var totalsStackView: UIStackView!
    @IBOutlet weak var retryCreateButton: StandardButton!
    @IBOutlet weak var removeLocalAccountButton: StandardButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var sendView: RoundedCornerView!
    @IBOutlet weak var shieldView: RoundedCornerView!
    @IBOutlet weak var addressView: RoundedCornerView!
    @IBOutlet weak var backgroundShield: UIImageView!
    
    @IBOutlet weak var readOnlyView: UIView!
    @IBOutlet weak var balanceNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var atDisposalView: UIView!
    @IBOutlet weak var stakedView: UIView!
    
    @IBOutlet weak var atDisposalLabel: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    @IBOutlet weak var bakerIdLabel: UILabel!
    @IBOutlet weak var sendImageView: UIImageView!
    
    @IBOutlet weak var shieldTypeLabel: UILabel!
    @IBOutlet weak var shieldTypeImageView: UIImageView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var generalButton: UIButton!
    @IBOutlet weak var shieldedButton: UIButton!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var topSpacingStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gtuDropView: UIView! {
        didSet {
            gtuDropView.isHidden = true
        }
    }
    
    var identityDataVC: AccountDetailsIdentityDataViewController!
    var transactionsVC: AccountTransactionsDataViewController!
    
    private var cancellables: [AnyCancellable] = []
    
    init?(coder: NSCoder, presenter: AccountDetailsPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gtuDropView.isHidden = true
        
        setupTabBar()
        setupIdentityDataUI()
        setupTransactionsUI()
        title = presenter.getTitle()
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        startRefreshTimer()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
        if self.isMovingFromParent {
            presenter.viewWillDisappear()
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            cancellables = []
            identityDataVC = nil
            transactionsVC = nil
        }
    }
    
    @objc func appDidBecomeActive() {
        presenter.updateTransfersOnChanges()
        startRefreshTimer()
    }
    
    @objc func appWillResignActive() {
        stopRefreshTimer()
    }
    
    func showMenuButton(iconName: String) {
        let closeIcon = UIImage(named: iconName)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.burgerButtonTapped))
    }
    
    @objc func burgerButtonTapped() {
        // update image
        presenter.burgerButtonTapped()
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
        presenter.updateTransfersOnChanges()
    }
    
    // swiftlint:disable function_body_length
    func bind(to viewModel: AccountDetailsViewModel) {
        self.showTransferData(accountState: viewModel.accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: viewModel.hasTransfers)
        
        // Note: Handle consuming transfers and keeping the current account state
        viewModel.$selectedTab.sink { [weak self]selectedTab in
            switch selectedTab {
            case .transfers:
                self?.showTransferData(accountState: viewModel.accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: viewModel.hasTransfers)
            case .identityData:
                self?.showIdentityData()
            }
        }.store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.$hasTransfers, viewModel.$accountState)
            .sink { [weak self](hasTransfers: Bool, accountState: SubmissionStatusEnum) in
                self?.showTransferData(accountState: accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: hasTransfers)
            }.store(in: &cancellables)
        
        viewModel.$balance
            .compactMap { $0 }
            .assign(to: \.text, on: balanceLabel)
            .store(in: &cancellables)
        
        viewModel.$showUnlockButton.sink { [weak self](showUnlock) in
            if viewModel.isShielded {
                if showUnlock {
                    self?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Lock_Unlocked"),
                                                                              style: .plain,
                                                                              target: self,
                                                                              action: #selector(self?.pressedUnlock(_:)))
                } else {
                    self?.navigationItem.rightBarButtonItem = nil
                }
            }
        }.store(in: &cancellables)
        
        viewModel.$menuState.sink {[weak self](state) in
            guard let self = self else { return }
            if !viewModel.isShielded {
                switch state {
                case .open:
                    self.showMenuButton(iconName: "lines_open")
                case .closed:
                    self.showMenuButton(iconName: "lines_close")
                }
            }
        }.store(in: &cancellables)
        
        viewModel.$isShielded.sink { [weak self](isShielded) in
            guard let self = self else { return }
            self.sendImageView.image = (isShielded ? UIImage(named: "send_shielded") : UIImage(named: "send"))
            self.shieldTypeLabel.text = isShielded ? "accountDetails.unshield".localized : "accountDetails.shield".localized
            self.shieldTypeImageView.image = (isShielded ? UIImage(named: "Icon_Unshield") : UIImage(named: "Icon_Shield_white"))
            self.isShielded = isShielded
            self.title = self.presenter.getTitle()
            self.atDisposalView.setHiddenIfChanged(isShielded)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            self.generalButton.backgroundColor = isShielded ? UIColor.primarySelected : UIColor.primary
            self.shieldedButton.backgroundColor = isShielded ? UIColor.primary : UIColor.primarySelected
            
            if isShielded {
                self.balanceNameLabel.text =  String(format: ("accounts.overview.shieldedtotal".localized), viewModel.name ?? "")
            } else {
                self.balanceNameLabel.text = "accounts.overview.generaltotal".localized
            }
            self.backgroundShield.isHidden = !isShielded
            self.totalsStackView.spacing = isShielded ? 35 : 15
            self.topSpacingStackViewConstraint.constant = isShielded ? 20 : 10
        }.store(in: &cancellables)
        
        viewModel.$isShieldedEnabled.sink { [weak self] enabled in
            if enabled {
                self?.buttonsView.setHiddenIfChanged(false)
                self?.shieldView.setHiddenIfChanged(false)
                self?.spacerView.setHiddenIfChanged(true)
            } else {
                self?.buttonsView.setHiddenIfChanged(true)
                self?.shieldView.setHiddenIfChanged(true)
                self?.spacerView.setHiddenIfChanged(false)
            }
        }.store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.$isShielded, viewModel.$hasStaked)
            .map { (isShieldedOutput, stakedOutput) -> Bool in
                isShieldedOutput == true || stakedOutput == false
            }.sink { [weak self](hideStaked) in
                self?.stakedView.setHiddenIfChanged(hideStaked)
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
            }.store(in: &cancellables)
        
        viewModel.$atDisposal
            .compactMap { $0 }
            .assign(to: \.text, on: atDisposalLabel)
            .store(in: &cancellables)
        
        viewModel.$staked
            .compactMap { $0 }
            .assign(to: \.text, on: stakedLabel)
            .store(in: &cancellables)
        
        viewModel.$bakerId
            .sink { [weak self](id) in
                if let bakerid = id {
                    self?.bakerIdLabel.text = String(format: "accounts.overview.staked".localized, bakerid)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isReadOnly
            .map { !$0 }
            .sink(receiveValue: { [weak self] isReadOnly in
                self?.readOnlyView.setHiddenIfChanged(isReadOnly)
            })
            .store(in: &cancellables)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        presenter.userTappedSend()
    }
    
    @IBAction func shieldTapped(_ sender: Any) {
        // Shield/Unshield button pressed
        presenter.userTappedShieldUnshield()
    }
    
    @IBAction func addressTapped(_ sender: Any) {
        presenter.userTappedAddress()
    }
    
    @IBAction func retryAccountCreationTapped(_ sender: Any) {
        presenter.userTappedRetryAccountCreation()
    }
    
    @IBAction func removeFailedLocalAccountTapped(_ sender: Any) {
        presenter.userTappedRemoveFailedAccount()
    }
    
    @IBAction func gtuDropTapped(_ sender: UIButton) {
        sender.isEnabled = false
        presenter.gtuDropTapped()
    }
    
    @IBAction func pressedUnlock(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        presenter.pressedUnlock()
    }
    
    @IBAction func pressedGeneral(_ sender: UIButton) {
        presenter.userSelectedGeneral()
    }
    @IBAction func pressedShielded(_ sender: UIButton) {
        presenter.userSelectedShieled()
    }
}

extension AccountDetailsViewController {
    func setupTabBar() {
        let transfersTabBarItem = MDCTabBarItem(
            title: "accountDetails.transfers".localized,
            image: nil,
            tag: 0
        )
        
        let identityDataTabBarItem = MDCTabBarItem(
            title: "accountDetails.identity_data".localized,
            image: nil, tag: 1
        )
        
        detailsTabBar.items = [
            transfersTabBarItem,
            identityDataTabBarItem
        ]
        
        detailsTabBar.preferredLayoutStyle = .fixed
        detailsTabBar.setTitleColor(.primary, for: .selected)
        detailsTabBar.setTitleColor(.text, for: .normal)
        detailsTabBar.setTitleFont(Fonts.tabBar, for: .normal)
        detailsTabBar.tintColor = .primary
        detailsTabBar.rippleColor = .clear
        detailsTabBar.selectionIndicatorStrokeColor = .primary
        detailsTabBar.setSelectedItem(transfersTabBarItem, animated: true)
        detailsTabBar.bottomDividerColor = UIColor.fadedText.withAlphaComponent(0.3)
        detailsTabBar.tabBarDelegate = self
    }
    
    fileprivate func setupIdentityDataUI() {
        identityDataVC = AccountDetailsIdentityDataFactory.create(with: presenter.getIdentityDataPresenter())
        add(child: identityDataVC, inside: containerView)
    }
    
    fileprivate func setupTransactionsUI() {
        transactionsVC = AccountTransactionsDataFactory.create(with: presenter.getTransactionsDataPresenter())
        add(child: transactionsVC, inside: containerView)
    }
    
    fileprivate func showIdentityData() {
        transactionsVC.view.isHidden = true
        if identityDataVC.hasIdentities() {
            identityDataVC.view.isHidden = false
        } else {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "accountDetails.noIdentities".localized
        }
    }
    
    private func showTransferData(accountState: SubmissionStatusEnum, isReadOnly: Bool, hasTransfers: Bool) {
        identityDataVC.view.isHidden = true
        self.setupUIBasedOn(accountState, isReadOnly: isReadOnly)
        if accountState == .finalized {
            self.updateTransfersUI(hasTransfers: hasTransfers)
        } else {
            transactionsVC.view.isHidden = true
        }
    }
    
    fileprivate func updateTransfersUI(hasTransfers: Bool) {
        // If no transfers show message
        if hasTransfers {
            transactionsVC.view.isHidden = false
            transactionsVC.tableView.reloadData()
        } else {
            transactionsVC.view.isHidden = true
            errorMessageLabel.text = "accountDetails.noTransfers".localized
        }
        
#if ENABLE_GTU_DROP
        if hasTransfers {
            self.gtuDropView.isHidden = true
            errorMessageLabel.superview?.isHidden = false
        } else {
            if presenter.showGTUDrop() {
                self.gtuDropView.isHidden = false
                errorMessageLabel.superview?.isHidden = true
            } else {
                self.gtuDropView.isHidden = true
            }
        }
#endif
    }
    
    fileprivate func setupUIBasedOn(_ state: SubmissionStatusEnum, isReadOnly: Bool) {
        var showMessage = false
        var message = ""
        var showErrorButtons = false
        var statusIconImageName = ""
        var canSend = false
        switch state {
            // received and committed should be handled the same way
            // Difference is that the committed state will have a block has because it is on a block (but no yet finalized).
            // received state is not yet in a block. Both can be interpreted as "pending" state
        case .committed, .received:
            showMessage = true
            message = "accountDetails.committedMessage".localized
            statusIconImageName = "pending"
        case .absent:
            showMessage = true
            message = "accountDetails.failedMessage".localized
            showErrorButtons = true
            statusIconImageName = "problem_icon"
        case .finalized:
            if !isReadOnly {
                canSend = true
            }
        }
        self.retryCreateButton.isHidden = !showErrorButtons
        self.removeLocalAccountButton.isHidden = !showErrorButtons
        self.errorMessageLabel.text = message
        self.statusImageView.isHidden = !showMessage
        if !statusIconImageName.isEmpty {
            self.statusImageView.image = UIImage(named: statusIconImageName)
        }
        // Disable send and address if not finalized
        if canSend {
            if !isReadOnly {
                sendView.enable()
                shieldView.enable()
            }
            addressView.enable()
        } else {
            sendView.disable()
            shieldView.disable()
            addressView.disable()
            if isReadOnly {
                addressView.enable()
            }
        }
    }
}

extension AccountDetailsViewController: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            presenter.userSelectedTransfers()
        } else {
            presenter.userSelectedIdentityData()
        }
    }
}
