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

    private var cancellables = [AnyCancellable]()
    private var defaultNextButtonBottomConstraintConstant: CGFloat = 0
    private var subtitleTopConstraintDefaultConstant: CGFloat = 0

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var nextButton: StandardButton!
    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!

    var namePublisher: AnyPublisher<String, Never> { nicknameTextField.textPublisher }

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

        nicknameTextField.clearButtonMode = .whileEditing

        let addIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)

        subtitleTopConstraint.constant = -(keyboardHeight / 2)
        nextButtonBottomConstraint.constant = keyboardHeight
    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)

        subtitleTopConstraint.constant = subtitleTopConstraintDefaultConstant
        nextButtonBottomConstraint.constant = defaultNextButtonBottomConstraintConstant
    }

    func bind(to viewModel: CreateNicknameViewModel) {
        viewModel.$invalidLengthError
            .sink { [weak self] in
                let color: UIColor = $0 ? .errorText : .text
                self?.nicknameTextField.textColor = color
            }
            .store(in: &cancellables)

        viewModel.$shakeTextView
            .sink { [weak self] in
                guard $0 else { return }
                HapticFeedbackHelper.generate(feedback: .light)
                self?.nicknameTextField.shake()
            }
            .store(in: &cancellables)

        viewModel.$enableCtaButton
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)

        viewModel.$name
            .compactMap { $0 }
            .sink { [weak self] in
                self?.nicknameTextField.text = $0
            }
            .store(in: &cancellables)
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
}
