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
protocol DelegationPoolSelectionViewProtocol: AnyObject {
    func bind(viewModel: DelegationPoolViewModel)
    var bakerIdPublisher: AnyPublisher<String, Never> { get }
}

class DelegationPoolSelectionFactory {
    class func create(with presenter: DelegationPoolSelectionPresenter) -> DelegationPoolSelectionViewController {
        DelegationPoolSelectionViewController.instantiate(fromStoryboard: "Stake") {coder in
            return DelegationPoolSelectionViewController(coder: coder, presenter: presenter)
        }
    }
}

class DelegationPoolSelectionViewController: BaseViewController, DelegationPoolSelectionViewProtocol, Storyboarded {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var poolSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bakerIdTextField: UITextField!
    @IBOutlet weak var bakerIdErrorLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
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

        presenter.view = self
        presenter.viewDidLoad()
    }
    
    func bind(viewModel: DelegationPoolViewModel) {
        
    }
    
    @IBAction func pressedContinue(_ sender: Any) {
    }
}
