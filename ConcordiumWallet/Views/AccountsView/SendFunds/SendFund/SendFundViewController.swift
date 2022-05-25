//
//  SendFundViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/7/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class SendFundFactory {
    class func create(with presenter: SendFundPresenter) -> SendFundViewController {
        SendFundViewController.instantiate(fromStoryboard: "SendFund") {coder in
            return SendFundViewController(coder: coder, presenter: presenter)
        }
    }
}

class SendFundViewController: KeyboardDismissableBaseViewController, SendFundViewProtocol, Storyboarded {
	var presenter: SendFundPresenterProtocol
    var recipientAddressPublisher: AnyPublisher<String, Never> { recipientTextView.textPublisher }
    var amountSubject = PassthroughSubject<String, Never>()

    @IBOutlet weak var mainStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addMemoLabel: UILabel!

    @IBOutlet weak var costMessageLabel: UILabel!
    @IBOutlet weak var sendAllButton: StandardButton!
    @IBOutlet weak var sendFundsButton: StandardButton!
    @IBOutlet weak var selectRecipientWidgetView: UIView!
    @IBOutlet weak var addMemoWidgetView: WidgetView!
    @IBOutlet weak var addMemoWidgetLabel: UILabel!
    @IBOutlet weak var removeMemoButton: UIButton!
    
    @IBOutlet weak var firstBalanceNameLabel: UILabel!
    @IBOutlet weak var secondBalanceNameLabel: UILabel!
    
    @IBOutlet weak var firstBalanceLabel: UILabel!
    @IBOutlet weak var secondBalanceLabel: UILabel!
    @IBOutlet weak var shieldedBalanceLockImageView: UIImageView! {
        didSet {
            shieldedBalanceLockImageView.alpha = 0.5
        }
    }
    
    @IBOutlet weak var recipientTextView: UITextView!
    @IBOutlet weak var recipientPlacehodlerLabel: UILabel!
    @IBOutlet weak var recipientTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var errorMessageLabel: UILabel!

    private var defaultMainStackViewTopConstraintConstant: CGFloat = 0
    private var defaultMainStackViewBottomConstraintConstant: CGFloat = 0
    
    private lazy var textFieldDelegate = GTUTextFieldDelegate { [weak self] _, isValid in
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))

        amountTextField.delegate = textFieldDelegate
        setupRecipientTextArea()

        defaultMainStackViewBottomConstraintConstant = mainStackViewBottomConstraint.constant
        defaultMainStackViewTopConstraintConstant = mainStackViewTopConstraint.constant

        amountTextField.textPublisher
            .sink(receiveValue: { [weak self] text in
                self?.amountSubject.send(text)
            })
            .store(in: &cancellables)
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

        viewModel.$insufficientFunds
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasSufficientFunds  in
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.errorMessageLabel.alpha = hasSufficientFunds ? 1 : 0
                }
            })
            .store(in: &cancellables)

        viewModel.$sendButtonEnabled
            .assign(to: \.isEnabled, on: sendFundsButton)
            .store(in: &cancellables)

        viewModel.$sendAllEnabled
            .assign(to: \.isEnabled, on: sendAllButton)
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
        guard let amount = amountTextField.text else { return }

        presenter.userTappedSendFund(amount: amount)
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
                self.recipientPlacehodlerLabel.isHidden = true
            }
            guard let font = self.recipientTextView.font else { return }
            let height = text.height(withConstrainedWidth: self.recipientTextView.frame.width, font: font)
            self.recipientTextFieldHeight.constant = height
        } else {
            self.recipientPlacehodlerLabel.isHidden = false
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
