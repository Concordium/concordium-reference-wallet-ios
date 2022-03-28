//
//  StakeAmountInputViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 03/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine
import CryptoKit

// MARK: View
protocol StakeAmountInputViewProtocol: Loadable , ShowAlert {
    func bind(viewModel: StakeAmountInputViewModel)
    var amountPublisher: AnyPublisher<String, Never> { get }
    var restakeOptionPublisher: PassthroughSubject<Bool, Error> { get }
}

class StakeAmountInputFactory {
    class func create(with presenter: StakeAmountInputPresenterProtocol) -> StakeAmountInputViewController {
        StakeAmountInputViewController.instantiate(fromStoryboard: "Stake") {coder in
            return StakeAmountInputViewController(coder: coder, presenter: presenter)
        }
    }
}

class StakeAmountInputViewController: KeyboardDismissableBaseViewController, StakeAmountInputViewProtocol, Storyboarded, Loadable {

    @IBOutlet weak var firstBalanceLabel: UILabel!
    @IBOutlet weak var firstBalanceValue: UILabel!
    @IBOutlet weak var secondBalanceLabel: UILabel!
    @IBOutlet weak var secondBalanceValue: UILabel!
    
    @IBOutlet weak var amountMessage: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
   
    @IBOutlet weak var optionalBalancesView: UIStackView!
    @IBOutlet weak var thirdBalanceLabel: UILabel!
    @IBOutlet weak var thirdBalanceValue: UILabel!
    @IBOutlet weak var fourthBalanceLabel: UILabel!
    @IBOutlet weak var fourthBalanceValue: UILabel!
    
    @IBOutlet weak var bottomDescription: UILabel!
    @IBOutlet weak var restakeController: UISegmentedControl!
    @IBOutlet weak var continueButton: StandardButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
	var presenter: StakeAmountInputPresenterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    var amountPublisher: AnyPublisher<String, Never> {
        return amountTextField.textPublisher
            .eraseToAnyPublisher()
    }
    var restakeOptionPublisher = PassthroughSubject<Bool, Error>()
    
    init?(coder: NSCoder, presenter: StakeAmountInputPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0,  bottom: 10, right: 0)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        restakeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        restakeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.whiteText], for: .selected)
        restakeController.setTitle("stake.inputamount.yesrestake".localized, forSegmentAt: 0)
        restakeController.setTitle("stake.inputamount.norestake".localized, forSegmentAt: 1)

        presenter.view = self
        presenter.viewDidLoad()
    }

    func bind(viewModel: StakeAmountInputViewModel) {
        viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        
        viewModel.$firstBalance.sink { [weak self] balanceVM in
            guard let self = self else { return }
            self.firstBalanceLabel.text = balanceVM.label
            self.firstBalanceValue.text = balanceVM.value
        }.store(in: &cancellables)
        
        viewModel.$secondBalance.sink { [weak self] balanceVM in
            guard let self = self else { return }
            self.secondBalanceLabel.text = balanceVM.label
            self.secondBalanceValue.text = balanceVM.value
        }.store(in: &cancellables)
        
        viewModel.$showsPoolLimits
            .compactMap { !$0 }
            .assign(to: \.isHidden, on: optionalBalancesView)
            .store(in: &cancellables)
        
        viewModel.$currentPoolLimit.sink { [weak self] balanceVM in
            guard let self = self else { return }
            guard let balanceVM = balanceVM else { return }
            self.thirdBalanceLabel.text = balanceVM.label
            self.thirdBalanceValue.text = balanceVM.value
        }.store(in: &cancellables)
        
        viewModel.$poolLimit.sink { [weak self] balanceVM in
            guard let self = self else { return }
            guard let balanceVM = balanceVM else { return }
            self.fourthBalanceLabel.text = balanceVM.label
            self.fourthBalanceValue.text = balanceVM.value
        }.store(in: &cancellables)
        
        viewModel.$amountMessage
            .compactMap { $0 }
            .assign(to: \.text, on: amountMessage)
            .store(in: &cancellables)
        
        viewModel.$transactionFee
            .compactMap { $0 }
            .assign(to: \.text, on: transactionFeeLabel)
            .store(in: &cancellables)
        
        viewModel.$amountErrorMessage.sink { [weak self] errorMessage in
            guard let self = self else { return }
            if let errorMessage = errorMessage {
                self.errorLabel.text = errorMessage
                self.errorLabel.isHidden = false
                self.amountTextField.textColor = .errorText
            } else {
                self.errorLabel.isHidden = true
                self.amountTextField.textColor = .primary
            }
        }.store(in: &cancellables)
        
        viewModel.$amount
            .compactMap { $0 }
            .assign(to: \.text, on: amountTextField)
            .store(in: &cancellables)
        
        viewModel.$bottomMessage
            .compactMap { $0 }
            .assign(to: \.text, on: bottomDescription)
            .store(in: &cancellables)
        
        viewModel.$isRestakeSelected.sink { [weak self] isRestakeSelected in
            if isRestakeSelected {
                self?.restakeController.selectedSegmentIndex = 0
            } else {
                self?.restakeController.selectedSegmentIndex = 1
            }
        }.store(in: &cancellables)
        
        viewModel.$isContinueEnabled
            .compactMap { $0 }
            .assign(to: \.isEnabled, on: continueButton)
            .store(in: &cancellables)
        
        viewModel.$isAmountLocked.sink { [weak self] isAmountLocked in
            if isAmountLocked {
                self?.amountTextField.placeholder = "stake.inputAmount.amountlockedplaceholder".localized
                self?.amountTextField.isUserInteractionEnabled = false
            } else {
                self?.amountTextField.placeholder = "stake.inputAmount.amountplaceholder".localized
                self?.amountTextField.isUserInteractionEnabled = true
            }
        }.store(in: &cancellables)
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = -keyboardHeight
        view.layoutIfNeeded()
    }
    
    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func restakeValueChanged(_ sender: UISegmentedControl) {
        restakeOptionPublisher.send(sender.selectedSegmentIndex == 0)
    }
    
    @IBAction func pressedContinue(_ sender: UIButton) {
        presenter.pressedContinue()
    }
}


// MARK: - UITextFieldDelegate
extension StakeAmountInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
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
        
    }
}

//extension StakeAmountInputViewController: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            view.endEditing(true)
//            return false
//        }
//        return true
//    }
//}
