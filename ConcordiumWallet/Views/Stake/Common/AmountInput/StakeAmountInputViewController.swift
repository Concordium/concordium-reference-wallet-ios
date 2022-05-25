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
protocol StakeAmountInputViewProtocol: Loadable, ShowAlert {
    func bind(viewModel: StakeAmountInputViewModel)
    var amountPublisher: AnyPublisher<String, Never> { get }
    var restakeOptionPublisher: PassthroughSubject<Bool, Never> { get }
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
    
    private lazy var textFieldDelegate = GTUTextFieldDelegate { _, _ in }
  
    var amountPublisher: AnyPublisher<String, Never> {
        return amountTextField.textPublisher
    }
    var restakeOptionPublisher = PassthroughSubject<Bool, Never>()
    
    init?(coder: NSCoder, presenter: StakeAmountInputPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                     left: 0,
                                                     bottom: 10,
                                                     right: 0)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        restakeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        restakeController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.whiteText], for: .selected)
        restakeController.setTitle("stake.inputamount.yesrestake".localized, forSegmentAt: 0)
        restakeController.setTitle("stake.inputamount.norestake".localized, forSegmentAt: 1)
        
        amountTextField.delegate = textFieldDelegate

        presenter.view = self
        presenter.viewDidLoad()
        showCloseButton()
        
    }
    func showCloseButton() {
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
    }

    @objc func closeButtonTapped() {
        presenter.closeButtonTapped()
    }

    // swiftlint:disable function_body_length
    func bind(viewModel: StakeAmountInputViewModel) {
        
        viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        
        viewModel.$firstBalance.sink { [weak self] balanceVM in
            guard let self = self else { return }
            self.firstBalanceLabel.text = balanceVM.label
            self.firstBalanceLabel.textColor = balanceVM.hightlighted ? .errorText : .text
            self.firstBalanceValue.text = balanceVM.value
            self.firstBalanceValue.textColor = balanceVM.hightlighted ? .errorText : .text
        }.store(in: &cancellables)
        
        viewModel.$secondBalance.sink { [weak self] balanceVM in
            guard let self = self else { return }
            self.secondBalanceLabel.text = balanceVM.label
            self.secondBalanceLabel.textColor = balanceVM.hightlighted ? .errorText : .text
            self.secondBalanceValue.text = balanceVM.value
            self.secondBalanceValue.textColor = balanceVM.hightlighted ? .errorText : .text
        }.store(in: &cancellables)
        
        viewModel.$showsPoolLimits
            .compactMap { !$0 }
            .assign(to: \.isHidden, on: optionalBalancesView)
            .store(in: &cancellables)
        
        viewModel.$currentPoolLimit.sink { [weak self] balanceVM in
            guard let self = self else { return }
            guard let balanceVM = balanceVM else { return }
            self.thirdBalanceLabel.text = balanceVM.label
            self.thirdBalanceLabel.textColor = balanceVM.hightlighted ? .errorText : .text
            self.thirdBalanceValue.text = balanceVM.value
            self.thirdBalanceValue.textColor = balanceVM.hightlighted ? .errorText : .text
        }.store(in: &cancellables)
        
        viewModel.$poolLimit.sink { [weak self] balanceVM in
            guard let self = self else { return }
            guard let balanceVM = balanceVM else { return }
            self.fourthBalanceLabel.text = balanceVM.label
            self.fourthBalanceLabel.textColor = balanceVM.hightlighted ? .errorText : .text
            self.fourthBalanceValue.text = balanceVM.value
            self.fourthBalanceValue.textColor = balanceVM.hightlighted ? .errorText : .text
        }.store(in: &cancellables)
        
        viewModel.$amountMessage
            .compactMap { $0 }
            .assign(to: \.text, on: amountMessage)
            .store(in: &cancellables)
        
        amountTextField
            .textPublisher
            .assignNoRetain(to: \.amount, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$transactionFee
            .compactMap { $0 }
            .assign(to: \.text, on: transactionFeeLabel)
            .store(in: &cancellables)
        
        viewModel.$amountErrorMessage
            .combineLatest(viewModel.$hasStartedInput)
            .sink { [weak self] (errorMessage, hasStartedInput) in
            guard let self = self else { return }
            if let errorMessage = errorMessage, hasStartedInput {
                self.errorLabel.text = errorMessage
                self.errorLabel.isHidden = false
                self.amountTextField.textColor = .errorText
            } else {
                self.errorLabel.isHidden = true
                self.amountTextField.textColor = .primary
            }
        }.store(in: &cancellables)
        
        amountTextField.textPublisher
            .assignNoRetain(to: \.amount, on: viewModel)
            .store(in: &cancellables)
        
        amountTextField.textPublisher
            .first()
            .sink { _ in viewModel.hasStartedInput = true }
            .store(in: &cancellables)
        
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
        
        restakeOptionPublisher
            .assignNoRetain(to: \.isRestakeSelected, on: viewModel)
            .store(in: &cancellables)
        
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
