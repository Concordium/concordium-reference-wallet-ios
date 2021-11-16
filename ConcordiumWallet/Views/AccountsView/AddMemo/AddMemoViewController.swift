//
//  AddMemoViewController.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import Combine

class AddMemoFactory {
    class func create(with presenter: AddMemoPresenter) -> AddMemoViewController {
        AddMemoViewController.instantiate(fromStoryboard: "SendFund") { coder in
            return AddMemoViewController(coder: coder, presenter: presenter)
        }
    }
}

class AddMemoViewController: KeyboardDismissableBaseViewController, AddMemoViewProtocol, Storyboarded {
    
    var presenter: AddMemoPresenterProtocol
    
    private var cancellables = [AnyCancellable]()
    private var defaultAddMemoButtonBottomConstraint: CGFloat = 0
    
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoTextViewPlaceholderLabel: UILabel!
    @IBOutlet weak var addMemoButton: StandardButton!
    @IBOutlet weak var addMemoButtonBottomConstraint: NSLayoutConstraint!
    
    var memoTitleLabelText: String? {
        didSet {
            memoTitleLabel.text = memoTitleLabelText
        }
    }
    
    var memoTextViewPlaceholderText: String? {
        didSet {
            memoTextViewPlaceholderLabel.text = memoTextViewPlaceholderText
        }
    }
    
    var buttonTitle: String? {
        didSet {
            addMemoButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var pageTitle: String? {
        didSet {
            title = pageTitle
        }
    }
    
    var memoPublisher: AnyPublisher<String, Never> { memoTextView.textPublisher }
    
    init?(coder: NSCoder, presenter: AddMemoPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defaultAddMemoButtonBottomConstraint = addMemoButtonBottomConstraint.constant
        presenter.view = self
        addMemoButton.isEnabled = false
        memoTextView.delegate = self

        presenter.viewDidLoad()
    }

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)
        addMemoButtonBottomConstraint.constant = keyboardHeight
    }

    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        super.keyboardWillHide(keyboardHeight)
        addMemoButtonBottomConstraint.constant = defaultAddMemoButtonBottomConstraint
    }

    override func didDismissKeyboard() {
        setTextViewPlaceholderHidden(!memoTextView.text.isEmpty)
        super.didDismissKeyboard()
    }

    func bind(to viewModel: AddMemoViewModel) {
        viewModel.$invalidMemoSizeError
            .sink { [weak self] in
                let color: UIColor = $0 ? .errorText : .text
                self?.memoTextView.textColor = color
            }
            .store(in: &cancellables)
        
        viewModel.$shakeTextView
            .sink { [weak self] in
                guard $0 else { return }
                HapticFeedbackHelper.generate(feedback: .light)
                self?.memoTextView.shake()
            }
            .store(in: &cancellables)
        
        viewModel.$enableAddMemoToTransferButton
            .assign(to: \.isEnabled, on: addMemoButton)
            .store(in: &cancellables)
        
        viewModel.$memo
            .compactMap { $0?.displayValue }
            .sink { [weak self] memo in
                self?.setTextViewPlaceholderHidden(!memo.isEmpty)
                self?.memoTextView.text = memo
            }
            .store(in: &cancellables)
    }

    @IBAction private func addMemoTapped(_ sender: Any) {
        presenter.userTappedAddMemoToTransfer()
    }
    
    private func setTextViewPlaceholderHidden(_ hidden: Bool) {
        memoTextViewPlaceholderLabel.isHidden = hidden
    }
}

// MARK: - UITextViewDelegate

extension AddMemoViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setTextViewPlaceholderHidden(true)
        return true
    }
}
