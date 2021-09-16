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

class SendFundViewController: BaseViewController, SendFundViewProtocol, Storyboarded {

	var presenter: SendFundPresenterProtocol
    var amountPublisher: AnyPublisher<String, Never> { amountTextField.textPublisher }
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectedRecipientLabel: UILabel!
    @IBOutlet weak var sendFundButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var costMessageLabel: UILabel!
    @IBOutlet weak var transferIconImageView: UIImageView!
    @IBOutlet weak var sendFundsButton: StandardButton!
    @IBOutlet weak var selectRecipientWidgetView: WidgetView!
    
    @IBOutlet weak var accountBalance: UILabel!
    @IBOutlet weak var accountBalanceShielded: UILabel!
    @IBOutlet weak var shieldedBalanceLockImageView: UIImageView!
    
    @IBOutlet weak var errorMessageLabel: UILabel! {
        didSet {
            errorMessageLabel.text = ""
        }
    }

    var buttonTitle: String? {
        didSet { sendFundsButton.setTitle(buttonTitle, for: .normal) }
    }

    var pageTitle: String? {
        didSet { self.title = pageTitle }
    }
    
    var showSelectRecipient: Bool = true {
        didSet {
            selectRecipientWidgetView.isHidden = !showSelectRecipient
        }
    }
    
    var showShieldedLock: Bool = false {
        didSet {
            shieldedBalanceLockImageView.image = showShieldedLock ? UIImage(named: "Icon_Shield") : nil
            shieldedBalanceLockImageView.alpha = 0.5
            self.view.layoutIfNeeded()
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
        
        amountTextField.attributedPlaceholder =
            NSAttributedString(string: amountTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])
        
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))

        keyboardWillShow { [weak self] keyboardHeight in
            self?.sendFundButtonBottomConstraint.constant = keyboardHeight
        }
        
        keyboardWillHide { [weak self] keyboardHeight in
            self?.sendFundButtonBottomConstraint.constant -= keyboardHeight
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tapGesture)

        amountTextField.delegate = self
    }

    func bind(to viewModel: SendFundViewModel) {
        
        viewModel.$recipientName
            .map { $0 ?? viewModel.selectRecipientText }
                .assign(to: \.text, on: selectedRecipientLabel)
                .store(in: &cancellables)

        viewModel.$isRecipientNameFaded
                .sink { [weak self] in
                    if $0 {
                        self?.selectedRecipientLabel.textColor = .fadedText
                    } else {
                        self?.selectedRecipientLabel.textColor = .text
                    }
                }
                .store(in: &cancellables)

        viewModel.$accountBalance
            .assign(to: \.text, on: accountBalance)
            .store(in: &cancellables)

        viewModel.$accountBalanceShielded
            .sink(receiveValue: { str in
                self.accountBalanceShielded.text = str?.appending((self.shieldedBalanceLockImageView.image != nil ? " + " : ""))
            })
            .store(in: &cancellables)
        
        viewModel.$feeMessage
            .assign(to: \.text, on: costMessageLabel)
            .store(in: &cancellables)

        viewModel.$errorMessage
            .assign(to: \.text, on: errorMessageLabel)
            .store(in: &cancellables)

        viewModel.$sendButtonEnabled
            .assign(to: \.isEnabled, on: sendFundsButton)
            .store(in: &cancellables)
        
        viewModel.$imageName
            .sink { [weak self] (imageName) in
                self?.transferIconImageView.image = UIImage(named: imageName ?? "")
        }.store(in: &cancellables)
    }

    @objc private func hideKeyboardOnTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func selectRecipientTapped(_ sender: Any) {
        presenter.userTappedSelectRecipient()
         amountTextField.resignFirstResponder()
    }

    @IBAction func sendFundTapped(_ sender: Any) {
        if let amount = amountTextField.text {
            presenter.userTappedSendFund(amount: amount)
        }
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}

extension SendFundViewController {
    @objc func closeButtonTapped() {
        presenter.userTappedClose()
    }
}

extension SendFundViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newString = text.replacingCharacters(in: range, with: replacementString)

        if newString.unsignedWholePart  > (Int.max - 999999)/1000000 {
            return false
        }
        
        // Allow only numbers, dot and up to six decimal points
        return newString.matches(regex: "^[0-9]*[\\.,]?[0-9]{0,6}$")
    }
}
