//
//  DelegationPoolSelectionViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 08/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol DelegationPoolSelectionViewProtocol: ShowAlert, Loadable {
    func bind(viewModel: DelegationPoolViewModel)
    var poolOption: PassthroughSubject<Int, Error> { get }
    var bakerIdPublisher: AnyPublisher<String, Never> { get }
    
}

class DelegationPoolSelectionFactory {
    class func create(with presenter: DelegationPoolSelectionPresenter) -> DelegationPoolSelectionViewController {
        DelegationPoolSelectionViewController.instantiate(fromStoryboard: "Stake") {coder in
            return DelegationPoolSelectionViewController(coder: coder, presenter: presenter)
        }
    }
}

class DelegationPoolSelectionViewController: KeyboardDismissableBaseViewController, DelegationPoolSelectionViewProtocol, Storyboarded {
    var poolOption = PassthroughSubject<Int, Error>()
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var poolSelectionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var currentBakerIdLabel: UILabel!
    @IBOutlet weak var bakerIdTextField: UITextField!
    @IBOutlet weak var bakerIdErrorLabel: UILabel!
    @IBOutlet weak var continueButton: StandardButton!
   
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var linkListener: LinkPressedListener?
    private var cancellables = Set<AnyCancellable>()
    
    var bakerIdPublisher: AnyPublisher<String, Never> {
        return bakerIdTextField.textPublisher
            .eraseToAnyPublisher()
    }
    var presenter: DelegationPoolSelectionPresenterProtocol

    init?(coder: NSCoder, presenter: DelegationPoolSelectionPresenterProtocol) {
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
        poolSelectionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        poolSelectionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.whiteText], for: .selected)
        poolSelectionSegmentedControl.setTitle("delegation.pool.baker".localized, forSegmentAt: 0)
        poolSelectionSegmentedControl.setTitle("delegation.pool.passive".localized, forSegmentAt: 1)
        linkListener = bottomLabel.addOnLinkPressedListener()
        
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
    
    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = -keyboardHeight
        view.layoutIfNeeded()
    }
    
    override func keyboardWillHide(_ keyboardHeight: CGFloat) {
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    // swiftlint:disable function_body_length
    func bind(viewModel: DelegationPoolViewModel) {
        viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        
        viewModel.$message.sink { [weak self] text in
            self?.topLabel.text = text
        }.store(in: &cancellables)
        
        viewModel.$selectedPoolIndex.sink { [weak self] index in
            self?.poolSelectionSegmentedControl.selectedSegmentIndex = index
            if index == 0 {
                self?.bakerIdTextField.isHidden = false
            } else {
                self?.bakerIdTextField.isHidden = true
                self?.bakerIdTextField.resignFirstResponder()
            }
        }.store(in: &cancellables)
        
        viewModel.$currentValue.sink { currentBakerIdValue in
            if let currentBakerIdValue = currentBakerIdValue {
                self.currentBakerIdLabel.isHidden = false
                self.currentBakerIdLabel.text = currentBakerIdValue
                self.bakerIdTextField.placeholder = "delegation.pool.idplaceholder.update".localized
            } else {
                self.currentBakerIdLabel.isHidden = true
                self.bakerIdTextField.placeholder = "delegation.pool.idplaceholder.create".localized
            }
        }.store(in: &cancellables)
        
        viewModel.$bakerId
            .compactMap { $0 }
            .assign(to: \.text, on: bakerIdTextField)
            .store(in: &cancellables)
        
        viewModel.$bakerIdErrorMessage.sink { [weak self] errorMessage in
            guard let self = self else { return }
            if let errorMessage = errorMessage {
                self.bakerIdErrorLabel.text = errorMessage
                self.bakerIdErrorLabel.isHidden = false
                self.bakerIdTextField.textColor = .errorText
            } else {
                self.bakerIdErrorLabel.isHidden = true
                self.bakerIdTextField.textColor = .primary
            }
        }.store(in: &cancellables)
    
        viewModel.$bottomMessage
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] bottomMessage in
                self?.bottomLabel.attributedText = bottomMessage
            })
            .store(in: &cancellables)
        
        viewModel.$isPoolValid
            .compactMap { $0 }
            .assign(to: \.isEnabled, on: continueButton)
            .store(in: &cancellables)
    }
    
    @IBAction func pressedContinue(_ sender: Any) {
        self.presenter.pressedContinue()
    }
    
    @IBAction func poolOptionChanged(_ sender: UISegmentedControl) {
        poolOption.send(sender.selectedSegmentIndex)
    }
}
