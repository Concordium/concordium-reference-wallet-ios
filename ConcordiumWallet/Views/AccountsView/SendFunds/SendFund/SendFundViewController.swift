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
    var recipientAddressPublisher: AnyPublisher<String, Never> { recipientTextField.textPublisher }
    var amountPublisher: AnyPublisher<String, Never> { amountTextField.textPublisher }

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addMemoLabel: UILabel!
    @IBOutlet weak var sendFundButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var costMessageLabel: UILabel!
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
    
    @IBOutlet weak var recipientTextField: UITextView!
    @IBOutlet weak var recipientPlacehodlerLabel: UILabel!
    @IBOutlet weak var recipientTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var errorMessageLabel: UILabel!

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

        amountTextField.attributedPlaceholder =
            NSAttributedString(string: amountTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])
        
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))

        amountTextField.delegate = self
        setupRecipientTextArea()
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)
        sendFundButtonBottomConstraint.constant = keyboardHeight
    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)
        sendFundButtonBottomConstraint.constant = .zero
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
            .map { !$0 }
            .assign(to: \.isHidden, on: errorMessageLabel)
            .store(in: &cancellables)

        viewModel.$sendButtonEnabled
            .assign(to: \.isEnabled, on: sendFundsButton)
            .store(in: &cancellables)

        viewModel.$showMemoRemoveButton
            .map { !$0 }
            .assign(to: \.isHidden, on: removeMemoButton)
            .store(in: &cancellables)
        
        viewModel.$recipientAddress
            .sink(receiveValue: { [weak self] text in
                self?.recipientTextField.text = text
                self?.updateRecipientTextArea(text: text)
            })
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
    
    @IBAction func sendFundTapped(_ sender: Any) {
        guard let amount = amountTextField.text else { return }

        presenter.userTappedSendFund(amount: amount)
    }
    
    func setupRecipientTextArea() {
        recipientTextField.textContainer.lineFragmentPadding = 0
        recipientTextField.textContainerInset = .zero
        recipientTextField.textPublisher.sink(receiveValue: { [weak self] text in
            guard let self = self else { return }
            self.updateRecipientTextArea(text: text)
        }).store(in: &cancellables)
    }
    
    func updateRecipientTextArea(text: String?) {
        if let text = text, text.count > 0 {
            self.recipientPlacehodlerLabel.isHidden = true
            guard let font = self.recipientTextField.font else { return }
            let height = text.height(withConstrainedWidth: self.recipientTextField.frame.width, font: font)
            self.recipientTextFieldHeight.constant = height
        } else {
            self.recipientPlacehodlerLabel.isHidden = false
        }
    }
}

extension SendFundViewController {
    @objc func closeButtonTapped() {
        presenter.userTappedClose()
    }
}

// MARK: - UITextFieldDelegate
extension SendFundViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        switch textField.accessibilityIdentifier {
        
        // Amount
        case amountTextField.accessibilityIdentifier:
            let text = (textField.text ?? "") as NSString
            
            let updatedText = text.replacingCharacters(
                in: range,
                with: replacementString
            )

            if updatedText.unsignedWholePart  > (Int.max - 999999)/1000000 {
                return false
            }
            
            // Allow only numbers, dot and up to six decimal points
            return updatedText.matches(regex: "^[0-9]*[\\.,]?[0-9]{0,6}$")
            
        default:
            return true
        }
    }
}
