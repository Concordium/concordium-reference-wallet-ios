//
//  BakerMetadataViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 21/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol BakerMetadataViewProtocol: ShowAlert {
    func bind(viewModel: BakerMetadataViewModel)
}

class BakerMetadataFactory {
    class func create(with presenter: BakerMetadataPresenterProtocol) -> BakerMetadataViewController {
        BakerMetadataViewController.instantiate(fromStoryboard: "Stake") {coder in
            return BakerMetadataViewController(coder: coder, presenter: presenter)
        }
    }
}

class BakerMetadataViewController: KeyboardDismissableBaseViewController, BakerMetadataViewProtocol, Storyboarded {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var metadataTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var linkPressedListener: LinkPressedListener?
    
    private var cancellables = Set<AnyCancellable>()
    
	var presenter: BakerMetadataPresenterProtocol

    init?(coder: NSCoder, presenter: BakerMetadataPresenterProtocol) {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close_icon"),
            style: .plain,
            target: self,
            action: #selector(pressedClose)
        )
        
        linkPressedListener = textLabel.addOnLinkPressedListener()
        
        presenter.view = self
        presenter.viewDidLoad()
    }

    func bind(viewModel: BakerMetadataViewModel) {
        viewModel.$title
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
        
        viewModel.$text
            .assign(to: \.attributedText, on: textLabel)
            .store(in: &cancellables)
        
        viewModel.$currentValueLabel
            .assign(to: \.text, on: currentValueLabel)
            .store(in: &cancellables)
        
        metadataTextField.text = viewModel.currentValue
        
        viewModel.$placeholder
            .assign(to: \.placeholder, on: metadataTextField)
            .store(in: &cancellables)
        
        metadataTextField.textPublisher
            .assignNoRetain(to: \.currentValue, on: viewModel)
            .store(in: &cancellables)
    }
    
    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = -keyboardHeight
        view.layoutIfNeeded()
    }
    
    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func pressedContinue(_ sender: UIButton) {
        presenter.pressedContinue()
    }
    
    @objc func pressedClose() {
        presenter.pressedClose()
    }
}
