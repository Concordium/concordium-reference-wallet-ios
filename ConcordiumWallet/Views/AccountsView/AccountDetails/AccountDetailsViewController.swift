//
//  AccountDetailsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/30/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

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
    private var sendEnabled: Bool = false
    private var receiveEnabled: Bool = false
    private var shieldEnabled: Bool = false
    private var viewModel: AccountDetailsViewModel!

    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var totalsStackView: UIStackView!
    @IBOutlet weak var retryCreateButton: StandardButton!
    @IBOutlet weak var removeLocalAccountButton: StandardButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var backgroundShield: UIImageView!
    
    @IBOutlet weak var readOnlyView: UIView!
    @IBOutlet weak var balanceNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var atDisposalView: UIView!
    @IBOutlet weak var stakedView: UIView!
    
    @IBOutlet weak var atDisposalLabel: UILabel!
    @IBOutlet weak var stakedValueLabel: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var generalButton: UIButton!
    @IBOutlet weak var shieldedButton: UIButton!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var topSpacingStackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonSliderContainer: RoundedCornerView!
    
    @IBOutlet weak var buttonSliderContainerConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var gtuDropView: UIView! {
        didSet {
            gtuDropView.isHidden = true
        }
    }
    var transactionsVC: AccountTransactionsDataViewController!
    var accountTokensViewController: AccountTokensViewController!

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
        setupTransactionsUI()
        setupAccountTokensUI()
        title = presenter.getTitle()
        presenter.view = self
        presenter.viewDidLoad()
        
        viewModel.$selectedSection.map { $0 != .tokens }
            .assign(to: \.isHidden, on: accountTokensViewController.view)
            .store(in: &cancellables)

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

    private func setupButtonSlider() {
        let areActionsEnabled = viewModel.accountState == .finalized && !viewModel.isReadOnly

        let buttonSlider = ButtonSlider(
            didTapTokensButton: { [weak self] in
                self?.viewModel.selectedSection = .tokens
            },
            actionSend: {
                if self.sendEnabled {
                    self.presenter.userTappedSend()
                }
            },
            didTapTransactionList: { [weak self] in
                self?.viewModel.selectedSection = .transfers
            },
            actionReceive: {
                if self.receiveEnabled {
                    self.presenter.userTappedAddress()
                }
            },
            actionEarn: {
                self.presenter.showEarn()
            },
            actionSettings: {
                self.presenter.burgerButtonTapped()
            },
            isDisabled: !areActionsEnabled
        )
        let childView = UIHostingController(rootView: buttonSlider)
        addChild(childView)
        childView.view.frame = buttonSliderContainer.bounds
        buttonSliderContainer.subviews.forEach { $0.removeFromSuperview() }
        buttonSliderContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
    }

    // swiftlint:disable function_body_length
    func bind(to viewModel: AccountDetailsViewModel) {
        self.viewModel = viewModel

        showTransferData(accountState: viewModel.accountState, isReadOnly: viewModel.isReadOnly, hasTransfers: viewModel.hasTransfers)
        
        // HACK: Remnant from legacy wallet code that ensures the UI to be updated appropriately when shilded balances are enabled or hidden.
        //       The value of 'selectedBalance' isn't actually ever written (nor read!); the reason this works is that
        //       'switchToBalanceType', 'hideShieldedTapped' etc. re-binds the view model, causing the (hardcoded) value '.balance' to be republished.
        //       Via this observer, 'updateTransfers' is called when this happens to refresh the UI at just the right time.
        viewModel.$selectedBalance
                .sink { [weak self] _ in
                    self?.presenter.userSelectedTransfers()
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
                self.viewModel.selectedSection = .transfers
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
                self.buttonSliderContainer.subviews.forEach { $0.removeFromSuperview() }
                self.buttonSliderContainer.isHidden = true
                self.buttonSliderContainerConstraintHeight.constant = 0
            } else {
                self.setupButtonSlider()
                self.buttonSliderContainer.isHidden = false
                self.buttonSliderContainerConstraintHeight.constant = 60
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
            .sink { [weak self](text) in
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

private extension AccountDetailsViewController {

    func setupAccountTokensUI() {
        accountTokensViewController = AccountTokensViewFactory.create(with: presenter)
        add(child: accountTokensViewController, inside: containerView)
    }

    func setupTransactionsUI() {
        transactionsVC = AccountTransactionsDataFactory.create(with: presenter.createTransactionsDataPresenter())
        add(child: transactionsVC, inside: containerView)
    }

    func showTransferData(accountState: SubmissionStatusEnum, isReadOnly: Bool, hasTransfers: Bool) {
        setupUIBasedOn(accountState, isReadOnly: isReadOnly)
        if accountState == .finalized {
            updateTransfersUI(hasTransfers: hasTransfers)
        } else {
            transactionsVC.view.isHidden = true
        }
    }
    
    func updateTransfersUI(hasTransfers: Bool) {
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
                errorMessageLabel.superview?.isHidden = false
            }
        }
#endif
    }
    
    func setupUIBasedOn(_ state: SubmissionStatusEnum, isReadOnly: Bool) {
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
