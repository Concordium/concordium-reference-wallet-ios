//
//  SendFundViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/7/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import UIKit
import SDWebImage
class SendFundFactory {
    class func create(with presenter: SendFundPresenter) -> SendFundViewController {
        SendFundViewController.instantiate(fromStoryboard: "SendFund") { coder in
            SendFundViewController(coder: coder, presenter: presenter)
        }
    }
}

enum SendFundsViewError: Error {
    case parseError(FungibleTokenParseError)
    case insufficientFunds
    
    var localizedDescription: String {
        switch self {
        case .parseError(let fungibleTokenParseError):
            return fungibleTokenParseError.localizedDescription
        case .insufficientFunds:
            return "sendFund.insufficientFunds".localized
        }
    }
}

class SendFundViewController: KeyboardDismissableBaseViewController, SendFundViewProtocol, Storyboarded {
    var presenter: SendFundPresenterProtocol
    var recipientAddressPublisher: AnyPublisher<String, Never> { recipientTextView.textPublisher }
    var selectedTokenType = PassthroughSubject<SendFundsTokenSelection, Never>()

    @IBOutlet var mainStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var mainStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var addMemoLabel: UILabel!

    @IBOutlet var costMessageLabel: UILabel!
    @IBOutlet var sendAllButton: StandardButton!
    @IBOutlet var sendFundsButton: StandardButton!
    @IBOutlet var selectRecipientWidgetView: UIView!
    @IBOutlet var addMemoWidgetView: WidgetView!
    @IBOutlet var addMemoWidgetLabel: UILabel!
    @IBOutlet var removeMemoButton: UIButton!

    @IBOutlet var firstBalanceNameLabel: UILabel!
    @IBOutlet var secondBalanceNameLabel: UILabel!

    @IBOutlet var tokenSelectionStackView: UIStackView!
    @IBOutlet var selectedTokenName: UILabel!
    @IBOutlet var selectedTokenImageView: UIImageView!
    @IBOutlet var firstBalanceLabel: UILabel!
    @IBOutlet var secondBalanceLabel: UILabel!
    @IBOutlet var shieldedBalanceLockImageView: UIImageView! {
        didSet {
            shieldedBalanceLockImageView.alpha = 0.5
        }
    }

    var amountTextPublisher: AnyPublisher<String, Never> {
        amountTextField.textPublisher
    }
    @IBOutlet var recipientTextView: UITextView!
    @IBOutlet var recipientPlacehodlerLabel: UILabel!
    @IBOutlet var recipientTextFieldHeight: NSLayoutConstraint!
    @IBOutlet var errorMessageLabel: UILabel!

    @IBOutlet var tokenSelectionViewWrapper: UIView!
    private var defaultMainStackViewTopConstraintConstant: CGFloat = 0
    private var defaultMainStackViewBottomConstraintConstant: CGFloat = 0

    private lazy var textFieldDelegate = GTUTextFieldDelegate { [weak self] value, isValid in
        if isValid {
            self?.presenter.userChangedAmount()
        }
    }

    private var cancellables = [AnyCancellable]()

    init?(coder: NSCoder, presenter: SendFundPresenterProtocol) {
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
        errorMessageLabel.alpha = 0

        amountTextField.attributedPlaceholder =
            NSAttributedString(string: amountTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])

        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(closeButtonTapped))

        amountTextField.delegate = textFieldDelegate
        setupRecipientTextArea()

        defaultMainStackViewBottomConstraintConstant = mainStackViewBottomConstraint.constant
        defaultMainStackViewTopConstraintConstant = mainStackViewTopConstraint.constant

        let guesture = UITapGestureRecognizer(target: self, action: #selector(selectToken(_:)))
        tokenSelectionStackView.addGestureRecognizer(guesture)
        tokenSelectionViewWrapper.layer.cornerRadius = 10
        tokenSelectionViewWrapper.layer.borderWidth = 1.0
        tokenSelectionViewWrapper.layer.borderColor = Pallette.primary.cgColor
        tokenSelectionStackView.isUserInteractionEnabled = true
    }

    @objc private func selectToken(_ sender: AnyObject) {
        presenter.selectTokenType()
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)
        mainStackViewBottomConstraint.constant = keyboardHeight
        mainStackViewTopConstraint.constant = -(keyboardHeight / 2)
    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)
        mainStackViewTopConstraint.constant = defaultMainStackViewTopConstraintConstant
        mainStackViewBottomConstraint.constant = defaultMainStackViewBottomConstraintConstant
    }

    // swiftlint:disable:next function_body_length
    func bind(to viewModel: SendFundViewModel) {
        
        viewModel.$buttonTitle
            .sink { [weak self] buttonTitle in
                self?.sendFundsButton.setTitle(buttonTitle, for: .normal)
            }
            .store(in: &cancellables)

        viewModel.$pageTitle
            .assign(to: \.title, on: self)
            .store(in: &cancellables)

        viewModel.$showMemoAndRecipient
            .sink { [weak self] showMemoAndRecipient in
                self?.selectRecipientWidgetView.isHidden = !showMemoAndRecipient
                self?.addMemoWidgetView.isHidden = !showMemoAndRecipient
            }
            .store(in: &cancellables)

        viewModel.$showShieldedLock
            .map { !$0 }
            .assign(to: \.isHidden, on: shieldedBalanceLockImageView)
            .store(in: &cancellables)

        viewModel.$addMemoText
            .assign(to: \.text, on: addMemoLabel)
            .store(in: &cancellables)

        viewModel.$firstBalance
            .assign(to: \.text, on: firstBalanceLabel)
            .store(in: &cancellables)

        viewModel.$firstBalanceName
            .assign(to: \.text, on: firstBalanceNameLabel)
            .store(in: &cancellables)

        viewModel.$secondBalance
            .assign(to: \.text, on: secondBalanceLabel)
            .store(in: &cancellables)

        viewModel.$secondBalanceName
            .assign(to: \.text, on: secondBalanceNameLabel)
            .store(in: &cancellables)

        viewModel.$feeMessage
            .assign(to: \.text, on: costMessageLabel)
            .store(in: &cancellables)

        viewModel.$shouldShowError
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShowError in
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.errorMessageLabel.alpha = shouldShowError ? 1 : 0
                }
            })
            .store(in: &cancellables)

        viewModel.$selectedTokenType
            .map { type in
                if case let SendFundsTokenSelection.cis2(token: token) = type {
                    return token.symbol ?? token.name
                } else {
                    return "CCD"
                }
            }
            .assign(to: \.text, on: self.selectedTokenName)
            .store(in: &cancellables)

        viewModel.$selectedTokenType
            .sink { type in
                if case let SendFundsTokenSelection.cis2(token: token) = type {
                    self.selectedTokenImageView.sd_setImage(with: token.thumbnail, placeholderImage: UIImage(systemName: "photo"))
                } else {
                    self.selectedTokenImageView.image = UIImage(named: "concordium_logo")
                }
            }
            .store(in: &cancellables)
        
        viewModel.$sendButtonEnabled
            .assign(to: \.isEnabled, on: sendFundsButton)
            .store(in: &cancellables)

        viewModel.$sendAllEnabled
            .assign(to: \.isEnabled, on: sendAllButton)
            .store(in: &cancellables)

        viewModel.$sendAllVisible
            .sink { [weak self] isVisible in
                self?.sendAllButton.isHidden = !isVisible
            }
            .store(in: &cancellables)

        viewModel.$showMemoRemoveButton
            .map { !$0 }
            .assign(to: \.isHidden, on: removeMemoButton)
            .store(in: &cancellables)

        viewModel.$recipientAddress
            .sink(receiveValue: { [weak self] text in
                self?.recipientTextView.text = text
                self?.updateRecipientTextArea(text: text)
            })
            .store(in: &cancellables)

        viewModel.$sendAllAmount
            .compactMap { $0 }
            .assign(to: \.text, on: amountTextField)
            .store(in: &cancellables)
        
        viewModel.$selectedTokenType
            .map { $0 != .ccd }
            .assign(to: \.isHidden, on: addMemoWidgetView)
            .store(in: &cancellables)
        
        viewModel.$transferType
            .map { _ in false }
            .assign(to: \.isHidden, on: tokenSelectionViewWrapper)
            .store(in: &cancellables)
    }

    func showMemoWarningAlert(_ completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "warningAlert.transactionMemo.title".localized,
            message: "warningAlert.transactionMemo.text".localized,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "errorAlert.okButton".localized,
            style: .default
        ) { _ in
            completion()
        }

        let dontShowAgain = UIAlertAction(
            title: "warningAlert.dontShowAgainButton".localized,
            style: .default
        ) { [weak self] _ in
            self?.presenter.userTappedDontShowMemoAlertAgain { completion() }
        }

        alert.addAction(okAction)
        alert.addAction(dontShowAgain)

        present(alert, animated: true)
    }

    @IBAction func selectRecipientTapped(_ sender: Any) {
        presenter.userTappedSelectRecipient()
        view.endEditing(true)
    }

    @IBAction func scanQRTapped(_ sender: Any) {
        presenter.userTappedScanQR()
        view.endEditing(true)
    }

    @IBAction func addMemoTapped(_ sender: Any) {
        presenter.userTappedAddMemo()
        view.endEditing(true)
    }

    @IBAction func removeMemoTapped(_ sender: Any) {
        presenter.userTappedRemoveMemo()
    }

    @IBAction func sendAllTapped(_ sender: Any) {
        presenter.userTappedSendAll()
    }

    @IBAction func sendFundTapped(_ sender: Any) {
        guard let _ = amountTextField.text else { return }
        presenter.userTappedSendFund()
    }

    func setupRecipientTextArea() {
        recipientTextView.textContainer.lineFragmentPadding = 0
        recipientTextView.textContainerInset = .zero
        recipientTextView.textPublisher.sink(receiveValue: { [weak self] text in
            guard let self = self else { return }
            self.updateRecipientTextArea(text: text)
        }).store(in: &cancellables)
    }

    func updateRecipientTextArea(text: String?) {
        if let text = text {
            if text.count > 0 {
                recipientPlacehodlerLabel.isHidden = true
            }
            guard let font = recipientTextView.font else { return }
            let height = text.height(withConstrainedWidth: recipientTextView.frame.width, font: font)
            recipientTextFieldHeight.constant = height
        } else {
            recipientPlacehodlerLabel.isHidden = false
        }
    }

    @IBAction func recipientTextFieldEndEditing(_ sender: Any) {
        view.endEditing(true)
    }

    func showAddressInvalid() {
        showToast(withMessage: "addRecipient.addressInvalid".localized, time: 1)
    }

    override func didDismissKeyboard() {
        super.didDismissKeyboard()
        presenter.finishedEditingRecipientAddress()
    }
}

extension SendFundViewController {
    @objc func closeButtonTapped() {
        presenter.userTappedClose()
    }
}

extension SendFundViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView.accessibilityIdentifier {
        case recipientTextView.accessibilityIdentifier:
            if text == "\n" {
                presenter.finishedEditingRecipientAddress()
                view.endEditing(true)
                return false
            }
            return true
        default:
            return true
        }
    }
}
