//
//  AccountDetailsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/30/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

struct AccountTokensView: View {
    var tabBarViewModel: MaterialTabBar.ViewModel = .init()

    init() {
        tabBarViewModel.tabs = ["Fungible", "Collectibles", "Manage"]
    }

    var body: some View {
        VStack {
            MaterialTabBar(viewModel: tabBarViewModel)
        }
    }
}

class AccountDetailsFactory {
    class func create(with presenter: AccountDetailsPresenter) -> AccountDetailsViewController {
        AccountDetailsViewController.instantiate(fromStoryboard: "Account") { coder in
            AccountDetailsViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountDetailsViewController: BaseViewController, AccountDetailsViewProtocol, Storyboarded, ShowAlert {
    var presenter: AccountDetailsPresenterProtocol
    var isShielded: Bool = false
    private weak var updateTimer: Timer?
    private let tabViewModel = MaterialTabBar.ViewModel()
    private var sendEnabled: Bool = false
    private var receiveEnabled: Bool = false
    private var shieldEnabled: Bool = false
    private var viewModel: AccountDetailsViewModel!

    @IBOutlet var tabBar: UIView!
    @IBOutlet var totalsStackView: UIStackView!
    @IBOutlet var retryCreateButton: StandardButton!
    @IBOutlet var removeLocalAccountButton: StandardButton!

    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var containerView: UIView!

    @IBOutlet var backgroundShield: UIImageView!

    @IBOutlet var readOnlyView: UIView!
    @IBOutlet var balanceNameLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var atDisposalView: UIView!
    @IBOutlet var stakedView: UIView!

    @IBOutlet var atDisposalLabel: UILabel!
    @IBOutlet var stakedValueLabel: UILabel!
    @IBOutlet var stakedLabel: UILabel!

    @IBOutlet var buttonsView: UIView!
    @IBOutlet var generalButton: UIButton!
    @IBOutlet var shieldedButton: UIButton!
    @IBOutlet var spacerView: UIView!
    @IBOutlet var topSpacingStackViewConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSliderContainer: RoundedCornerView!
    private var accountTokensViewController = UIHostingController(rootView: AccountTokensView())
    @IBOutlet var gtuDropView: UIView! {
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
        gtuDropView.isHidden = true

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
        if isMovingFromParent {
            presenter.viewWillDisappear()
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
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

    func startRefreshTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 5.0,
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

    private func setupButtonSlider(isShielded: Bool) {
        let areActionsEnabled = viewModel.accountState == .finalized && !viewModel.isReadOnly

        let buttonSlider = ButtonSlider(
            isShielded: isShielded,
            didTapTokensButton: { [weak self] in
                self?.viewModel.selectedSection = .tokens
                self?.transactionsVC.view.isHidden = true
                self?.tabBar.isHidden = true
                self?.accountTokensViewController.view.isHidden = false
            },
            actionSend: {
                if self.sendEnabled {
                    self.presenter.userTappedSend()
                }
            },
            didTapTransactionList: { [weak self] in
                self?.viewModel.selectedSection = .transfers
                self?.transactionsVC.view.isHidden = false
//                self?.tabBar.isHidden = false
                self?.accountTokensViewController.view.isHidden = true

            },
            actionReceive: {
                if self.receiveEnabled {
                    self.presenter.userTappedAddress()
                }
            },
            actionEarn: {
                self.presenter.showEarn()
            },
            actionShield: {
                if self.shieldEnabled {
                    self.presenter.userTappedShieldUnshield()
                }
            },
            actionSettings: {
                self.presenter.burgerButtonTapped()
            },
            selectedSection: viewModel.selectedSection,
            isDisabled: !areActionsEnabled
        )
        show(buttonSlider, in: buttonSliderContainer)
    }

    private func setupButtonsShielded() {
        let buttonsShielded = ButtonsShielded(
            actionSendShielded: {
                if self.sendEnabled {
                    self.presenter.userTappedSend()
                }
            },
            actionUnshield: {
                if self.shieldEnabled {
                    self.presenter.userTappedShieldUnshield()
                }
            },
            actionReceive: {
                if self.receiveEnabled {
                    self.presenter.userTappedAddress()
                }
            })
        show(buttonsShielded, in: buttonSliderContainer)
    }

    // swiftlint:disable function_body_length
    func bind(to viewModel: AccountDetailsViewModel) {
        self.viewModel = viewModel

        showTransferData(accountState: viewModel.accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: viewModel.hasTransfers)

        tabViewModel.$selectedIndex
            .sink { [weak self] index in
                if index == 0 {
                    self?.presenter.userSelectedTransfers()
                    self?.showTransferData(
                        accountState: viewModel.accountState,
                        isReadOnly: viewModel.isReadOnly,
                        hasTransfers: viewModel.hasTransfers
                    )
                } else {
                    self?.presenter.userSelectedIdentityData()
                    self?.showIdentityData()
                }
            }
            .store(in: &cancellables)

        viewModel.$selectedBalance
            .sink { [weak self] _ in
                self?.tabViewModel.selectedIndex = 0
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(viewModel.$hasTransfers, viewModel.$accountState)
            .sink { [weak self] (hasTransfers: Bool, accountState: SubmissionStatusEnum) in
                self?.showTransferData(accountState: accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: hasTransfers)
            }.store(in: &cancellables)

        viewModel.$balance
            .compactMap { $0 }
            .assign(to: \.text, on: balanceLabel)
            .store(in: &cancellables)

        viewModel.$isShielded.sink { [weak self] isShielded in
            guard let self = self else { return }

            self.isShielded = isShielded
            self.title = self.presenter.getTitle()
            self.atDisposalView.setHiddenIfChanged(isShielded)

            self.generalButton.backgroundColor = isShielded ? UIColor.primary : UIColor.primarySelected
            self.shieldedButton.backgroundColor = isShielded ? UIColor.primarySelected : UIColor.primary

            if isShielded {
                self.balanceNameLabel.text = String(format: "accounts.overview.shieldedtotal".localized, viewModel.name ?? "")
                self.stakedView.setHiddenIfChanged(true)
            } else {
                self.balanceNameLabel.text = "accounts.overview.generaltotal".localized
                if viewModel.hasStaked {
                    self.stakedView.setHiddenIfChanged(false)
                } else {
                    self.stakedView.setHiddenIfChanged(true)
                }
            }
            self.backgroundShield.isHidden = !isShielded
            self.totalsStackView.spacing = isShielded ? 35 : 15
            self.topSpacingStackViewConstraint.constant = isShielded ? 20 : 10

            if isShielded {
                self.setupButtonsShielded()
            } else {
                self.setupButtonSlider(isShielded: viewModel.isShieldedEnabled)
            }

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }.store(in: &cancellables)

        viewModel.$isShieldedEnabled.sink { [weak self] enabled in
            if enabled {
                self?.buttonsView.setHiddenIfChanged(false)
                self?.spacerView.setHiddenIfChanged(true)
            } else {
                self?.buttonsView.setHiddenIfChanged(true)
                self?.spacerView.setHiddenIfChanged(false)
            }
        }.store(in: &cancellables)

        viewModel.$atDisposal
            .compactMap { $0 }
            .assign(to: \.text, on: atDisposalLabel)
            .store(in: &cancellables)

        viewModel.$stakedValue
            .compactMap { $0 }
            .assign(to: \.text, on: stakedValueLabel)
            .store(in: &cancellables)

        viewModel.$stakedLabel
            .sink { [weak self] text in
                self?.stakedLabel.text = text
            }
            .store(in: &cancellables)

        viewModel.$isReadOnly
            .map { !$0 }
            .sink(receiveValue: { [weak self] isReadOnly in
                self?.readOnlyView.setHiddenIfChanged(isReadOnly)
            })
            .store(in: &cancellables)
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
        tabViewModel.tabs = [
            "accountDetails.transfers".localized,
        ]

        show(MaterialTabBar(viewModel: tabViewModel), in: tabBar)
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
        setupUIBasedOn(accountState, isReadOnly: isReadOnly)
        if accountState == .finalized {
            updateTransfersUI(hasTransfers: hasTransfers)
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
                gtuDropView.isHidden = true
                errorMessageLabel.superview?.isHidden = false
            } else {
                if presenter.showGTUDrop() {
                    gtuDropView.isHidden = false
                    errorMessageLabel.superview?.isHidden = true
                } else {
                    gtuDropView.isHidden = true
                    errorMessageLabel.superview?.isHidden = false
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
        retryCreateButton.isHidden = !showErrorButtons
        removeLocalAccountButton.isHidden = !showErrorButtons
        errorMessageLabel.text = message
        statusImageView.isHidden = !showMessage
        if !statusIconImageName.isEmpty {
            statusImageView.image = UIImage(named: statusIconImageName)
        }
        // Disable send and address if not finalized
        if canSend {
            if !isReadOnly {
                sendEnabled = true
                shieldEnabled = true
            }
            receiveEnabled = true
        } else {
            sendEnabled = false
            receiveEnabled = false
            shieldEnabled = false
            if isReadOnly {
                receiveEnabled = true
            }
        }
    }
}
