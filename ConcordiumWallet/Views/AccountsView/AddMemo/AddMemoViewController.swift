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

class AddMemoViewController: BaseViewController, AddMemoViewProtocol, Storyboarded {
   
    var presenter: AddMemoPresenterProtocol
    
    private var cancellables = [AnyCancellable]()

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
    
    init?(coder: NSCoder, presenter: AddMemoPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        addMemoButton.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tapGesture)
        
        memoTextView.delegate = self
        
        presenter.viewDidLoad()
    }
    
    func bind(to: AddMemoViewModel) {
        
    }
    
    @objc private func hideKeyboardOnTap(_ sender: Any) {
        setTextViewPlaceholderHidden(!memoTextView.text.isEmpty)
        view.endEditing(true)
    }
    
    @IBAction private func addMemoTapped(_ sender: Any) {

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
