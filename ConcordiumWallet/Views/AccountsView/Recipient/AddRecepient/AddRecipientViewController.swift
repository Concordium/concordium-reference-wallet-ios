//
//  AddRecipientViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/14/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class AddRecipientFactory {
    class func create(with presenter: AddRecipientPresenter) -> AddRecipientViewController {
        AddRecipientViewController.instantiate(fromStoryboard: "SendFund") { coder in
            return AddRecipientViewController(coder: coder, presenter: presenter)
        }
    }
}

class AddRecipientViewController: KeyboardDismissableBaseViewController, AddRecipientViewProtocol, Storyboarded, ShowToast {

	var presenter: AddRecipientPresenterProtocol

    private var defaultSaveButtonBottomContstraint: CGFloat = 0
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var recipientNameTextField: UITextField! {
        didSet {
             recipientNameTextField.placeholder = "addRecipient.recipientName".localized
        }
    }
    
    @IBOutlet weak var recipientAddressTextField: UITextField! {
        didSet {
            recipientAddressTextField.placeholder = "addRecipient.recipientAddress".localized
        }
    }
    
    @IBOutlet weak var saveButton: StandardButton!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!

    init?(coder: NSCoder, presenter: AddRecipientPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        saveButton.isEnabled = false
        defaultSaveButtonBottomContstraint = saveButtonBottomConstraint.constant
        Publishers.CombineLatest(recipientNameTextField.textPublisher,
                              recipientAddressTextField.textPublisher)
        .receive(on: DispatchQueue.main)
        .sink { (name, address) in
            self.presenter.calculateSaveButtonState(name: name, address: address)
        }.store(in: &cancellables)

        presenter.viewDidLoad()
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)
        saveButtonBottomConstraint.constant = keyboardHeight
    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)
        saveButtonBottomConstraint.constant = defaultSaveButtonBottomContstraint
    }

    func bind(to viewModel: AddRecipientViewModel) {
        viewModel.$address.sink(receiveValue: {
            self.recipientAddressTextField.text = $0
            // Setting text does not send a notification. Without it the textFieldPublisher is not activated. Therefore, do it manually
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self.recipientAddressTextField)
        }).store(in: &cancellables)
        
        viewModel.$name.sink(receiveValue: {
            self.recipientNameTextField.text = $0
            // Setting text does not send a notification. Without it the textFieldPublisher is not activated. Therefore, do it manually
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self.recipientNameTextField)
        }).store(in: &cancellables)
        
        viewModel.$title.sink { self.title = $0 }
            .store(in: &cancellables)
        
        viewModel.$enableSave
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &cancellables)
    }

    @IBAction func saveTapped(_ sender: Any) {
        recipientNameTextField.resignFirstResponder()
        recipientAddressTextField.resignFirstResponder()
        presenter.userTappedSave(name: recipientNameTextField.text!, address: recipientAddressTextField.text!)
    }
    
    @IBAction func qrTapped(_ sender: Any) {
        presenter.userTappedQR()
    }

    func showAddressInvalid() {
        showToast(withMessage: "addRecipient.addressInvalid".localized)
    }
}
