//
//  CreateNicknameViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/15/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class CreateNicknameFactory {
    class func create(with presenter: CreateNicknamePresenter) -> CreateNicknameViewController {
        CreateNicknameViewController.instantiate(fromStoryboard: "Account") {coder in
            return CreateNicknameViewController(coder: coder, presenter: presenter)
        }
    }
}

class CreateNicknameViewController: KeyboardDismissableBaseViewController, CreateNicknameViewProtocol, Storyboarded {

	var presenter: CreateNicknamePresenterProtocol

    var cancellableArray = [AnyCancellable]()

    private var defaultNextButtonBottomConstraintConstant: CGFloat = 0
    private var subtitleTopConstraintDefaultConstant: CGFloat = 0

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var nextButton: StandardButton!
    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!

    init?(coder: NSCoder, presenter: CreateNicknamePresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleTopConstraintDefaultConstant = subtitleTopConstraint.constant
        defaultNextButtonBottomConstraintConstant = nextButtonBottomConstraint.constant

        presenter.view = self
        presenter.viewDidLoad()
        
        nextButton.isEnabled = !(nicknameTextField.text?.isEmpty ?? true)

        nicknameTextField.clearButtonMode = .whileEditing
        nicknameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellableArray)

        let addIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)

        subtitleTopConstraint.constant = -keyboardHeight
        nextButtonBottomConstraint.constant = keyboardHeight

    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)

        subtitleTopConstraint.constant = subtitleTopConstraintDefaultConstant
        nextButtonBottomConstraint.constant = defaultNextButtonBottomConstraintConstant
    }

    @objc func closeButtonTapped(_ sender: Any) {
        presenter.closeButtonPressed()
    }

    @IBAction func nextAction(_ sender: Any) {
        view.endEditing(true)
        presenter.next(nickname: nicknameTextField.text!)
    }

    func setProperties(_ properties: CreateNicknameProperties) {
        nicknameTextField.attributedPlaceholder = NSAttributedString(
            string: properties.textFieldPlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary]
        )

        title = properties.title
        nextButton.setTitle(properties.button, for: .normal)
        subtitleLabel.text = properties.subtitle
        detailsLabel.text = properties.details
    }

    func setNickname(_ nickname: String) {
        nicknameTextField.text = nickname
    }
    
    func showKeyboard() {
        nicknameTextField.becomeFirstResponder()
    }
}

extension CreateNicknameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        presenter.next(nickname: nicknameTextField.text!)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 35
    }
}
